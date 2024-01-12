/// This binary is a simply dummy client, which receives status updates from planning and
/// prints them to standard out. It repurposes the `PlannungUpdaterTester` service orginally
/// created for internally testing the sending of satus updates.
use backend::status_updater::grpc_implementation::grpc_status_updater::planning_updater_server::PlanningUpdaterServer;
use backend::status_updater::grpc_implementation::grpc_status_updater::PlanningUpdate;
use backend::status_updater::grpc_implementation::updater_server_planning::PlanningUpdaterTester;
use clap::Parser;
use std::net::Ipv4Addr;

const DEFAULT_PORT: u16 = 8273;
const DEFAULT_ADDRESS: Ipv4Addr = std::net::Ipv4Addr::UNSPECIFIED;

#[derive(Parser)]
pub struct Args {
    /// The IP-Address the server should be configured to.
    /// Defaults to 0.0.0.0
    #[arg(short, long, value_name = "IP_ADDRESS")]
    ip_address: Option<Ipv4Addr>,
    /// The socket the server should listen on.
    /// Defaults to 8273
    #[arg(short, long, value_name = "Port")]
    port: Option<u16>,
}

impl Args {
    pub fn address(&self) -> std::net::SocketAddr {
        std::net::SocketAddrV4::new(
            self.ip_address.unwrap_or(DEFAULT_ADDRESS),
            self.port.unwrap_or(DEFAULT_PORT),
        )
        .into()
    }
}

#[tokio::main]
async fn main() {
    let args = Args::parse();
    let (send, mut rec) = tokio::sync::mpsc::channel(1024);

    let server = PlanningUpdaterTester { channel: send };
    tokio::spawn(
        tonic::transport::Server::builder()
            .add_service(PlanningUpdaterServer::new(server))
            .serve(args.address()),
    );
    while let Some(update) = rec.recv().await {
        let PlanningUpdate { id, step } = update;
        println!("Route id: {}, Step: {}", id, step)
    }
}
