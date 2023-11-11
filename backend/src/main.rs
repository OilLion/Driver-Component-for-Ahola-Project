use backend::{
    args::{Args, Parser},
    route_manager::{
        grpc_implementation::grpc_route_manager::route_manager_server::RouteManagerServer,
        RouteManager,
    },
    types::LoginTokens,
    user_manager::{grpc_user_manager::user_manager_server::UserManagerServer, UserManager},
};

use sqlx::postgres::PgPoolOptions;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt().init();
    let args = Args::parse();
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(args.database_url())
        .await
        .unwrap();
    let tokens = LoginTokens::new();
    let user_manager = UserManager::new(pool.clone(), tokens.clone(), args.login_duration());
    let route_manager = RouteManager::new(pool.clone(), tokens.clone());
    tonic::transport::Server::builder()
        .add_service(UserManagerServer::new(user_manager))
        .add_service(RouteManagerServer::new(route_manager))
        .serve(args.address())
        .await
        .unwrap();
}
