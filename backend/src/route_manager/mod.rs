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
    AddRouteResult as AddRouteResultMessage, 
    Routes as RoutesMessage,
};
use sqlx::{error::DatabaseError, Pool, Postgres};

use crate::{
    constants::database_error_codes::DATABASE_FOREIGN_KEY_VIOLATION, types::routes::Route,
};

pub struct RouteManager {
    database: Pool<Postgres>,
}

impl RouteManager {
    pub fn new(database: Pool<Postgres>) -> Self {
        Self { database }
    }
    async fn add_route(&self, route: &Route) -> Result<AddRouteResult, sqlx::Error> {
        if route.events.len() < 2 {
            return Ok(AddRouteResult::InvlaidRoute);
        }
        let mut transaction = self.database.begin().await?;
        // insert a new route and retreive the id
        let add_route_result = sqlx::query!(
            "INSERT INTO DELIVERY (veh_name)
                            VALUES ($1)
                            RETURNING id",
            route.vehicle
        )
        .fetch_one(&mut *transaction)
        .await;
        match add_route_result {
            Ok(record) => {
                let route_id = record.id;
                let event_insert_queries = route.events.iter().zip(0i32..).map(|(event, index)| {
                    sqlx::query!(
                        "INSERT INTO EVENT (Del_id, location, step)
                    VALUES ($1, $2, $3)",
                        route_id,
                        event.location,
                        index
                    )
                });
                for insert in event_insert_queries {
                    insert.execute(&mut *transaction).await?;
                }
                transaction.commit().await?;
                Ok(AddRouteResult::Success(route_id))
            }
            Err(sqlx::Error::Database(error))
                if error
                    .code()
                    .is_some_and(|code| code == DATABASE_FOREIGN_KEY_VIOLATION)
                    && error
                        .constraint()
                        .is_some_and(|contraint| contraint == "fk_delivery_associati_vehicle") =>
            {
                Ok(AddRouteResult::UnknownVehicle(error))
            }
            Err(err) => Err(err),
        }
    }
}

#[derive(Debug)]
enum AddRouteResult {
    Success(i32),
    InvlaidRoute,
    UnknownVehicle(Box<dyn DatabaseError>),
}

#[cfg(test)]
mod route_manager_tests {
    use sqlx::postgres::PgPoolOptions;

    use crate::{constants::DATABASE_URL, types::routes::Event};
    use uuid::Uuid;

    use super::*;

    #[tokio::test]
    async fn add_basic_route() {
        let events: Vec<_> = ["Kokkola", "Helsinki"]
            .iter()
            .map(|location| Event {
                location: (*location).into(),
            })
            .collect();
        let vehicle = "Truck";
        match test_adding_route_helper(events, vehicle.into())
            .await
            .unwrap()
        {
            AddRouteResult::Success(_) => (),
            other => panic!("{:?}", other),
        }
    }

    #[tokio::test]
    async fn add_route_many_events() {
        let events: Vec<_> = (0..128)
            .map(|_| Uuid::new_v4().to_string())
            .map(|location| Event { location })
            .collect();
        let vehicle = "Van";
        match test_adding_route_helper(events, vehicle.into())
            .await
            .unwrap()
        {
            AddRouteResult::Success(_) => (),
            other => panic!("{:?}", other),
        }
    }

    #[tokio::test]
    async fn reject_route_with_no_events() {
        let vehicle = "Van";
        let route_result = test_adding_route_helper(vec![], vehicle.into())
            .await
            .unwrap();
        assert!(matches!(route_result, AddRouteResult::InvlaidRoute));
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
        .await
        .unwrap();
        assert!(matches!(route_result, AddRouteResult::InvlaidRoute));
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
        let route_result = test_adding_route_helper(events, vehicle.into())
            .await
            .unwrap();
        assert!(matches!(route_result, AddRouteResult::UnknownVehicle(_)))
    }

    async fn test_adding_route_helper(
        events: Vec<Event>,
        vehicle: String,
    ) -> Result<AddRouteResult, sqlx::Error> {
        let (pool, route_manager) = setup().await;
        let route = Route::new(vehicle.clone(), events.clone());
        match route_manager.add_route(&route).await? {
            AddRouteResult::Success(route_id) => {
                let route_events = sqlx::query!(
                    "SELECT * FROM
                        delivery inner JOIN event on delivery.id = event.del_id 
                        where id = $1",
                    route_id
                )
                .fetch_all(&pool)
                .await
                .unwrap();
                for ((db_event, index), control_event) in
                    route_events.iter().zip(0i32..).zip(events)
                {
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
                Ok(AddRouteResult::Success(route_id))
            }
            other => Ok(other),
        }
    }

    async fn setup() -> (Pool<Postgres>, RouteManager) {
        let pool = get_database_pool().await;
        let rout_manager = RouteManager::new(pool.clone());
        (pool, rout_manager)
    }

    async fn get_database_pool() -> Pool<Postgres> {
        PgPoolOptions::new()
            .max_connections(5)
            .connect(DATABASE_URL)
            .await
            .unwrap()
    }
}
