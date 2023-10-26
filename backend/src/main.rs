use sqlx::{postgres::PgPoolOptions, Pool, Postgres};

const DATABASE_URL: &str = "postgresql://Driver:1234@localhost/Drivers";

#[tokio::main]
async fn main() {
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(DATABASE_URL)
        .await
        .unwrap();

    let chris = Driver::new("Chris", "1234");
    create_driver(pool.clone(), &chris).await.unwrap();
}

async fn create_driver(
    pool: Pool<Postgres>,
    driver: &Driver,
) -> Result<sqlx::postgres::PgQueryResult, sqlx::Error> {
    sqlx::query!(
        "INSERT INTO DRIVER (name, password)
        VALUES ($1, $2)",
        driver.name,
        driver.password
    )
    .execute(&pool)
    .await
}

struct Driver {
    name: String,
    password: String,
}

impl Driver {
    pub fn new(name: impl Into<String>, password: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            password: password.into(),
        }
    }
}

struct UserManager {
    database: Pool<Postgres>,
}

impl UserManager {
    pub fn new(database: Pool<Postgres>) -> Self {
        Self { database }
    }
}
