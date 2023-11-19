pub mod grpc_status_updater {
    tonic::include_proto!("status_updater");
}

use grpc_status_updater::{
    driver_updater_server::DriverUpdater, StatusUpdateRequest, StatusUpdateResponse,
};

pub use grpc_status_updater::planning_updater_client::PlanningUpdaterClient;
use tonic::{async_trait, Response};

use super::StatusUpdater;

#[async_trait]
impl DriverUpdater for StatusUpdater {
    async fn update_status(
        &self,
        request: tonic::Request<StatusUpdateRequest>,
    ) -> std::result::Result<Response<StatusUpdateResponse>, tonic::Status> {
        let StatusUpdateRequest { uuid, step } = request.into_inner();
        Ok(Response::new(StatusUpdateResponse {
            done: self.update_status(&uuid, step).await?,
        }))
    }
}

pub mod updater_server_planning {
    use tonic::{async_trait, Response, Status};

    use super::grpc_status_updater::{
        planning_updater_server::PlanningUpdater, PlanningResponse, PlanningUpdate,
    };

    pub struct PlanningUpdaterTester {
        pub channel: tokio::sync::mpsc::Sender<PlanningUpdate>,
    }

    #[async_trait]
    impl PlanningUpdater for PlanningUpdaterTester {
        async fn status_update(
            &self,
            request: tonic::Request<PlanningUpdate>,
        ) -> std::result::Result<Response<PlanningResponse>, Status> {
            self.channel.try_send(request.into_inner()).unwrap();
            Ok(Response::new(PlanningResponse {}))
        }
    }
}
