use sqlx::{Acquire, Pool, Postgres};
use thiserror::Error;

use crate::types::LoginTokens;

#[derive(Error, Debug)]
enum StatusUpdaterError {}

pub struct StatusUpdater {
    login_tokens: LoginTokens,
    database: Pool<Postgres>,
}

async fn update_status<'a>(
    conn: impl Acquire<'a, Database = Postgres>,
    driver: &str,
    step: i32,
) -> Result<bool, crate::error::Error> {
    let mut conn = conn.acquire().await?;
    let (id, current_step, total_steps) = {
        let delivery = sqlx::query!(
            r#"
                SELECT delivery.id as "id?", delivery.current_step, COUNT(*) as step_count
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
        (
            delivery
                .id
                .ok_or(crate::error::Error::DriverNotAssigned(driver.into()))?,
            delivery
                .current_step
                .ok_or(crate::error::Error::DriverNotAssigned(driver.into()))?,
            delivery
                .step_count
                .ok_or(crate::error::Error::DriverNotAssigned(driver.into()))? as i32,
        )
    };
    if step > total_steps {
        Err(crate::error::Error::RouteUpdateExceedsEventCount(
            step,
            total_steps,
        ))
    } else if current_step <= step {
        sqlx::query!(
            "
                UPDATE delivery
                SET current_step = $1
                WHERE id = $2
            ",
            step,
            id
        )
        .execute(conn.as_mut())
        .await?;
        Ok(step == total_steps)
    } else {
        Err(crate::error::Error::RouteUpdateSmallerThanCurrent(
            step,
            current_step,
        ))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::test_utils;
    use crate::{route_manager::RouteManager, test_utils::generate_test_user_and_vehicle};

    #[tokio::test]
    async fn test_update_status() {
        let pool = test_utils::get_database_pool().await;
        let mut tx = pool.begin().await.unwrap();
        let (user, vehicle) = generate_test_user_and_vehicle(tx.as_mut()).await;
        let route = test_utils::generate_route(vehicle, 10);
        let route_id = RouteManager::add_route_helper(tx.as_mut(), route)
            .await
            .unwrap();
        RouteManager::select_route_helper(tx.as_mut(), &user, route_id)
            .await
            .unwrap();
        // updating status forward works
        assert!(update_status(tx.as_mut(), &user, 2)
            .await
            .is_ok_and(|done| done == false));
        assert!(update_status(tx.as_mut(), &user, 3)
            .await
            .is_ok_and(|done| done == false));
        // even when skipping numbers
        assert!(update_status(tx.as_mut(), &user, 6)
            .await
            .is_ok_and(|done| done == false));
        // or with repeats
        assert!(update_status(tx.as_mut(), &user, 6)
            .await
            .is_ok_and(|done| done == false));
        // going back is no good though
        let result = update_status(tx.as_mut(), &user, 3).await;
        assert!(matches!(
            result,
            Err(crate::error::Error::RouteUpdateSmallerThanCurrent(3, 6)),
        ));
        // so is exceeding the number of
        let result = update_status(tx.as_mut(), &user, 11).await;
        assert!(matches!(
            result,
            Err(crate::error::Error::RouteUpdateExceedsEventCount(11, 10)),
        ));
        // final update returns true
        assert!(update_status(tx.as_mut(), &user, 10)
            .await
            .is_ok_and(|done| done));
        tx.rollback().await.unwrap();
    }
}
