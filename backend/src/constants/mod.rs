use std::{net::Ipv4Addr, time::Duration};

pub mod database_error_codes {
    pub const DATABASE_UNIQUE_CONSTRAINT_VIOLATED: &str = "23505";
}

pub const DATABASE_URL: &str = "postgresql://Driver:1234@localhost/Drivers";
pub const DEFAULT_ADDRESS: Ipv4Addr = Ipv4Addr::UNSPECIFIED;
pub const DEFAULT_PORT: u16 = 4269;
pub const DEFAULT_LOGIN_DURATION: Duration = Duration::from_secs(86400);
