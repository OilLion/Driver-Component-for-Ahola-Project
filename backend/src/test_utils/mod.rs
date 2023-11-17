use sqlx::{postgres::PgPoolOptions, Acquire, Pool, Postgres};
use uuid::Uuid;

use crate::{
    constants::DATABASE_URL,
    types::{
        routes::{Event, Route},
        LoginTokens,
    },
};

pub async fn get_database_pool() -> Pool<Postgres> {
    PgPoolOptions::new()
        .max_connections(5)
        .connect(DATABASE_URL)
        .await
        .unwrap()
}

/// Generates a test user and a test vehicle and puts them into the database
/// returns (user, vehicle)
pub async fn generate_test_user_and_vehicle(
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

/// Generates a route with the specified vehicle and the amount of events
pub fn generate_route(vehicle: String, event_count: usize) -> Route {
    let events = (0..event_count)
        .map(|_| Event {
            location: Uuid::new_v4().to_string(),
        })
        .collect();
    Route { events, vehicle }
}
