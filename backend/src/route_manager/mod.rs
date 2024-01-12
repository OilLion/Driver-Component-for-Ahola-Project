use sqlx::{Acquire, PgConnection, Pool, Postgres};
use uuid::Uuid;

use crate::sql::AssignedRoute;
use crate::{
    error::{violates_fk_constraint, Error},
    sql,
    sql::{
        assign_driver_to_route, get_driver_info, get_route, insert_route, retrieve_routes_for_user,
    },
    types::{
        routes::{DriverRoute, Route},
        LoginTokens,
    },
};

pub mod grpc_implementation;

/// The `RouteManager` is responsible for handling routes.
/// It can add new routes to the database and retrieve routes based on a drivers specific vehicle,
/// as well as assign a driver to a route.
#[derive(Debug)]
pub struct RouteManager {
    database: Pool<Postgres>,
    login_tokens: LoginTokens,
}

impl RouteManager {
    /// Creates a new `RouteManager` with the given database connection pool and `LoginTokens` map.
    pub fn new(database: Pool<Postgres>, login_tokens: LoginTokens) -> Self {
        Self {
            database,
            login_tokens,
        }
    }
    /// Adds the `route` to the database and returns the id of the route, as assigned by the database.
    /// Delegates to [`add_route_helper`](Self::add_route_helper) for the actual insertion.
    /// # Errors
    /// Returns:
    /// - [`Error::InvalidRoute`] if the given `route` has less than 2 events.
    /// - [`Error::UnknownVehicle`] if the given `route` has a vehicle that is
    ///     not registered in the database.
    /// - [`Error::UnhandledDatabaseError`] if any other database error occurs.
    async fn add_route(&self, route: Route) -> Result<i32, Error> {
        let mut conn = self.database.acquire().await?;
        let route_id = Self::add_route_helper(&mut conn, route).await?;
        Ok(route_id)
    }

    async fn add_route_helper(conn: &mut PgConnection, route: Route) -> Result<i32, Error> {
        if route.events.len() < 2 {
            return Err(Error::InvalidRoute);
        }
        insert_route(conn.as_mut(), &route).await.map_err(|error| {
            if violates_fk_constraint(&error, Some("fk_delivery_associati_vehicle")) {
                Error::UnknownVehicle(route.vehicle.clone())
            } else {
                error.into()
            }
        })
    }

    /// Retrieves all routes for the driver associated with the given `token_id`.
    /// Only routes with the same vehicle as the driver are returned.
    /// Delegate to [`get_route_helper`](Self::get_route_helper) for the actual retrieval.
    /// # Errors
    /// Returns:
    /// - [`Error::UnauthenticatedUser`] if the given `token_id` is not associated with a driver.
    /// - [`Error::UnhandledDatabaseError`] if any other database error occurs.
    async fn get_routes(&self, token_id: Uuid) -> Result<impl Iterator<Item = DriverRoute>, Error> {
        let mut conn = self.database.acquire().await?;
        Self::get_route_helper(conn.as_mut(), &self.login_tokens, &token_id).await
    }

    async fn get_route_helper(
        conn: &mut PgConnection,
        login_tokens: &LoginTokens,
        token_id: &Uuid,
    ) -> Result<impl Iterator<Item = DriverRoute>, Error> {
        let login_token = login_tokens
            .get_token(&token_id)
            .ok_or(Error::UnauthenticatedUser)?;
        let user_name = login_token.user.as_str();
        retrieve_routes_for_user(conn, user_name)
            .await
            .map_err(|err| err.into())
    }

    /// Assigns the driver associated with the given `token_id` to the route with the given `route_id`.
    /// Delegates to [`select_route_helper`](Self::select_route_helper) for the actual assignment.
    /// # Errors
    /// Returns:
    /// - [`Error::UnauthenticatedUser`] if the given `token_id` is not associated with a driver.
    /// - [`Error::UnknownRoute`] if the given `route_id` is not found in the database.
    /// - [`Error::RouteAlreadyAssigned`] if the given `route_id` is already assigned to a driver.
    /// - [`Error::DriverAlreadyAssigned`] if the driver associated with the given `token_id` is
    ///    already assigned to a route.
    /// - [`Error::IncompatibleVehicle`] if the vehicle of the driver associated with the given
    ///     `token_id` does not match the vehicle of the route with the given `route_id`.
    /// - [`Error::UnhandledDatabaseError`] if any other database error occurs.
    async fn select_route(&self, token_id: &Uuid, route_id: i32) -> Result<bool, Error> {
        let token = self
            .login_tokens
            .get_token(token_id)
            .ok_or(Error::UnauthenticatedUser)?;
        let name = token.user.as_str();
        let mut conn = self.database.acquire().await?;
        Self::select_route_helper(conn.as_mut(), &name, route_id).await?;
        Ok(true)
    }

    async fn select_route_helper(
        conn: &'_ mut PgConnection,
        name: &str,
        route_id: i32,
    ) -> Result<bool, Error> {
        let conn = conn.acquire().await?;
        let mut tx = conn.begin().await?;
        let route = get_route(tx.as_mut(), route_id)
            .await
            .map_err(|error| match error {
                sqlx::Error::RowNotFound => Error::UnknownRoute(route_id),
                err => err.into(),
            })?;
        if route.is_assigned() {
            return Err(Error::RouteAlreadyAssigned(route_id));
        }
        let driver_info = get_driver_info(tx.as_mut(), name).await?;
        if driver_info.is_assigned() {
            return Err(Error::DriverAlreadyAssigned(name.into()));
        }
        if driver_info.vehicle != route.vehicle {
            return Err(Error::IncompatibleVehicle(route.vehicle.into()));
        }
        assign_driver_to_route(tx.as_mut(), name, route_id).await?;
        tx.commit().await?;
        Ok(true)
    }

    /// Retrieves the route assigned to the driver associated with the given `token_id`.
    /// # Errors
    /// Returns:
    /// - [`Error::UnauthenticatedUser`] if the given `token_id` is not associated with a driver.
    /// - [`Error::DriverNotAssigned`] if the driver associated with the given `token_id` is not
    ///    assigned to a route.
    /// - [`Error::UnhandledDatabaseError`] if any other database error occurs.
    /// - [`Error::MalformedTokenId`] if the given `token_id` is not a valid [`Uuid`].
    async fn get_assigned_route(&self, token_id: &[u8]) -> Result<AssignedRoute, Error> {
        let token_id = Uuid::from_slice(token_id)?;
        let token = self
            .login_tokens
            .get_token(&token_id)
            .ok_or(Error::UnauthenticatedUser)?;
        let name = token.user.as_str();
        let mut conn = self.database.acquire().await?;
        sql::retrieve_assigned_route(conn.as_mut(), name)
            .await?
            .ok_or(Error::DriverNotAssigned(name.into()))
    }
}

#[cfg(test)]
mod route_manager_tests {
    use sqlx::Transaction;
    use std::time::{Duration, Instant};

    use crate::test_utils;

    use crate::types::{routes::Event, LoginToken};
    use uuid::Uuid;

    use super::*;

    #[tokio::test]
    async fn select_route() {
        let (pool, _, _) = setup().await;
        let mut tx = pool.begin().await.unwrap();
        let (username, vehicle) = test_utils::generate_test_user_and_vehicle(tx.as_mut()).await;
        let route = test_utils::generate_route(vehicle, 3);
        let route_id = RouteManager::add_route_helper(tx.as_mut(), route)
            .await
            .unwrap();
        RouteManager::select_route_helper(tx.as_mut(), &username, route_id)
            .await
            .unwrap();
        let route = get_route(tx.as_mut(), route_id).await.unwrap();
        let user = get_driver_info(tx.as_mut(), &username).await.unwrap();
        assert!(user.route.is_some_and(|id| id == route_id));
        assert!(route.driver.is_some_and(|name| name == username));
        tx.rollback().await.unwrap();
    }

    #[tokio::test]
    async fn select_route_bad_vehicle_assigned() {
        let (pool, _, _) = setup().await;
        let mut tx = pool.begin().await.unwrap();
        let (username, _) = test_utils::generate_test_user_and_vehicle(tx.as_mut()).await;
        let (_, control_vehicle) = test_utils::generate_test_user_and_vehicle(tx.as_mut()).await;
        let route = test_utils::generate_route(control_vehicle.clone(), 3);
        let route_id = RouteManager::add_route_helper(tx.as_mut(), route)
            .await
            .unwrap();
        let result = RouteManager::select_route_helper(tx.as_mut(), &username, route_id).await;
        assert!(
            result.is_err_and(|err| if let Error::IncompatibleVehicle(veh) = err {
                veh == control_vehicle
            } else {
                panic!("{}", err)
            })
        );
        let route = get_route(tx.as_mut(), route_id).await.unwrap();
        let user = get_driver_info(tx.as_mut(), &username).await.unwrap();
        assert!(!user.is_assigned());
        assert!(!route.is_assigned());
    }

    #[tokio::test]
    async fn add_basic_route() {
        let events: Vec<_> = ["Kokkola", "Helsinki"]
            .iter()
            .map(|location| Event {
                location: (*location).into(),
            })
            .collect();
        let vehicle = "Truck";
        test_adding_route_helper(events, vehicle.into())
            .await
            .unwrap();
    }

    #[tokio::test]
    async fn add_route_many_events() {
        let events: Vec<_> = (0..128)
            .map(|_| Uuid::new_v4().to_string())
            .map(|location| Event { location })
            .collect();
        let vehicle = "Van";
        test_adding_route_helper(events, vehicle.into())
            .await
            .unwrap();
    }

    #[tokio::test]
    async fn reject_route_with_no_events() {
        let vehicle = "Van";
        let route_result = test_adding_route_helper(vec![], vehicle.into()).await;
        assert!(route_result.is_err_and(|err| matches!(err, Error::InvalidRoute)));
    }

    #[tokio::test]
    async fn reject_route_with_one_event() {
        let vehicle = "Van";
        let route_result = test_adding_route_helper(
            vec![Event {
                location: "Hamburg".into(),
            }],
            vehicle.into(),
        )
        .await;
        assert!(route_result.is_err_and(|err| matches!(err, Error::InvalidRoute)));
    }

    #[tokio::test]
    async fn reject_route_with_unknown_vehicle() {
        let vehicle = "vehicle_not_in_database";
        let events: Vec<_> = ["Kokkola", "Helsinki"]
            .iter()
            .map(|location| Event {
                location: (*location).into(),
            })
            .collect();
        let route_result = test_adding_route_helper(events, vehicle.into()).await;
        assert!(route_result.is_err_and(|err| matches!(err, Error::UnknownVehicle(_))));
    }

    async fn test_adding_route_helper(events: Vec<Event>, vehicle: String) -> Result<i32, Error> {
        let (pool, route_manager, _) = setup().await;
        let route = Route::new(vehicle.clone(), events.clone());
        let route_id = route_manager.add_route(route).await?;
        let route_events = sqlx::query!(
            "SELECT * FROM
                        delivery inner JOIN event on delivery.id = event.del_id 
                        where id = $1",
            route_id
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        for ((db_event, index), control_event) in route_events.iter().zip(0i32..).zip(events) {
            assert_eq!(db_event.veh_name, vehicle);
            assert_eq!(db_event.location, control_event.location);
            assert_eq!(db_event.step, index);
            assert_eq!(db_event.name, None);
        }
        sqlx::query!("DELETE FROM event WHERE del_id=$1", route_id)
            .execute(&pool)
            .await?;
        sqlx::query!("DELETE FROM delivery WHERE id=$1", route_id)
            .execute(&pool)
            .await?;
        Ok(route_id)
    }

    #[tokio::test]
    async fn get_routes_not_authenticated() {
        let (_, route_manager, _) = setup().await;
        let get_route_result = route_manager.get_routes(Uuid::new_v4()).await;
        assert!(get_route_result.is_err_and(|err| matches!(err, Error::UnauthenticatedUser)));
    }

    #[tokio::test]
    async fn get_routes() {
        let (pool, _, tokens) = setup().await;
        let mut tx = pool.begin().await.unwrap();
        let (username, vehicle) = test_utils::generate_test_user_and_vehicle(tx.as_mut()).await;
        let login_token =
            LoginToken::new(username.clone(), Instant::now() + Duration::from_secs(100));
        tokens.insert_token(login_token.id, login_token.clone());
        let inserted_routes = generate_test_routes(&mut tx, vehicle.as_str(), 100, 12).await;
        let retrieved_routes = RouteManager::get_route_helper(&mut tx, &tokens, &login_token.id)
            .await
            .unwrap();
        for (retrieved, inserted) in retrieved_routes.zip(inserted_routes) {
            assert_eq!(retrieved.events, inserted.events)
        }
        tx.rollback().await.unwrap();
    }

    #[tokio::test]
    async fn get_assigned_route() {
        let (pool, _, _) = setup().await;
        let mut tx = pool.begin().await.unwrap();
        let (username, vehicle) = test_utils::generate_test_user_and_vehicle(tx.as_mut()).await;
        let route = test_utils::generate_route(vehicle.clone(), 3);
        let route_id = sql::insert_route(tx.as_mut(), &route).await.unwrap();
        sql::assign_driver_to_route(tx.as_mut(), &username, route_id)
            .await
            .unwrap();
        let assigned_route = sql::retrieve_assigned_route(tx.as_mut(), &username)
            .await
            .unwrap()
            .unwrap();
        assert_eq!(assigned_route.route.events, route.events);
        assert_eq!(assigned_route.route.id, route_id);
        assert_eq!(assigned_route.step, 1);
        tx.rollback().await.unwrap()
    }

    async fn setup() -> (Pool<Postgres>, RouteManager, LoginTokens) {
        let tokens = LoginTokens::new();
        let pool = test_utils::get_database_pool().await;
        let rout_manager = RouteManager::new(pool.clone(), tokens.clone());
        (pool, rout_manager, tokens)
    }

    async fn generate_test_routes(
        connection: &mut Transaction<'_, Postgres>,
        // connection: &Pool<Postgres>,
        vehicle: &str,
        route_count: usize,
        event_count: usize,
    ) -> Vec<Route> {
        let routes: Vec<_> = (0..route_count)
            .map(|_| test_utils::generate_route(vehicle.into(), event_count))
            .collect();
        for route in &routes {
            insert_route(connection.as_mut(), &route).await.unwrap();
        }
        routes
    }
}
