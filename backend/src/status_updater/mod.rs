use std::sync::{mpsc::channel, Arc};

use crate::types::LoginTokens;
use anyhow::anyhow;
use sqlx::{Acquire, Pool, Postgres};
use thiserror::Error;
use tokio::task::JoinError;
use tonic::Request;
use tracing::{event, Level};
use uuid::Uuid;

pub mod grpc_implementation;

use grpc_implementation::PlanningUpdaterClient;

use self::grpc_implementation::grpc_status_updater::PlanningUpdate;

/// The 'StatusUpdater' has the responisbility for receiving status updates
/// from the drivers. In every status update it recieves, it sends a message
/// to the `PlanningClient`, which is responible for sending the update to
/// planning.
pub struct StatusUpdater {
    login_tokens: LoginTokens,
    database: Pool<Postgres>,
    messages: tokio::sync::mpsc::Sender<Message>,
}

pub struct PlanningClient {
    database: Pool<Postgres>,
    messages: tokio::sync::mpsc::Receiver<Message>,
    service_url: &'static str,
    updates: tokio::task::JoinSet<Result<(), Message>>,
}

impl PlanningClient {
    pub async fn run(mut self) {
        loop {
            tokio::select! {
                Some(message) = self.messages.recv() => {
                    let task = update_planning(message, self.service_url);
                    self.updates.spawn(task);
                }
                Some(join_result) = self.updates.join_next(), if !self.updates.is_empty() => {
                    Self::handle_join_result(&self.database, join_result).await
                }
                else => event!(Level::ERROR, "select failed")
            }
        }
    }

    async fn handle_join_result<'a>(
        conn: impl Acquire<'a, Database = Postgres>,
        join_result: Result<Result<(), Message>, JoinError>,
    ) {
        match join_result {
            Ok(Ok(_)) => (),
            Ok(Err(message)) => {
                if let Err(error) = mark_unsent(conn, message).await {
                    event!(Level::ERROR, %error)
                }
            }
            Err(join_error) => {
                event!(Level::ERROR, %join_error, "unable to join update_planning task");
            }
        }
    }
}

async fn update_planning(message: Message, service_url: &'static str) -> Result<(), Message> {
    let handle_error = |err: &dyn std::error::Error| {
        event!(
            Level::DEBUG,
            error = %err,
            "unable to connect to planning server for updates",
        );
        message
    };
    PlanningUpdaterClient::connect(service_url)
        .await
        .map_err(|err| handle_error(&err))?
        .status_update(Request::new(PlanningUpdate {
            id: message.route_id,
            step: message.step,
        }))
        .await
        .map_err(|err| handle_error(&err))?;
    Ok(())
}

async fn mark_unsent<'a>(
    conn: impl Acquire<'a, Database = Postgres>,
    message: Message,
) -> Result<(), sqlx::Error> {
    todo!()
}

#[derive(Debug, Clone, Copy)]
struct Message {
    route_id: i32,
    step: i32,
}

impl StatusUpdater {
    async fn update_status(&self, token_id: &[u8], step: i32) -> Result<bool, crate::error::Error> {
        let token_id =
            Uuid::from_slice(token_id).map_err(|_| crate::error::Error::MalformedTokenId)?;
        let driver = self
            .login_tokens
            .get_token(&token_id)
            .ok_or(crate::error::Error::UnauthenticatedUser)?;
        let (done, route_id) = update_status(&self.database, &driver.user, step).await?;
        if done {
            remove_route(&self.database, route_id).await?;
        }
        if let Err(error) = self.messages.try_send(Message { route_id, step }) {
            match error {
                tokio::sync::mpsc::error::TrySendError::Full(message) => {
                    event!(Level::DEBUG, %error);
                    mark_unsent(&self.database, message).await?;
                }
                tokio::sync::mpsc::error::TrySendError::Closed(message) => {
                    event!(Level::ERROR, %error);
                    mark_unsent(&self.database, message).await?;
                }
            }
        }
        Ok(done)
    }
}

async fn remove_route<'a>(
    conn: impl Acquire<'a, Database = Postgres>,
    route_id: i32,
) -> Result<(), sqlx::Error> {
    let mut conn = conn.acquire().await?;
    sqlx::query!(
        " 
            DELETE FROM delivery
            WHERE id=$1
        ",
        route_id
    )
    .execute(conn.as_mut())
    .await?;
    Ok(())
}

async fn update_status<'a>(
    conn: impl Acquire<'a, Database = Postgres>,
    driver: &str,
    step: i32,
) -> Result<(bool, i32), crate::error::Error> {
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
        Ok((step == total_steps, id))
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
            .is_ok_and(|done| done.0 == false));
        assert!(update_status(tx.as_mut(), &user, 3)
            .await
            .is_ok_and(|done| done.0 == false));
        // even when skipping numbers
        assert!(update_status(tx.as_mut(), &user, 6)
            .await
            .is_ok_and(|done| done.0 == false));
        // or with repeats
        assert!(update_status(tx.as_mut(), &user, 6)
            .await
            .is_ok_and(|done| done.0 == false));
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
            .is_ok_and(|done| done.0));
        tx.rollback().await.unwrap();
    }
}
