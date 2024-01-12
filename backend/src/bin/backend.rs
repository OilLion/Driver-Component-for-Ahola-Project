use backend::user_manager::grpc_implementation::UserManagerServer;

use backend::{
    args::{Args, Parser},
    route_manager::{
        grpc_implementation::grpc_route_manager::route_manager_server::RouteManagerServer,
        RouteManager,
    },
    status_updater::{
        create_status_updater_and_client,
        grpc_implementation::grpc_status_updater::driver_updater_server::DriverUpdaterServer,
    },
    types::LoginTokens,
    user_manager::UserManager,
};

use sqlx::postgres::PgPoolOptions;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt().pretty().init();
    let args = Args::parse();
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(args.database_url())
        .await
        .unwrap();
    let tokens = LoginTokens::new();
    let user_manager = UserManager::new(pool.clone(), tokens.clone(), args.login_duration());
    let route_manager = RouteManager::new(pool.clone(), tokens.clone());
    let (status_updater, status_planning_client) = create_status_updater_and_client(
        pool.clone(),
        tokens.clone(),
        1024,
        args.planning_url().into(),
    );
    tokio::spawn(status_planning_client.run());
    tonic::transport::Server::builder()
        .add_service(UserManagerServer::new(user_manager))
        .add_service(RouteManagerServer::new(route_manager))
        .add_service(DriverUpdaterServer::new(status_updater))
        .serve(args.address())
        .await
        .unwrap();
}
