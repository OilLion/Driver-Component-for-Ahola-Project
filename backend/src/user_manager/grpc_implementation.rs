use tonic::Response;
use tracing::{event, instrument, Level};

use super::UserManager;
use crate::error::Error;

pub mod grpc_user_manager {
    tonic::include_proto!("user_manager");
}
#[rustfmt::skip]
pub use grpc_user_manager::user_manager_server::{
    UserManagerServer,
    UserManager as UserManagerService,
};
#[rustfmt::skip]
use grpc_user_manager::{
    Login, LoginResponse, LoginResult,
    Registration, RegistrationResponse, RegistrationResult,
};

#[tonic::async_trait]
impl UserManagerService for UserManager {
    /// Registers a new driver in the database, by calling the [`add_driver`](UserManager::add_driver) method.
    /// The `username`, `password` and `vehicle` are taken from the [`Registration`] message.
    /// The `Result<(), Error>` is matched against and converted into the appropriate
    /// [`RegistrationResult`] in a [`RegistrationResponse`].
    ///
    /// # Logging
    /// Logs the result of the registration attempt with an appropriate log [`Level`].
    /// Unknown errors are logged with [`Level::ERROR`] and all other errors are logged with
    /// [`Level::DEBUG`].
    /// A successful registration is logged with [`Level::INFO`].
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
        let result = self
            .add_driver(username.as_str(), password.as_str(), vehicle.as_str())
            .await;
        match result {
            Ok(_) => {
                event!(
                    Level::INFO,
                    message = "registered new driver",
                    %username,
                );
                Ok(Response::new(RegistrationResponse {
                    result: RegistrationResult::RegistrationSuccess as i32,
                }))
            }
            Err(err) => Ok(handle_register_error(err)),
        }
    }
    /// Logs in a driver, by calling the [`login_driver`](UserManager::login_driver) method.
    /// The `username` and `password` are taken from the [`Login`] message in the request.
    /// The `Result<LoginToken, Error>` is matched against and converted into the appropriate
    /// [`LoginResult`] in a [`LoginResponse`].
    /// An `Ok(LoginToken)` is converted into a [`LoginResult::LoginSuccess`] message containing
    /// the tokens id and the duration for which it is valid in seconds.
    /// # Logging
    /// Logs the result of the login attempt with an appropriate log [`Level`].
    /// Unknown errors are logged with [`Level::ERROR`] and all other errors are logged with
    /// [`Level::DEBUG`].
    /// A successful login is logged with [`Level::INFO`].
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
            Ok(token) => Ok(Response::new({
                event!(Level::INFO, user_logged_in = %username);
                LoginResponse {
                    result: LoginResult::LoginSuccess as i32,
                    uuid: (*token.id.as_bytes()).into(),
                    duration: self.user_timeout.as_secs(),
                }
            })),
            Err(e) => match e {
                Error::DriverNotRegistered(_) => {
                    event!(Level::DEBUG, %username, "loginattempt with nonexistent username");
                    Ok(Response::new(LoginResponse {
                        result: LoginResult::DoesNotExist as i32,
                        uuid: vec![],
                        duration: 0,
                    }))
                }
                Error::InvalidPassword => {
                    event!(Level::DEBUG, %username, "user attempted to login with wrong password");
                    Ok(Response::new(LoginResponse {
                        result: LoginResult::InvalidPassword as i32,
                        uuid: vec![],
                        duration: 0,
                    }))
                }
                error => {
                    event!(Level::ERROR, %username, %error, "login attempt lead to unhandled error");
                    Ok(Response::new(LoginResponse {
                        result: LoginResult::LoginUnknownError as i32,
                        uuid: vec![],
                        duration: 0,
                    }))
                }
            },
        }
    }
}

fn handle_register_error(error: crate::error::Error) -> Response<RegistrationResponse> {
    match error {
        Error::DuplicateUsername(username) => {
            event!(
                Level::DEBUG,
                message = "registration attempt with existing username",
                %username,
            );
            Response::new(RegistrationResponse {
                result: RegistrationResult::UserAlreadyExists as i32,
            })
        }
        Error::UnhandledDatabaseError(error) => {
            event!(Level::ERROR, %error, "unhandled database error");
            Response::new(RegistrationResponse {
                result: RegistrationResult::RegistrationUnknownError as i32,
            })
        }
        error => {
            event!(Level::ERROR, %error, "unhandled error");
            Response::new(RegistrationResponse {
                result: RegistrationResult::RegistrationUnknownError as i32,
            })
        }
    }
}
