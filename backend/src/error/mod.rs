use crate::constants::database_error_codes::{
    DATABASE_FOREIGN_KEY_VIOLATION, DATABASE_UNIQUE_CONSTRAINT_VIOLATED,
};
use sqlx::error::DatabaseError;
use std::sync::Arc;
// use thiserror::Error;
use tonic::{Code, Status};

#[derive(thiserror::Error, Debug)]
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
    IncompatibleVehicle(String),
    #[error("invalid status update, new step {0} is smaller than current step {1}")]
    RouteUpdateSmallerThanCurrent(i32, i32),
    #[error("invalid status update, new step {0} exceeds total steps {1}")]
    RouteUpdateExceedsEventCount(i32, i32),
    #[error("supplied token id is invalid {0}")]
    MalformedTokenId(#[from] uuid::Error),
    #[error("driver {0} not registered")]
    DriverNotRegistered(String),
    #[error("invalid password")]
    InvalidPassword,
    #[error("driver with name {0} already registered")]
    DuplicateUsername(String),
}

impl From<Error> for Status {
    fn from(error: Error) -> Self {
        let code = match error {
            Error::InvalidRoute
            | Error::DriverNotAssigned(_)
            | Error::IncompatibleVehicle(_)
            | Error::RouteUpdateSmallerThanCurrent(_, _)
            | Error::RouteUpdateExceedsEventCount(_, _)
            | Error::MalformedTokenId(_)
            | Error::InvalidPassword => Code::InvalidArgument,
            Error::UnknownVehicle(_) | Error::UnknownRoute(_) | Error::DriverNotRegistered(_) => {
                Code::NotFound
            }
            Error::RouteAlreadyAssigned(_)
            | Error::DriverAlreadyAssigned(_)
            | Error::DuplicateUsername(_) => Code::ResourceExhausted,
            Error::UnauthenticatedUser => Code::Unauthenticated,
            Error::UnhandledDatabaseError(_) => Code::Unknown,
        };
        let mut status = Self::new(code, error.to_string());
        status.set_source(Arc::new(error));
        status
    }
}

/// checks if a DatabaseError has a code which matches the supplied code.
fn error_code(error: &Box<dyn DatabaseError>, code: &str) -> bool {
    error.code().is_some_and(|err_code| err_code == code)
}

/// checks if a DatabaseError has a constraint which matches the supplied constraint.
fn error_constraint(error: &Box<dyn DatabaseError>, constraint: &str) -> bool {
    error
        .constraint()
        .is_some_and(|err_constraint| err_constraint == constraint)
}

/// checks if a `sqlx::Error` is a `Error::Database` and if the contained
/// `DatabaseError` is notifying a unique constraint violation.
pub fn violates_unique_constraint(error: &sqlx::Error) -> bool {
    if let sqlx::Error::Database(error) = error {
        error_code(error, DATABASE_UNIQUE_CONSTRAINT_VIOLATED)
    } else {
        false
    }
}

/// checks if a `sqlx::Error` is a `Error::Database` and if the contained
/// `DatabaseError` is notifying a foreign key constraint violation.
/// Optionally checks the constraint name, if one is supplied in `details`.
pub fn violates_fk_constraint(error: &sqlx::Error, details: Option<&str>) -> bool {
    if let sqlx::Error::Database(error) = error {
        error_code(error, DATABASE_FOREIGN_KEY_VIOLATION)
            && details.map_or(true, |details| error_constraint(error, details))
    } else {
        false
    }
}
