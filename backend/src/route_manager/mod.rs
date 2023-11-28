pub mod grpc_implementation;

use sqlx::{Acquire, PgConnection, Pool, Postgres};
use uuid::Uuid;

use crate::{
    constants::database_error_codes::DATABASE_FOREIGN_KEY_VIOLATION,
    error::{check_error, Error},
    sql::{
        assign_driver_to_route, get_driver_info, get_route, insert_route, retrieve_routes_for_user,
    },
    types::{
        routes::{DriverRoute, Event, Route},
        LoginTokens,
    },
};

#[derive(Debug)]
pub struct RouteManager {
    database: Pool<Postgres>,
    login_tokens: LoginTokens,
}

impl RouteManager {
    pub fn new(database: Pool<Postgres>, login_tokens: LoginTokens) -> Self {
        Self {
            database,
            login_tokens,
        }
    }
    async fn add_route(&self, route: Route) -> Result<i32, Error> {
        let mut conn = self.database.acquire().await?;
        let route_id = Self::add_route_helper(&mut conn, route).await?;
        Ok(route_id)
    }

    pub(super) async fn add_route_helper(
        conn: &mut PgConnection,
        route: Route,
    ) -> Result<i32, Error> {
        if route.events.len() < 2 {
            Err(Error::InvalidRoute)
        } else {
            insert_route(conn.as_mut(), &route).await.map_err(|error| {
                if check_error(
                    &error,
                    DATABASE_FOREIGN_KEY_VIOLATION,
                    "fk_delivery_associati_vehicle",
                ) {
                    Error::UnknownVehicle(route.vehicle.clone())
                } else {
                    error.into()
                }
            })
        }
    }

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

    pub(super) async fn select_route_helper(
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
            return Err(Error::IncompatibelVehicle(route.vehicle.into()));
        }
        assign_driver_to_route(tx.as_mut(), name, route_id).await?;
        tx.commit().await?;
        Ok(true)
    }
}

#[derive(Debug)]
struct _Route(i32, Vec<Event>);

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
        let route = sqlx::query!(
            "
                SELECT * FROM delivery
                WHERE id = $1
            ",
            route_id
        )
        .fetch_one(tx.as_mut())
        .await
        .unwrap();
        let user = sqlx::query!(
            "
                SELECT * FROM driver
                WHERE name = $1
            ",
            username
        )
        .fetch_one(tx.as_mut())
        .await
        .unwrap();
        assert!(user.id.is_some_and(|id| id == route.id));
        assert!(route.name.is_some_and(|name| name == user.name));
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
            result.is_err_and(|err| if let Error::IncompatibelVehicle(veh) = err {
                veh == control_vehicle
            } else {
                panic!("{}", err)
            })
        );
        let route = sqlx::query!(
            "
                SELECT * FROM delivery
                WHERE id = $1
            ",
            route_id
        )
        .fetch_one(tx.as_mut())
        .await
        .unwrap();
        let user = sqlx::query!(
            "
                SELECT * FROM driver
                WHERE name = $1
            ",
            username
        )
        .fetch_one(tx.as_mut())
        .await
        .unwrap();
        assert!(user.id.is_none());
        assert!(route.name.is_none());
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
    async fn reject_rpute_with_unknown_vehicle() {
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
