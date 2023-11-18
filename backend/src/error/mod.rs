use thiserror::Error;
use tonic::{Code, Status};

#[derive(Error, Debug)]
pub enum Error {
    #[error("supplied route is invalid")]
    InvalidRoute,
    #[error("vehicle {0} not in database")]
    UnknownVehicle(String),
    #[error("route with id {0} not in database")]
    UnknownRoute(i32),
    #[error("route with id {0} is already assigned")]
    RouteAlreadyAssigned(i32),
    #[error("driver {0} already assigned a route")]
    DriverAlreadyAssigned(String),
    #[error("driver {0} is not assigned to a route")]
    DriverNotAssigned(String),
    #[error("attempt to access RouteManager functionality with invlaid LoginToken id")]
    UnauthenticatedUser,
    #[error("database error: {0}")]
    UnhandledDatabaseError(#[from] sqlx::Error),
    #[error("driver not registered for vehicle {0}")]
    IncompatibelVehicle(String),
    #[error("invalid status update, new step {0} is smaller than current step {1}")]
    RouteUpdateSmallerThanCurrent(i32, i32),
    #[error("invalid status update, new step {0} exceeds total steps {1}")]
    RouteUpdateExceedsEventCount(i32, i32),
    #[error("supplied token id is invalid")]
    MalformedTokenId,
}

impl From<Error> for Status {
    fn from(error: Error) -> Self {
        let code = match error {
            Error::InvalidRoute
            | Error::DriverNotAssigned(_)
            | Error::IncompatibelVehicle(_)
            | Error::RouteUpdateSmallerThanCurrent(_, _)
            | Error::RouteUpdateExceedsEventCount(_, _)
            | Error::MalformedTokenId => Code::InvalidArgument,
            Error::UnknownVehicle(_) | Error::UnknownRoute(_) => Code::NotFound,
            Error::RouteAlreadyAssigned(_) | Error::DriverAlreadyAssigned(_) => {
                Code::ResourceExhausted
            }
            Error::UnauthenticatedUser => Code::Unauthenticated,
            Error::UnhandledDatabaseError(_) => Code::Unknown,
        };
        Self::new(code, error.to_string())
    }
}
