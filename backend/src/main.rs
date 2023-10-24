use sqlx::postgres::PgPoolOptions;

const DATABASE_URL: &str = "postgresql://Driver:1234@localhost/Drivers";

#[tokio::main]
async fn main() {
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(DATABASE_URL)
        .await
        .unwrap();
}
