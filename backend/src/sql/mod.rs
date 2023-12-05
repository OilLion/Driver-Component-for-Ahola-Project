use crate::types::routes::{DriverRoute, Event, Route};
use sqlx::{postgres::PgQueryResult, PgConnection};

pub type Connection<'a> = &'a mut PgConnection;

type Result<T> = std::result::Result<T, sqlx::Error>;

/// Inserts a `[Route]` into the database and returns the assigned id
pub async fn insert_route(conn: &mut PgConnection, route: &Route) -> Result<i32> {
    let id = sqlx::query!(
        "INSERT INTO DELIVERY (veh_name)
                        VALUES ($1)
                        RETURNING id",
        route.vehicle,
    )
    .fetch_one(conn.as_mut())
    .await
    .map(|id| id.id)?;
    for query in {
        route.events.iter().zip(0i32..).map(|(event, index)| {
            sqlx::query!(
                "INSERT INTO EVENT (Del_id, location, step)
                    VALUES ($1, $2, $3)",
                id,
                event.location,
                index
            )
        })
    } {
        query.execute(conn.as_mut()).await?;
    }
    Ok(id)
}

pub async fn delete_route(conn: &mut PgConnection, id: i32) -> Result<PgQueryResult> {
    sqlx::query!("DELETE FROM EVENT WHERE Del_id = $1", id)
        .execute(conn.as_mut())
        .await?;
    sqlx::query!("DELETE FROM DELIVERY WHERE id = $1", id)
        .execute(conn.as_mut())
        .await
}

pub struct DbDelivery {
    pub vehicle: String,
    pub driver: Option<String>,
}

impl DbDelivery {
    pub fn is_assigned(&self) -> bool {
        self.driver.is_some()
    }
}

pub async fn get_route(conn: Connection<'_>, id: i32) -> Result<DbDelivery> {
    sqlx::query_as!(
        DbDelivery,
        " 
        SELECT veh_name as vehicle, name as driver 
        FROM delivery
        where id=$1
        ",
        id
    )
    .fetch_one(conn)
    .await
}

pub struct DbDriverInfo {
    pub vehicle: String,
    pub route: Option<i32>,
}

impl DbDriverInfo {
    pub fn is_assigned(&self) -> bool {
        self.route.is_some()
    }
}

pub async fn get_driver_info(conn: Connection<'_>, name: &str) -> Result<DbDriverInfo> {
    sqlx::query_as!(
        DbDriverInfo,
        "
        SELECT veh_name as vehicle, id as route
        FROM driver
        where name=$1
        ",
        name
    )
    .fetch_one(conn.as_mut())
    .await
}

pub async fn assign_driver_to_route(conn: Connection<'_>, name: &str, id: i32) -> Result<()> {
    sqlx::query!(
        "
        UPDATE driver
        SET id = $1
        WHERE driver.name= $2
        ",
        id,
        name,
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
        id
    )
    .execute(conn.as_mut())
    .await?;
    Ok(())
}

pub async fn retrieve_routes_for_user(
    connection: Connection<'_>,
    user: &str,
) -> Result<impl Iterator<Item = DriverRoute>> {
    use std::collections::BTreeMap;
    let mut routes: BTreeMap<i32, DriverRoute> = BTreeMap::new();
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
            .or_insert_with(|| DriverRoute::new(event.id))
            .events
            .push(Event {
                location: event.location,
            });
    });
    Ok(routes.into_values())
}

pub async fn insert_driver(
    conn: Connection<'_>,
    username: &str,
    password: &str,
    vehicle: &str,
) -> Result<PgQueryResult> {
    sqlx::query!(
        "
        INSERT INTO DRIVER (name, password, Veh_name)
        VALUES ($1, $2, $3)
        ",
        username,
        password,
        vehicle,
    )
    .execute(conn.as_mut())
    .await
}

pub async fn check_password(conn: Connection<'_>, username: &str, password: &str) -> Result<bool> {
    sqlx::query!(
        r#"
            SELECT password = $2 as "valid!"
            FROM DRIVER
            WHERE name = $1
        "#,
        username,
        password,
    )
    .fetch_one(conn.as_mut())
    .await
    .map(|row| row.valid)
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct UpdateMessage {
    pub route_id: i32,
    pub step: i32,
}

pub async fn mark_unsent(conn: Connection<'_>, update: UpdateMessage) -> Result<PgQueryResult> {
    sqlx::query!(
        "SELECT insert_or_update_outstanding_delivery($1, $2)",
        update.route_id,
        update.step
    )
    .execute(conn.as_mut())
    .await
}

pub async fn retrieve_unsent(conn: Connection<'_>) -> Result<Vec<UpdateMessage>>
where
{
    sqlx::query_as!(
        UpdateMessage,
        "
            SELECT id as route_id, current_step as step FROM outstandingupdates
        "
    )
    .fetch_all(conn.as_mut())
    .await
}
