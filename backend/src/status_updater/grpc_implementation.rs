pub mod grpc_status_updater {
    tonic::include_proto!("status_updater");
}

use grpc_status_updater::{
    driver_updater_server::DriverUpdater, StatusUpdateRequest, StatusUpdateResponse,
};
use tonic::async_trait;

use super::StatusUpdater;

#[async_trait]
impl DriverUpdater for StatusUpdater {
    async fn update_status(
        &self,
        request: tonic::Request<StatusUpdateRequest>,
    ) -> std::result::Result<tonic::Response<StatusUpdateResponse>, tonic::Status> {
        todo!()
    }
}
