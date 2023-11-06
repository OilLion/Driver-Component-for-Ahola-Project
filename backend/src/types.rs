use std::time::Instant;
use uuid::Uuid;

pub mod routes;

pub struct Driver {
    pub username: String,
    pub password: String,
}

impl Driver {
    pub fn new(username: impl Into<String>, password: impl Into<String>) -> Self {
        Self {
            username: username.into(),
            password: password.into(),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LoginToken {
    pub id: Uuid,
    pub user: String,
    pub expiration: Instant,
}

impl LoginToken {
    pub fn new(user: String, expiration: Instant) -> Self {
        Self {
            id: Uuid::new_v4(),
            user,
            expiration,
        }
    }
}

#[derive(Clone, Debug)]
pub struct LoginTokens(std::sync::Arc<dashmap::DashMap<uuid::Uuid, LoginToken>>);

impl LoginTokens {
    pub fn new() -> Self {
        Self(std::sync::Arc::new(dashmap::DashMap::new()))
    }
    pub fn contains_token(&self, token_key: &Uuid) -> bool {
        self.0.contains_key(token_key)
    }
    pub fn insert_token(&self, key: Uuid, token: LoginToken) -> Option<LoginToken> {
        self.0.insert(key, token)
    }
    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }
}
