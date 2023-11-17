use thiserror::Error;

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
    #[error("attempt to access RouteManager functionality with invlaid LoginToken id")]
    UnauthenticatedUser,
    #[error("database error: {0}")]
    UnhandledDatabaseError(#[from] sqlx::Error),
    #[error("driver not registered for vehicle {0}")]
    IncompatibelVehicle(String),
}
