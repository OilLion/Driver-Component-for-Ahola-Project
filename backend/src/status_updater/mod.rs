use sqlx::{Pool, Postgres};
use thiserror::Error;

use crate::types::LoginTokens;

#[derive(Error, Debug)]
enum StatusUpdaterError {}

pub struct StatusUpdater {
    login_tokens: LoginTokens,
    database: Pool<Postgres>,
}

impl StatusUpdater {}
