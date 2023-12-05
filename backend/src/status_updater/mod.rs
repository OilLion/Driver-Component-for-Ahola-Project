use crate::sql::UpdateMessage;
use crate::types::LoginTokens;
use sqlx::{Acquire, PgConnection, Pool, Postgres};
use tokio::task::{JoinError, JoinSet};
use tonic::Request;
use tracing::{event, Level};
use uuid::Uuid;

pub mod grpc_implementation;

use crate::sql;
use grpc_implementation::PlanningUpdaterClient;

use self::grpc_implementation::grpc_status_updater::PlanningUpdate;

/// The 'StatusUpdater' has the responisbility for receiving status updates
/// from the drivers. In every status update it recieves, it sends a message
/// to the `PlanningClient`, which is responible for sending the update to
/// planning.
pub struct StatusUpdater {
    login_tokens: LoginTokens,
    database: Pool<Postgres>,
    messages: tokio::sync::mpsc::Sender<UpdateMessage>,
}

/// The 'PlanningClient' is responsible for sending status updates to planning.
pub struct PlanningClient {
    database: Pool<Postgres>,
    messages: tokio::sync::mpsc::Receiver<UpdateMessage>,
    service_url: &'static str,
}

impl PlanningClient {
    /// Creates a new `PlanningClient` with the given database connection pool,
    /// receiver for messages from the `StatusUpdater` and the url of the
    /// Planning grpc server.
    fn new(
        database: Pool<Postgres>,
        messages: tokio::sync::mpsc::Receiver<UpdateMessage>,
        service_url: String,
    ) -> Self {
        let service_url = service_url.leak();
        Self {
            database,
            messages,
            service_url,
        }
    }
    /// Runs the `PlanningClient`
    /// When it receives a message from the `StatusUpdater`, it spawns a task which
    /// establishes a connection to the planning server and sends the message.
    /// Also awaits the results of the tasks it has spawned. If a task failed to send the update
    /// to planning, the update is buffered in the database.
    pub async fn run(mut self) -> Result<(), sqlx::Error> {
        let mut updates: JoinSet<Result<(), UpdateMessage>> = JoinSet::new();
        loop {
            tokio::select! {
                Some(message) = self.messages.recv() => {
                    let task = update_planning(message, self.service_url);
                    updates.spawn(task);
                },
                Some(join_result) = updates.join_next(), if !updates.is_empty() => {
                    let mut conn = self.database.acquire().await?;
                    Self::handle_join_result(conn.as_mut(), join_result).await
                },
                else => break,
            }
        }
        Ok(())
    }

    async fn handle_join_result<'a>(
        conn: &'_ mut PgConnection,
        join_result: Result<Result<(), UpdateMessage>, JoinError>,
    ) {
        match join_result {
            Ok(Ok(_)) => (),
            Ok(Err(message)) => {
                if let Err(error) = crate::sql::mark_unsent(conn, message).await {
                    event!(Level::ERROR, %error)
                }
            }
            Err(join_error) => {
                event!(Level::ERROR, %join_error, "unable to join update_planning task");
            }
        }
    }
}

/// creates a `StatusUpdater` and a `PlanningClient` with a channel connecting them
/// of the given capacity.
pub fn create_status_updater_and_client(
    database: Pool<Postgres>,
    login_tokens: LoginTokens,
    capacity: usize,
    service_url: String,
) -> (StatusUpdater, PlanningClient) {
    let (send, rec) = tokio::sync::mpsc::channel(capacity);
    (
        StatusUpdater::new(database.clone(), login_tokens, send),
        PlanningClient::new(database, rec, service_url),
    )
}

/// Sends a message to the `PlanningClient` to update the status of the route.
async fn update_planning(
    message: UpdateMessage,
    service_url: &'static str,
) -> Result<(), UpdateMessage> {
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
        .map_err(|err| handle_error(&err))
        .map(|_| ())
}

impl StatusUpdater {
    fn new(
        database: Pool<Postgres>,
        login_tokens: LoginTokens,
        messages: tokio::sync::mpsc::Sender<UpdateMessage>,
    ) -> Self {
        Self {
            login_tokens,
            database,
            messages,
        }
    }
    async fn update_status(&self, token_id: &[u8], step: i32) -> Result<bool, crate::error::Error> {
        let token_id =
            Uuid::from_slice(token_id).map_err(|_| crate::error::Error::MalformedTokenId)?;
        let driver = self
            .login_tokens
            .get_token(&token_id)
            .ok_or(crate::error::Error::UnauthenticatedUser)?;
        let mut conn = self.database.acquire().await?;
        let (done, route_id) = update_status(conn.as_mut(), &driver.user, step).await?;
        if done {
            sql::delete_route(conn.as_mut(), route_id).await?;
        }
        if let Err(error) = self.messages.try_send(UpdateMessage { route_id, step }) {
            let mut conn = self.database.acquire().await?;
            match error {
                tokio::sync::mpsc::error::TrySendError::Full(message) => {
                    event!(Level::DEBUG, %error);
                    sql::mark_unsent(conn.as_mut(), message).await?;
                }
                tokio::sync::mpsc::error::TrySendError::Closed(message) => {
                    event!(Level::ERROR, %error);
                    sql::mark_unsent(conn.as_mut(), message).await?;
                }
            }
        }
        Ok(done)
    }
}

async fn update_status<'a>(
    conn: &mut PgConnection,
    driver: &str,
    step: i32,
) -> Result<(bool, i32), crate::error::Error> {
    let (id, current_step, total_steps) = {
        let update_meta = sql::get_assigned_route_status(conn.as_mut(), driver, step).await?;
        (
            update_meta
                .route_id
                .ok_or(crate::error::Error::DriverNotAssigned(driver.into()))?,
            update_meta
                .current_step
                .ok_or(crate::error::Error::DriverNotAssigned(driver.into()))?,
            update_meta
                .total_steps
                .ok_or(crate::error::Error::DriverNotAssigned(driver.into()))? as i32,
        )
    };
    if step > total_steps {
        Err(crate::error::Error::RouteUpdateExceedsEventCount(
            step,
            total_steps,
        ))
    } else if current_step <= step {
        sql::update_status(conn.as_mut(), id, step).await?;
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
    use crate::constants::{PLANNING_SOCKET, PLANNING_URL};
    use crate::test_utils;
    use crate::test_utils::generate_test_user_and_vehicle;

    #[tokio::test]
    async fn test_update_status() {
        let pool = test_utils::get_database_pool().await;
        let mut tx = pool.begin().await.unwrap();
        let (user, vehicle) = generate_test_user_and_vehicle(tx.as_mut()).await;
        let route = test_utils::generate_route(vehicle, 10);
        let route_id = crate::sql::insert_route(tx.as_mut(), &route).await.unwrap();
        crate::sql::assign_driver_to_route(tx.as_mut(), &user, route_id)
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

    #[tokio::test]
    async fn test_mark_outstanding() {
        use crate::sql::{mark_unsent, retrieve_unsent};
        let pool = test_utils::get_database_pool().await;
        let mut tx = pool.begin().await.unwrap();
        let (_, test_vehicle) = test_utils::generate_test_user_and_vehicle(tx.as_mut()).await;
        let route = test_utils::generate_route(test_vehicle, 10);
        let route_id = crate::sql::insert_route(tx.as_mut(), &route).await.unwrap();
        let message = UpdateMessage { route_id, step: 3 };
        mark_unsent(tx.as_mut(), message).await.unwrap();
        let mut unsent = retrieve_unsent(tx.as_mut()).await.unwrap().into_iter();
        assert_eq!(unsent.next().unwrap(), message);
        // increasing step works:
        let message = UpdateMessage { route_id, step: 5 };
        mark_unsent(tx.as_mut(), message).await.unwrap();
        let mut unsent = retrieve_unsent(tx.as_mut()).await.unwrap().into_iter();
        assert_eq!(unsent.next().unwrap(), message);
        // decreasing does not affect it:
        let message = UpdateMessage { route_id, step: 2 };
        mark_unsent(tx.as_mut(), message).await.unwrap();
        let mut unsent = retrieve_unsent(tx.as_mut()).await.unwrap().into_iter();
        assert_eq!(unsent.next().unwrap().step, 5);
    }

    #[tokio::test]
    async fn test_sending_update() {
        use grpc_implementation::grpc_status_updater::planning_updater_server::PlanningUpdaterServer;
        use grpc_implementation::updater_server_planning::PlanningUpdaterTester;
        let (send, mut rec) = tokio::sync::mpsc::channel(1024);
        let planning_server = PlanningUpdaterTester { channel: send };
        let server = tonic::transport::Server::builder()
            .add_service(PlanningUpdaterServer::new(planning_server))
            .serve(PLANNING_SOCKET);
        tokio::spawn(server);
        let message = UpdateMessage {
            route_id: 42,
            step: 4,
        };
        // message arrives at planning with correct id and step
        update_planning(message, PLANNING_URL).await.unwrap();
        if let Some(update) = rec.recv().await {
            assert_eq!((update.id, update.step), (message.route_id, message.step));
        }
        let return_message = update_planning(message, "http:://localhost:888")
            .await
            .unwrap_err();
        assert_eq!(message, return_message);
    }
}
