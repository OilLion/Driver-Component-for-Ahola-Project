use crate::types::routes::Route;
use sqlx::PgConnection;

type Connection<'a> = &'a mut PgConnection;

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
