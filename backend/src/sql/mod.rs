use crate::types::routes::Route;
use sqlx::PgConnection;

/// Inserts a `[Route]` into the database and returns the assigned id
pub async fn insert_route(conn: &mut PgConnection, route: &Route) -> Result<i32, sqlx::Error> {
    sqlx::query!(
        "INSERT INTO DELIVERY (veh_name)
                        VALUES ($1)
                        RETURNING id",
        route.vehicle,
    )
    .fetch_one(conn.as_mut())
    .await
    .map(|id| id.id)
}
