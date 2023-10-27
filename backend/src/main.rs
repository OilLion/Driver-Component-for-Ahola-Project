use backend::{
    args::{Args, Parser},
    types::LoginTokens,
    user_manager::{grpc_user_manager::user_manager_server::UserManagerServer, UserManager},
};

use sqlx::postgres::PgPoolOptions;

#[tokio::main]
async fn main() {
    let args = Args::parse();
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(args.database_url())
        .await
        .unwrap();
    let tokens = LoginTokens::new();
    let user_manager = UserManager::new(pool.clone(), tokens.clone(), args.login_duration());
    tonic::transport::Server::builder()
        .add_service(UserManagerServer::new(user_manager))
        .serve(args.address())
        .await
        .unwrap();
}
