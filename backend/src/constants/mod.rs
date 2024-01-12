use std::{
    net::{Ipv4Addr, SocketAddr, SocketAddrV4},
    time::Duration,
};

pub mod database_error_codes {
    pub const DATABASE_UNIQUE_CONSTRAINT_VIOLATED: &str = "23505";
    pub const DATABASE_FOREIGN_KEY_VIOLATION: &str = "23503";
    pub const FOREIGN_KEY_CONSTRAINT_DRIVER_VEHICLE: &str = "fk_driver_associati_vehicle";
}

pub const DATABASE_URL: &str = "postgresql://Driver:1234@localhost/Drivers";
pub const PLANNING_URL: &str = "http://localhost:4423";
pub const PLANNING_SOCKET: SocketAddr =
    SocketAddr::V4(SocketAddrV4::new(std::net::Ipv4Addr::LOCALHOST, 4423));
pub const DEFAULT_ADDRESS: Ipv4Addr = Ipv4Addr::UNSPECIFIED;
pub const DEFAULT_PORT: u16 = 4269;
pub const DEFAULT_LOGIN_DURATION: Duration = Duration::from_secs(86400);
