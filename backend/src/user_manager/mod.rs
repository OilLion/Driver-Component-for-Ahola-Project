use sqlx::{Pool, Postgres};
use tracing::{event, instrument, Level};

pub mod grpc_user_manager {
    tonic::include_proto!("user_manager");
}

use grpc_user_manager::user_manager_server::UserManager as UserManagerService;
use grpc_user_manager::{Registration, RegistrationResponse, RegistrationResult};
use tonic::Response;

use crate::types::{LoginToken, LoginTokens};

use std::time::{Duration, Instant};

use crate::constants::database_error_codes::*;

use self::grpc_user_manager::{Login, LoginResponse, LoginResult as GrpcLoginResult};

#[derive(Debug)]
pub struct UserManager {
    database: Pool<Postgres>,
    login_tokens: LoginTokens,
    user_timeout: Duration,
}

impl UserManager {
    pub fn new(
        database: Pool<Postgres>,
        login_tokens: LoginTokens,
        user_timeout: Duration,
    ) -> Self {
        Self {
            database,
            login_tokens,
            user_timeout,
        }
    }
    async fn add_driver(
        &self,
        username: &str,
        password: &str,
        vehicle: &str,
    ) -> Result<RegisterResult, sqlx::Error> {
        let result = sqlx::query!(
            "INSERT INTO DRIVER (name, password, Veh_name)
                VALUES ($1, $2, $3)",
            username,
            password,
            vehicle,
        )
        .execute(&self.database)
        .await;
        match result {
            Ok(_) => Ok(RegisterResult::Success),
            Err(sqlx::Error::Database(error))
                if error
                    .code()
                    .is_some_and(|code| code == DATABASE_UNIQUE_CONSTRAINT_VIOLATED) =>
            {
                Ok(RegisterResult::DuplicateUsername)
            }
            Err(err) => Err(err),
        }
    }
    async fn login_driver(
        &self,
        username: &str,
        password: &str,
    ) -> Result<LoginResult, sqlx::Error> {
        // let mut transaction = self.database.begin().await?;
        let query = sqlx::query!(
            "SELECT password FROM DRIVER
                WHERE name = $1",
            username
        );
        let result = query.fetch_one(&self.database).await;
        match result {
            Ok(record) => Ok(if record.password == password {
                let expiration = Instant::now() + self.user_timeout;
                let token = LoginToken::new(username.into(), expiration);
                self.login_tokens.insert_token(token.id, token.clone());
                LoginResult::Success(token)
            } else {
                LoginResult::InvalidPassword
            }),
            Err(sqlx::Error::RowNotFound) => Ok(LoginResult::DoesNotExist),
            Err(e) => Err(e),
        }
    }
}

#[derive(Debug, PartialEq, Eq)]
enum LoginResult {
    Success(LoginToken),
    InvalidPassword,
    DoesNotExist,
}

#[derive(Debug, Eq, PartialEq)]
enum RegisterResult {
    Success,
    DuplicateUsername,
}

#[tonic::async_trait]
impl UserManagerService for UserManager {
    #[instrument]
    async fn register_user(
        &self,
        registration: tonic::Request<Registration>,
    ) -> Result<Response<RegistrationResponse>, tonic::Status> {
        let Registration {
            username,
            password,
            vehicle,
        } = registration.into_inner();
        match self
            .add_driver(username.as_str(), password.as_str(), vehicle.as_str())
            .await
        {
            Ok(RegisterResult::Success) => {
                event!(
                    Level::INFO,
                    message = "registered new driver",
                    %username,
                );
                Ok(Response::new(RegistrationResponse {
                    result: RegistrationResult::RegistrationSuccess as i32,
                }))
            }
            Ok(RegisterResult::DuplicateUsername) => {
                event!(
                    Level::DEBUG,
                    message = "registration attempt with existing username",
                    %username,
                );
                Ok(Response::new(RegistrationResponse {
                    result: RegistrationResult::UserAlreadyExists as i32,
                }))
            }
            Err(error) => {
                event!(Level::ERROR, %error, "unhandled database error");
                Ok(Response::new(RegistrationResponse {
                    result: RegistrationResult::RegistrationUnknownError as i32,
                }))
            }
        }
    }
    #[instrument]
    async fn login_user(
        &self,
        login: tonic::Request<Login>,
    ) -> Result<Response<LoginResponse>, tonic::Status> {
        let Login { username, password } = login.into_inner();
        match self
            .login_driver(username.as_str(), password.as_str())
            .await
        {
            Ok(login_result) => Ok(Response::new(match login_result {
                LoginResult::Success(token) => {
                    event!(Level::INFO, user_logged_in = %username);
                    LoginResponse {
                        result: GrpcLoginResult::LoginSuccess as i32,
                        uuid: (*token.id.as_bytes()).into(),
                        duration: self.user_timeout.as_secs(),
                    }
                }
                LoginResult::InvalidPassword => {
                    event!(Level::DEBUG, %username, "user attempted to login with wrong password");
                    LoginResponse {
                        result: GrpcLoginResult::InvalidPassword as i32,
                        uuid: vec![],
                        duration: 0,
                    }
                }
                LoginResult::DoesNotExist => {
                    event!(Level::DEBUG, %username, "loginattempt with nonexistent username");
                    LoginResponse {
                        result: GrpcLoginResult::DoesNotExist as i32,
                        uuid: vec![],
                        duration: 0,
                    }
                }
            })),
            Err(error) => {
                event!(Level::ERROR, %username, %error, "loginattempt lead to unhandled error");
                Ok(Response::new(LoginResponse {
                    result: GrpcLoginResult::LoginUnknownError as i32,
                    uuid: vec![],
                    duration: 0,
                }))
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::constants::DATABASE_URL;
    use sqlx::{postgres::PgPoolOptions, Pool, Postgres};
    use uuid::Uuid;

    async fn get_database_pool() -> Pool<Postgres> {
        PgPoolOptions::new()
            .max_connections(5)
            .connect(DATABASE_URL)
            .await
            .unwrap()
    }

    #[tokio::test]
    async fn create_and_login_user() {
        let (pool, user_manager, tokens) = setup().await;
        let username = Uuid::new_v4().to_string();
        let password = Uuid::new_v4().to_string();
        let vehicle = "Truck";
        // Register the driver
        assert!(user_manager
            .add_driver(username.as_str(), password.as_str(), vehicle)
            .await
            .is_ok());

        let driver = sqlx::query!(
            "SELECT name, password, Veh_name FROM DRIVER WHERE name = $1",
            username
        )
        .fetch_one(&pool)
        .await
        .unwrap();
        assert_eq!(driver.name, username);
        assert_eq!(driver.password, password);
        assert_eq!(driver.veh_name, "Truck");
        // Try logging in as the driver
        let login_token = user_manager
            .login_driver(username.as_str(), password.as_str())
            .await
            .unwrap();
        // Login should be successful and the returned token should
        // match the one in the `LoginTokens` map
        if let LoginResult::Success(token) = login_token {
            assert_eq!(token.user, username);
            assert!(tokens.contains_token(&token.id));
        } else {
            panic!("wrong LoginResult variant")
        }
        sqlx::query!("DELETE FROM DRIVER WHERE name = $1", username)
            .execute(&pool)
            .await
            .unwrap();
    }

    #[tokio::test]
    async fn create_user_twice() {
        let (pool, user_manager, _) = setup().await;
        let username = Uuid::new_v4().to_string();
        let password = Uuid::new_v4().to_string();
        let vehicle = "Truck";
        assert!(user_manager
            .add_driver(username.as_str(), password.as_str(), vehicle)
            .await
            .is_ok());
        let result = user_manager
            .add_driver(&username.as_str(), password.as_str(), vehicle)
            .await
            .unwrap();
        assert!(matches!(result, RegisterResult::DuplicateUsername));

        sqlx::query!("DELETE FROM DRIVER WHERE name = $1", username)
            .execute(&pool)
            .await
            .unwrap();
    }

    #[tokio::test]
    async fn wrong_password() {
        let (pool, user_manager, tokens) = setup().await;
        let username = Uuid::new_v4().to_string();
        let password = Uuid::new_v4().to_string();
        let vehicle = "Truck";
        assert!(user_manager
            .add_driver(username.as_str(), password.as_str(), vehicle)
            .await
            .is_ok());

        let login_result = user_manager
            .login_driver(username.as_str(), "wrong password")
            .await
            .unwrap();
        assert!(matches!(login_result, LoginResult::InvalidPassword));
        // no login token should be in the LoginTokens map
        assert!(tokens.is_empty());

        sqlx::query!("DELETE FROM DRIVER WHERE name = $1", username)
            .execute(&pool)
            .await
            .unwrap();
    }

    #[tokio::test]
    async fn login_nonexistant_user() {
        let (_, user_manager, tokens) = setup().await;
        let username = Uuid::new_v4().to_string();
        let password = Uuid::new_v4().to_string();
        let login_result = user_manager
            .login_driver(username.as_str(), password.as_str())
            .await
            .unwrap();
        assert!(tokens.is_empty());
        assert!(matches!(login_result, LoginResult::DoesNotExist))
    }

    #[tokio::test]
    async fn login_twice() {
        let (pool, user_manager, tokens) = setup().await;
        let username = Uuid::new_v4().to_string();
        let password = Uuid::new_v4().to_string();
        let vehicle = "Truck";
        user_manager
            .add_driver(username.as_str(), password.as_str(), vehicle)
            .await
            .unwrap();
        let login_token_a = user_manager
            .login_driver(username.as_str(), password.as_str())
            .await
            .unwrap();
        let login_token_b = user_manager
            .login_driver(username.as_str(), password.as_str())
            .await
            .unwrap();
        // login tokens should not be equal
        assert_ne!(login_token_a, login_token_b);
        if let LoginResult::Success(token) = login_token_a {
            assert!(tokens.contains_token(&token.id));
        } else {
            panic!("wrong LoginResult variant")
        }
        if let LoginResult::Success(token) = login_token_b {
            assert!(tokens.contains_token(&token.id));
        } else {
            panic!("wrong LoginResult variant")
        }
        sqlx::query!("DELETE FROM DRIVER WHERE name = $1", username)
            .execute(&pool)
            .await
            .unwrap();
    }

    /// Test helper function to setup the databse connect and needed objects
    async fn setup() -> (Pool<Postgres>, UserManager, LoginTokens) {
        let pool = get_database_pool().await;
        let tokens = crate::types::LoginTokens::new();
        let user_manager = UserManager::new(
            pool.clone(),
            tokens.clone(),
            std::time::Duration::from_secs(10),
        );
        (pool, user_manager, tokens)
    }
}
