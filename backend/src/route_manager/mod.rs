use std::collections::BTreeMap;

pub mod grpc_implementation;

use sqlx::{error::DatabaseError, postgres::PgArguments, query::Query, Acquire, Pool, Postgres};
use uuid::Uuid;

use crate::{
    constants::database_error_codes::DATABASE_FOREIGN_KEY_VIOLATION,
    error::Error,
    types::{
        routes::{Event, Route},
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
        if route.events.len() < 2 {
            return Err(Error::InvalidRoute);
        }
        let route_id = Self::add_route_helper(&self.database, route).await?;
        Ok(route_id)
    }

    async fn add_route_helper(
        conn: impl Acquire<'_, Database = Postgres> + Send,
        route: Route,
    ) -> Result<i32, Error> {
        let mut conn = conn.acquire().await?;
        if route.events.len() < 2 {
            return Err(Error::InvalidRoute);
        }
        // insert a new route and retreive the id
        let route_id = sqlx::query!(
            "INSERT INTO DELIVERY (veh_name)
                            VALUES ($1)
                            RETURNING id",
            route.vehicle
        )
        .fetch_one(conn.as_mut())
        .await
        .map_err(|error| match error {
            sqlx::Error::Database(error)
                if Self::check_error(
                    error.as_ref(),
                    DATABASE_FOREIGN_KEY_VIOLATION,
                    "fk_delivery_associati_vehicle",
                ) =>
            {
                Error::UnknownVehicle(route.vehicle.clone())
            }
            err => err.into(),
        })?
        .id;
        let event_insert_queries = Self::route_event_insert_queries(&route_id, route.events.iter());
        for insert in event_insert_queries {
            insert.execute(conn.as_mut()).await?;
        }
        Ok(route_id)
    }

    fn route_event_insert_queries<'a>(
        route_id: &'a i32,
        events: impl Iterator<Item = &'a Event>,
    ) -> impl Iterator<Item = Query<'a, Postgres, PgArguments>> {
        events.zip(0i32..).map(|(event, index)| {
            sqlx::query!(
                "INSERT INTO EVENT (Del_id, location, step)
                    VALUES ($1, $2, $3)",
                *route_id,
                event.location,
                index
            )
        })
    }

    async fn get_routes(&self, token_id: Uuid) -> Result<impl Iterator<Item = _Route> + '_, Error> {
        Self::get_route_helper(&self.database, &self.login_tokens, &token_id).await
    }

    async fn get_route_helper(
        conn: impl Acquire<'_, Database = Postgres>,
        login_tokens: &LoginTokens,
        token_id: &Uuid,
    ) -> Result<impl Iterator<Item = _Route>, Error> {
        let login_token = login_tokens
            .get_token(&token_id)
            .ok_or(Error::UnauthenticatedUser)?;
        let user_name = login_token.user.as_str();
        let values = Self::retrieve_routes_for_user(conn, user_name).await?;
        Ok(values.into_values())
    }

    async fn retrieve_routes_for_user<'a, A>(
        connection: A,
        user: &str,
    ) -> Result<BTreeMap<i32, _Route>, sqlx::Error>
    where
        A: Acquire<'a, Database = Postgres>,
    {
        let mut connection = connection.acquire().await?;
        let mut routes: BTreeMap<i32, _Route> = BTreeMap::new();
        sqlx::query!(
            "
                        SELECT de.id, ev.location, ev.step FROM
                            driver dr, delivery de, event ev
                            WHERE dr.name = $1
                            AND   dr.veh_name = de.veh_name
                            AND   de.id = ev.del_id
                            ORDER BY de.id, ev.step
                    ",
            user
        )
        .fetch_all(&mut *connection)
        .await?
        .into_iter()
        .for_each(|event| {
            routes
                .entry(event.id)
                .or_insert(_Route(event.id, vec![]))
                .1
                .push(Event {
                    location: event.location,
                });
        });
        Ok(routes)
    }

    async fn select_route(&self, token_id: &Uuid, route_id: i32) -> Result<bool, Error> {
        Self::select_route_helper(&self.database, &self.login_tokens, token_id, route_id).await?;
        Ok(true)
    }

    async fn select_route_helper(
        conn: impl Acquire<'_, Database = Postgres>,
        login_tokens: &LoginTokens,
        token_id: &Uuid,
        route_id: i32,
    ) -> Result<bool, Error> {
        let mut conn = conn.acquire().await?;
        let mut conn = conn.begin().await?;
        let token = login_tokens
            .get_token(token_id)
            .ok_or(Error::UnauthenticatedUser)?;
        let name = token.user.as_str();
        let route = sqlx::query!(
            "
                SELECT veh_name, name FROM delivery
                where id=$1
            ",
            route_id
        )
        .fetch_one(&mut *conn)
        .await
        .map_err(|error| match error {
            sqlx::Error::RowNotFound => Error::UnknownRoute(route_id),
            err => err.into(),
        })?;
        if route.name.is_some() {
            return Err(Error::RouteAlreadyAssigned(route_id));
        }
        let driver = sqlx::query!(
            "
                SELECT veh_name, id FROM driver
                where name=$1
            ",
            name
        )
        .fetch_one(&mut *conn)
        .await?;
        if driver.id.is_some() {
            return Err(Error::DriverAlreadyAssigned(name.into()));
        }
        if driver.veh_name != route.veh_name {
            return Err(Error::IncompatibelVehicle(route.veh_name.into()));
        }
        sqlx::query!(
            "
                UPDATE driver
                SET id = $1
                WHERE driver.name= $2
            ",
            route_id,
            name
        )
        .execute(conn.as_mut())
        .await?;
        sqlx::query!(
            "
                UPDATE delivery
                SET name=$1
                WHERE id=$2
            ",
            name,
            route_id
        )
        .execute(conn.as_mut())
        .await?;
        conn.commit().await?;
        Ok(true)
    }

    fn check_error(error: &dyn DatabaseError, code: &str, constraint: &str) -> bool {
        error.code().is_some_and(|error_code| error_code == code)
            && error
                .constraint()
                .is_some_and(|error_constraint| error_constraint == constraint)
    }
}

#[derive(Debug)]
struct _Route(i32, Vec<Event>);

#[cfg(test)]
mod route_manager_tests {
    use sqlx::{postgres::PgPoolOptions, Acquire, Transaction};
    use std::time::{Duration, Instant};

    use crate::{
        constants::DATABASE_URL,
        types::{routes::Event, LoginToken},
    };
    use uuid::Uuid;

    use super::*;

    #[tokio::test]
    async fn select_route() {
        let (pool, _, tokens) = setup().await;
        let mut tx = pool.begin().await.unwrap();
        let (username, vehicle) = generate_test_user_and_vehicle(tx.as_mut()).await;
        let route = generate_route(vehicle, 3);
        let route_id = RouteManager::add_route_helper(tx.as_mut(), route)
            .await
            .unwrap();
        let token_id = add_user_to_tokens(&tokens, username.clone());
        RouteManager::select_route_helper(tx.as_mut(), &tokens, &token_id, route_id)
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

    fn add_user_to_tokens(tokens: &LoginTokens, name: String) -> Uuid {
        let login_token = LoginToken::new(name, Instant::now() + Duration::from_secs(100));
        let id = login_token.id;
        tokens.insert_token(login_token.id, login_token);
        id
    }

    #[tokio::test]
    async fn select_route_bad_vehicle_assigned() {
        let (pool, _, tokens) = setup().await;
        let mut tx = pool.begin().await.unwrap();
        let (username, _) = generate_test_user_and_vehicle(tx.as_mut()).await;
        let (_, control_vehicle) = generate_test_user_and_vehicle(tx.as_mut()).await;
        let route = generate_route(control_vehicle.clone(), 3);
        let route_id = RouteManager::add_route_helper(tx.as_mut(), route)
            .await
            .unwrap();
        let token_id = add_user_to_tokens(&tokens, username.clone());
        let result =
            RouteManager::select_route_helper(tx.as_mut(), &tokens, &token_id, route_id).await;
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
        let (pool, route_manager, tokens) = setup().await;
        let mut tx = pool.begin().await.unwrap();
        let (username, vehicle) = generate_test_user_and_vehicle(tx.as_mut()).await;
        let login_token =
            LoginToken::new(username.clone(), Instant::now() + Duration::from_secs(100));
        tokens.insert_token(login_token.id, login_token.clone());
        let inserted_routes = generate_test_routes(&mut tx, vehicle.as_str(), 100, 12).await;
        let retrieved_routes = RouteManager::get_route_helper(&mut tx, &tokens, &login_token.id)
            .await
            .unwrap();
        for (retrieved, inserted) in retrieved_routes.zip(inserted_routes) {
            assert_eq!(retrieved.1, inserted.events)
        }
        tx.rollback().await.unwrap();
    }

    /// Generates a test user and a test vehicle and puts them into the database
    /// returns (user, vehicle)
    async fn generate_test_user_and_vehicle(
        conn: impl Acquire<'_, Database = Postgres>,
    ) -> (String, String) {
        let user = Uuid::new_v4().to_string();
        let vehicle = Uuid::new_v4().to_string();
        let mut conn = conn.acquire().await.unwrap();
        sqlx::query!(
            "
                INSERT INTO vehicle (name)
                VALUES ($1)
            ",
            vehicle
        )
        .execute(&mut *conn)
        // .execute(&pool)
        .await
        .unwrap();
        sqlx::query!(
            "
                INSERT INTO driver (name, veh_name, password)
                VALUES ($1, $2, '123');
            ",
            user,
            vehicle,
        )
        // .execute(&pool)
        .execute(&mut *conn)
        .await
        .unwrap();
        (user, vehicle)
    }

    async fn setup() -> (Pool<Postgres>, RouteManager, LoginTokens) {
        let tokens = LoginTokens::new();
        let pool = get_database_pool().await;
        let rout_manager = RouteManager::new(pool.clone(), tokens.clone());
        (pool, rout_manager, tokens)
    }

    async fn get_database_pool() -> Pool<Postgres> {
        PgPoolOptions::new()
            .max_connections(5)
            .connect(DATABASE_URL)
            .await
            .unwrap()
    }

    async fn generate_test_routes(
        connection: &mut Transaction<'_, Postgres>,
        // connection: &Pool<Postgres>,
        vehicle: &str,
        route_count: usize,
        event_count: usize,
    ) -> Vec<Route> {
        let routes: Vec<_> = (0..route_count)
            .map(|_| generate_route(vehicle.into(), event_count))
            .collect();
        for route in &routes {
            let route_id = sqlx::query!(
                "INSERT INTO DELIVERY (veh_name)
                            VALUES ($1)
                            RETURNING id",
                route.vehicle
            )
            .fetch_one(connection.as_mut())
            // .fetch_one(connection)
            .await
            .unwrap()
            .id;
            let event_insert_queries =
                RouteManager::route_event_insert_queries(&route_id, route.events.iter());
            for insert_query in event_insert_queries {
                insert_query.execute(connection.as_mut()).await.unwrap();
            }
        }
        routes
    }

    fn generate_route(vehicle: String, event_count: usize) -> Route {
        let events = (0..event_count)
            .map(|_| Event {
                location: Uuid::new_v4().to_string(),
            })
            .collect();
        Route { events, vehicle }
    }
}
