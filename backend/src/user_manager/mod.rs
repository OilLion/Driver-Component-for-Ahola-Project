use crate::{
    error::{violates_unique_constraint, Error},
    sql,
    types::{LoginToken, LoginTokens},
};

use crate::constants::database_error_codes::FOREIGN_KEY_CONSTRAINT_DRIVER_VEHICLE;
use crate::error::violates_fk_constraint;
use sqlx::{Pool, Postgres};
use std::time::{Duration, Instant};

pub mod grpc_implementation;

/// The `UserManager` is responsible for handling the registration and login of drivers.
#[derive(Debug)]
pub struct UserManager {
    database: Pool<Postgres>,
    login_tokens: LoginTokens,
    user_timeout: Duration,
}

impl UserManager {
    /// Creates a new `UserManager` with the given database connection pool and `LoginTokens` map.
    /// The `user_timeout` specifies how long a user can be logged in before the login token expires.
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
    /// Registers a new driver with the given `username`, `password` and `vehicle`, by inserting
    /// a new driver into the database.
    /// The `username` must be unique and the `vehicle` must be registered in the database,
    /// otherwise an error is returned.
    /// # Errors
    /// Returns:
    /// - [`Error::DuplicateUsername`] if the given `username` is already registered.
    /// - [`Error::UnknownVehicle`] if the given `vehicle` is not registered in the database.
    /// - [`Error::UnhandledDatabaseError`] if any other database error occurs.
    async fn add_driver(&self, username: &str, password: &str, vehicle: &str) -> Result<(), Error> {
        let mut conn = self.database.acquire().await?;
        match sql::insert_driver(conn.as_mut(), username, password, vehicle).await {
            Err(error) => {
                if violates_unique_constraint(&error) {
                    Err(Error::DuplicateUsername(username.into()))
                } else if violates_fk_constraint(
                    &error,
                    Some(FOREIGN_KEY_CONSTRAINT_DRIVER_VEHICLE),
                ) {
                    Err(Error::UnknownVehicle(vehicle.into()))
                } else {
                    Err(error.into())
                }
            }
            Ok(_) => Ok(()),
        }
    }

    /// Attempts to log in a driver with the given `username` and `password`.
    /// Checks if the password in the database matches the one supplied.
    /// If the passwords match, a new [`LoginToken`] is created and inserted
    /// into the [`login_tokens`](struct.UserManager.html#structfield.login_tokens) map.
    /// A copy of the token is returned.
    ///
    /// # Errors
    /// Returns:
    /// - [`Error::DriverNotRegistered`] if the given `username` is not found in the
    /// database.
    /// - [`Error::InvalidPassword`] if the given `password` does not match the one in the
    /// database.
    /// - [`Error::UnhandledDatabaseError`] if any other database error occurs.
    async fn login_driver(&self, username: &str, password: &str) -> Result<LoginToken, Error> {
        let mut conn = self.database.acquire().await?;
        let password_matches = sql::check_password(conn.as_mut(), username, password)
            .await
            .map_err(|error| match error {
                sqlx::Error::RowNotFound => Error::DriverNotRegistered(username.into()),
                err => err.into(),
            })?;
        if password_matches {
            let expiration = Instant::now() + self.user_timeout;
            let token = LoginToken::new(username.into(), expiration);
            self.login_tokens.insert_token(token.id, token.clone());
            Ok(token)
        } else {
            Err(Error::InvalidPassword)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::{constants::DATABASE_URL, error::Error};
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
        let token = user_manager
            .login_driver(username.as_str(), password.as_str())
            .await
            .unwrap();
        // Login should be successful and the returned token should
        // match the one in the `LoginTokens` map
        assert_eq!(token.user, username);
        assert!(tokens.contains_token(&token.id));
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
        let error = user_manager
            .add_driver(&username.as_str(), password.as_str(), vehicle)
            .await
            .unwrap_err();
        assert!(matches!(error, Error::DuplicateUsername(err_name) if err_name == username));

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

        let login_error = user_manager
            .login_driver(username.as_str(), "wrong password")
            .await;
        assert!(login_error.is_err_and(|err| matches!(err, Error::InvalidPassword)));
        // no login token should be in the LoginTokens map
        assert!(tokens.is_empty());

        sqlx::query!("DELETE FROM DRIVER WHERE name = $1", username)
            .execute(&pool)
            .await
            .unwrap();
    }

    #[tokio::test]
    async fn login_non_existent_user() {
        let (_, user_manager, tokens) = setup().await;
        let username = Uuid::new_v4().to_string();
        let password = Uuid::new_v4().to_string();
        let login_error = user_manager
            .login_driver(username.as_str(), password.as_str())
            .await;
        assert!(login_error.is_err_and(|err| matches!(err, Error::DriverNotRegistered(username))));
        assert!(tokens.is_empty());
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
        assert!(tokens.contains_token(&login_token_a.id));
        assert!(tokens.contains_token(&login_token_b.id));
        sqlx::query!("DELETE FROM DRIVER WHERE name = $1", username)
            .execute(&pool)
            .await
            .unwrap();
    }

    #[tokio::test]
    async fn insert_for_nonexistet_vehicle() {
        let (_, user_manager, _) = setup().await;
        let username = Uuid::new_v4().to_string();
        let password = Uuid::new_v4().to_string();
        let vehicle = Uuid::new_v4().to_string();
        let error = user_manager
            .add_driver(username.as_str(), password.as_str(), vehicle.as_str())
            .await
            .unwrap_err();
        assert!(matches!(error, Error::UnknownVehicle(err_vehicle) if err_vehicle == vehicle));
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
