use tonic::Response;
use tracing::{event, instrument, Level};
pub mod grpc_user_manager {
    tonic::include_proto!("user_manager");
}
use self::grpc_user_manager::{Login, LoginResponse, LoginResult as GrpcLoginResult};
use super::{LoginResult, RegisterResult, UserManager};
use grpc_user_manager::user_manager_server::UserManager as UserManagerService;
use grpc_user_manager::{Registration, RegistrationResponse, RegistrationResult};

pub use grpc_user_manager::user_manager_server::UserManagerServer;

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
