pub mod grpc_route_manager {
    tonic::include_proto!("route_manager");
}
use grpc_route_manager::route_manager_server::RouteManager as RouteManagerService;

// import type definitions from proto
#[rustfmt::skip]
use grpc_route_manager::{
    Event as EventMessage,
    Route as RouteMessage,
    AddRouteResponse, 
    RoutesReply,
    RouteReply,
    GetRoutesRequest,
    SelectRouteRequest,
    Result as RMResult,
};

use tonic::{Request, Response};
use tracing::{event, instrument, Level};
use uuid::Uuid;

use crate::types::routes::{Event, Route};

use self::grpc_route_manager::SelectRouteResponse;

use super::{RouteManager, RouteManagerError, _Route};

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

impl From<RouteManagerError> for AddRouteResponse {
    fn from(error: RouteManagerError) -> Self {
        use RouteManagerError as RE;
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

impl From<RouteManagerError> for RoutesReply {
    fn from(error: RouteManagerError) -> Self {
        Self {
            result: match error {
                RouteManagerError::UnauthenticatedUser => RMResult::UnauthenticatedUser.into(),
                _ => RMResult::UnknownError.into(),
            },
            routes: Vec::new(),
        }
    }
}

impl From<RouteManagerError> for SelectRouteResponse {
    fn from(error: RouteManagerError) -> Self {
        Self {
            result: match error {
                RouteManagerError::UnknownRoute(_) => RMResult::UnknownRoute.into(),
                RouteManagerError::RouteAlreadyAssigned(_) => RMResult::RouteAlreadyAssigned.into(),
                RouteManagerError::DriverAlreadyAssigned(_) => {
                    RMResult::DriverAlreadyAssigned.into()
                }
                RouteManagerError::UnauthenticatedUser => RMResult::UnauthenticatedUser.into(),
                RouteManagerError::IncompatibelVehicle(_) => RMResult::IncompatibleVehicle.into(),
                RouteManagerError::UnhandledDatabaseError(_)
                | RouteManagerError::UnknownVehicle(_)
                | RouteManagerError::InvalidRoute => RMResult::UnknownError.into(),
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

fn log_route_manager_error_and_convert_to_message<T>(err: RouteManagerError) -> T
where
    T: From<RouteManagerError>,
{
    match err {
        RouteManagerError::UnhandledDatabaseError(_) => event!(Level::ERROR, %err),
        _ => event!(Level::DEBUG, %err),
    };
    err.into()
}

#[tonic::async_trait]
impl RouteManagerService for RouteManager {
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
}

impl From<_Route> for RouteReply {
    fn from(route: _Route) -> Self {
        Self {
            events: route
                .1
                .into_iter()
                .map(|event| EventMessage {
                    location: event.location,
                })
                .collect(),
            route_id: route.0,
        }
    }
}
