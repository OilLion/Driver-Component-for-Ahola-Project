#!/bin/sh

rustup target add armv7-unknown-linux-gnueabi
cargo build --release --target aarch64-unknown-linux-musl
./run_database.sh

docker build

docker stop driver_database

docker-compose up -d
