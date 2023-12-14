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

pub struct AssignedRoute {
    pub route: DriverRoute,
    pub step: i32,
}

pub async fn retrieve_assigned_route(
    conn: Connection<'_>,
    name: &str,
) -> Result<Option<AssignedRoute>> {
    let mut route_events = sqlx::query!(
        "
        SELECT de.id, de.current_step, ev.location, ev.step FROM
        driver dr, delivery de, event ev
        WHERE dr.id = de.id
        AND de.id = ev.del_id
        AND dr.name = $1
        ORDER BY ev.step
        ",
        name
    )
    .fetch_all(conn.as_mut())
    .await?
    .into_iter()
    .peekable();
    let Some(mut route) = route_events.peek().map(|row| AssignedRoute {
        route: DriverRoute {
            id: row.id,
            events: vec![],
        },
        step: row.current_step,
    }) else {
        return Ok(None);
    };
    route.route.events = route_events.map(|row| Event::new(row.location)).collect();
    Ok(Some(route))
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
        AND de.name is null
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

#[derive(Debug, Copy, Clone)]
pub struct RouteStatus {
    pub route_id: i32,
    pub current_step: i32,
    pub total_steps: i32,
}

impl RouteStatus {
    fn try_new(
        route_id: Option<i32>,
        current_step: Option<i32>,
        total_steps: Option<i32>,
    ) -> Option<Self> {
        Some(RouteStatus {
            route_id: route_id?,
            current_step: current_step?,
            total_steps: total_steps?,
        })
    }
}

pub async fn get_assigned_route_status(
    conn: Connection<'_>,
    driver: &str,
) -> Result<Option<RouteStatus>> {
    let route_status = sqlx::query!(
        r#"
        SELECT delivery.id as "route_id?", delivery.current_step as "current_step?", COUNT(*) as total_steps
        FROM driver LEFT JOIN (
            SELECT id, current_step
            FROM event
            JOIN delivery ON event.del_id=delivery.id
            ) as delivery on driver.id = delivery.id
        WHERE driver.name = $1
        GROUP BY delivery.id, delivery.current_step;
        "#,
        driver
    )
    .fetch_one(conn.as_mut())
    .await?;
    Ok(RouteStatus::try_new(
        route_status.route_id,
        route_status.current_step,
        route_status.total_steps.map(|steps| steps as i32),
    ))
}

pub async fn update_status(
    conn: Connection<'_>,
    route_id: i32,
    step: i32,
) -> Result<PgQueryResult> {
    sqlx::query!(
        "
        UPDATE delivery
        SET current_step = $1
        WHERE id = $2
        ",
        step,
        route_id
    )
    .execute(conn.as_mut())
    .await
}
