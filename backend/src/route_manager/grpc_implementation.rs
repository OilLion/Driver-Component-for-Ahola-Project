pub mod grpc_route_manager {
    tonic::include_proto!("route_manager");
}
use grpc_route_manager::route_manager_server::RouteManager as RouteManagerService;

// import type definitions from proto
#[rustfmt::skip]
use grpc_route_manager::{
    Event as EventMessage,
    Route as RouteMessage,
    AddRouteResponse as AddRouteResponseMessage, 
    AddRouteResult, 
    RoutesReply,
    RouteReply,
    GetRoutesRequest,
    GetRouteResult
};
use tonic::{Request, Response};
use tracing::{event, instrument, Level};
use uuid::Uuid;

use crate::types::routes::{Event, Route};

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

impl From<RouteManagerError> for AddRouteResponseMessage {
    fn from(error: RouteManagerError) -> Self {
        Self {
            result: match error {
                RouteManagerError::InvalidRoute => AddRouteResult::InvalidRoute.into(),
                RouteManagerError::UnknownVehicle(_) => AddRouteResult::UnknownVehicle.into(),
                RouteManagerError::UnhandledDatabaseError(_) => {
                    AddRouteResult::AddUnknownError.into()
                }
                RouteManagerError::UnauthenticatedUser => AddRouteResult::AddUnknownError.into(),
            },
            route_id: -1,
        }
    }
}

impl From<RouteManagerError> for RoutesReply {
    fn from(error: RouteManagerError) -> Self {
        Self {
            result: match error {
                RouteManagerError::UnauthenticatedUser => {
                    GetRouteResult::UnauthenticatedUser.into()
                }
                _ => GetRouteResult::GetUnknownError.into(),
            },
            routes: Vec::new(),
        }
    }
}

impl From<i32> for AddRouteResponseMessage {
    fn from(route_id: i32) -> Self {
        event!(Level::INFO, route_id);
        Self {
            result: AddRouteResult::AddSuccess.into(),
            route_id,
        }
    }
}

fn log_route_manager_error_and_convert_to_message<T>(err: RouteManagerError) -> T
where
    T: From<RouteManagerError>,
{
    match err {
        RouteManagerError::InvalidRoute
        | RouteManagerError::UnknownVehicle(_)
        | RouteManagerError::UnauthenticatedUser => event!(Level::DEBUG, %err),
        RouteManagerError::UnhandledDatabaseError(_) => event!(Level::ERROR, %err),
    };
    err.into()
}

#[tonic::async_trait]
impl RouteManagerService for RouteManager {
    #[instrument]
    async fn add_route(
        &self,
        route_request: tonic::Request<RouteMessage>,
    ) -> Result<Response<AddRouteResponseMessage>, tonic::Status> {
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
                        result: GetRouteResult::GetSuccss.into(),
                        routes: routes.map(|route| route.into()).collect(),
                    },
                )
            } else {
                RoutesReply {
                    result: GetRouteResult::MalformedLoginToken.into(),
                    routes: Vec::new(),
                }
            },
        ))
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
