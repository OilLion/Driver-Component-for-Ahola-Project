use tonic::{Request, Response, Status};
use tracing::{event, instrument, Level};
use uuid::Uuid;

use super::RouteManager;
use crate::error::Error;
use crate::types::routes::{DriverRoute, Event, Route};

pub mod grpc_route_manager {
    tonic::include_proto!("route_manager");
}
use grpc_route_manager::route_manager_server::RouteManager as RouteManagerService;

#[rustfmt::skip]
use grpc_route_manager::{
    AddRouteResponse,
    AssignedRoute,
    Event as EventMessage,
    GetRoutesRequest,
    Result as RMResult,
    Route as RouteMessage,
    RouteReply,
    RoutesReply,
    SelectRouteRequest,
    SelectRouteResponse,
};
use crate::route_manager::grpc_implementation::grpc_route_manager::GetAssignedRouteRequest;
use crate::sql;

impl From<RouteMessage> for Route {
    fn from(route_message: RouteMessage) -> Self {
        Self {
            events: route_message
                .events
                .into_iter()
                .map(|event| event.into())
                .collect(),
            vehicle: route_message.vehicle,
        }
    }
}

impl From<EventMessage> for Event {
    fn from(event_message: EventMessage) -> Self {
        Self {
            location: event_message.location,
        }
    }
}

impl From<Error> for AddRouteResponse {
    fn from(error: Error) -> Self {
        use Error as RE;
        Self {
            result: match error {
                RE::InvalidRoute => RMResult::InvalidRoute.into(),
                RE::UnknownVehicle(_) => RMResult::UnknownVehicle.into(),
                _ => RMResult::UnknownError.into(),
            },
            route_id: -1,
        }
    }
}

impl From<Error> for RoutesReply {
    fn from(error: Error) -> Self {
        Self {
            result: match error {
                Error::UnauthenticatedUser => RMResult::UnauthenticatedUser.into(),
                _ => RMResult::UnknownError.into(),
            },
            routes: Vec::new(),
        }
    }
}

impl From<Error> for SelectRouteResponse {
    fn from(error: Error) -> Self {
        Self {
            result: match error {
                Error::UnknownRoute(_) => RMResult::UnknownRoute.into(),
                Error::RouteAlreadyAssigned(_) => RMResult::RouteAlreadyAssigned.into(),
                Error::DriverAlreadyAssigned(_) => RMResult::DriverAlreadyAssigned.into(),
                Error::UnauthenticatedUser => RMResult::UnauthenticatedUser.into(),
                Error::IncompatibelVehicle(_) => RMResult::IncompatibleVehicle.into(),
                Error::UnhandledDatabaseError(_)
                | Error::DriverNotAssigned(_)
                | Error::UnknownVehicle(_)
                | Error::RouteUpdateSmallerThanCurrent(..)
                | Error::RouteUpdateExceedsEventCount(_, _)
                | Error::MalformedTokenId(_)
                | Error::InvalidRoute
                | Error::DriverNotRegistered(_)
                | Error::InvalidPassword
                | Error::DuplicateUsername(_) => RMResult::UnknownError.into(),
            },
        }
    }
}

impl From<i32> for AddRouteResponse {
    fn from(route_id: i32) -> Self {
        event!(Level::INFO, route_id);
        Self {
            result: RMResult::Success.into(),
            route_id,
        }
    }
}

fn log_route_manager_error_and_convert_to_message<T>(err: Error) -> T
where
    T: From<Error>,
{
    match err {
        Error::UnhandledDatabaseError(_) => event!(Level::ERROR, %err),
        _ => event!(Level::DEBUG, %err),
    };
    err.into()
}

#[tonic::async_trait]
impl RouteManagerService for RouteManager {
    /// Inserts a new route into the database, by calling the [`insert_route`](RouteManager::insert_route) method.
    /// The `vehicle` and `events` are taken from the [`Route`] message.
    /// The `Result<i32, Error>` is mapped into the appropriate
    /// [`AddRouteResponse`] in a [`Response`].
    /// If the route is successfully inserted, the assigned id is returned in the response.
    /// #Logging
    /// Logs the result of the insertion attempt with an appropriate log [`Level`].
    /// Unknown errors are logged with [`Level::ERROR`] and all other errors are logged with
    /// [`Level::DEBUG`].
    /// A successful insertion is logged with [`Level::INFO`].
    #[instrument]
    async fn add_route(
        &self,
        route_request: tonic::Request<RouteMessage>,
    ) -> Result<Response<AddRouteResponse>, tonic::Status> {
        Ok(Response::new(
            self.add_route(route_request.into_inner().into())
                .await
                .map_or_else(log_route_manager_error_and_convert_to_message, |route_id| {
                    route_id.into()
                }),
        ))
    }

    /// Retrieves routes from the database, by calling the [`get_routes`](RouteManager::get_routes) method.
    /// The `uuid` is taken from the [`GetRoutesRequest`] message.
    /// The `Result<Vec<DriverRoute>, Error>` is mapped into the appropriate
    /// [`RoutesReply`] in a [`Response`].
    /// If the routes are successfully retrieved, they are returned in the response.
    /// #Logging
    /// Logs the result of the retrieval attempt with an appropriate log [`Level`].
    /// Unknown errors are logged with [`Level::ERROR`] and all other errors are logged with
    /// [`Level::DEBUG`].
    #[instrument]
    async fn get_routes(
        &self,
        request: Request<GetRoutesRequest>,
    ) -> Result<Response<RoutesReply>, tonic::Status> {
        Ok(Response::new(
            if let Ok(token) = Uuid::from_slice(&request.into_inner().uuid) {
                self.get_routes(token).await.map_or_else(
                    log_route_manager_error_and_convert_to_message,
                    |routes| RoutesReply {
                        result: RMResult::Success.into(),
                        routes: routes.map(|route| route.into()).collect(),
                    },
                )
            } else {
                RoutesReply {
                    result: RMResult::MalformedLoginToken.into(),
                    routes: Vec::new(),
                }
            },
        ))
    }

    /// Selects a route for a driver, by calling the [`select_route`](RouteManager::select_route) method.
    /// The `route_id` and `uuid` are taken from the [`SelectRouteRequest`] message.
    /// The `Result<(), Error>` is mapped into the appropriate
    /// [`SelectRouteResponse`] in a [`Response`].
    /// If the route is successfully selected, the response contains [`RMResult::Success`].
    /// #Logging
    /// Logs the result of the selection attempt with an appropriate log [`Level`].
    /// Unknown errors are logged with [`Level::ERROR`] and all other errors are logged with
    /// [`Level::DEBUG`].
    /// A successful selection is logged with [`Level::INFO`].
    #[instrument]
    async fn select_route(
        &self,
        request: tonic::Request<SelectRouteRequest>,
    ) -> Result<tonic::Response<SelectRouteResponse>, tonic::Status> {
        let SelectRouteRequest { route_id, uuid } = request.into_inner();
        Ok(Response::new(if let Ok(token) = Uuid::from_slice(&uuid) {
            self.select_route(&token, route_id).await.map_or_else(
                log_route_manager_error_and_convert_to_message,
                |_| SelectRouteResponse {
                    result: RMResult::Success.into(),
                },
            )
        } else {
            SelectRouteResponse {
                result: RMResult::MalformedLoginToken.into(),
            }
        }))
    }

    #[instrument]
    async fn get_assigned_route(
        &self,
        request: Request<GetAssignedRouteRequest>,
    ) -> Result<Response<AssignedRoute>, Status> {
        let GetAssignedRouteRequest { uuid } = request.into_inner();
        let sql::AssignedRoute { route, step } = self.get_assigned_route(&uuid).await?;
        Ok(Response::new({
            AssignedRoute {
                route: Some(route.into()),
                current_step: step,
            }
        }))
    }
}

impl From<DriverRoute> for RouteReply {
    fn from(route: DriverRoute) -> Self {
        Self {
            events: route
                .events
                .into_iter()
                .map(|event| EventMessage {
                    location: event.location,
                })
                .collect(),
            route_id: route.id,
        }
    }
}
