use std::{net::Ipv4Addr, time::Duration};

pub use clap::Parser;

use crate::constants::*;

#[derive(Parser)]
pub struct Args {
    /// The IP-Address the server should be configured to.
    /// Defaults to 0.0.0.0
    #[arg(short, long, value_name = "IP_ADDRESS")]
    ip_address: Option<Ipv4Addr>,
    /// The socket the server should listen on.
    /// Defaults to 4269
    #[arg(short, long, value_name = "Port")]
    port: Option<u16>,
    /// The login duration for drivers.
    /// Defaults to 68400s or 24h
    #[arg(short, long, value_name = "Duration in seconds")]
    login_duration: Option<u64>,
    /// URL for the postgres database.
    #[arg(short, long, value_name = "URL of the database")]
    database_url: Option<String>,
    /// URL of the planning server.
    planning_url: Option<String>,
}

impl Args {
    pub fn address(&self) -> std::net::SocketAddr {
        std::net::SocketAddrV4::new(
            self.ip_address.unwrap_or(DEFAULT_ADDRESS),
            self.port.unwrap_or(DEFAULT_PORT),
        )
        .into()
    }
    pub fn login_duration(&self) -> Duration {
        if let Some(duration) = self.login_duration {
            Duration::from_secs(duration)
        } else {
            DEFAULT_LOGIN_DURATION
        }
    }
    pub fn database_url(&self) -> &str {
        self.database_url
            .as_ref()
            .map(|url| url.as_str())
            .unwrap_or(crate::constants::DATABASE_URL)
    }
    pub fn planning_url(&self) -> &str {
        self.planning_url
            .as_ref()
            .map(|url| url.as_str())
            .unwrap_or(crate::constants::PLANNING_URL)
    }
}
