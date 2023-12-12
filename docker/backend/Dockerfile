FROM lukemathwalker/cargo-chef:latest-rust-1 AS chef

FROM chef AS planner
COPY ../../backend .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
RUN mkdir build_dir 
WORKDIR ./build_dir/
COPY --from=planner /recipe.json recipe.json
## # Build dependencies - this is the caching Docker layer!
RUN cargo chef cook --release --recipe-path  recipe.json

RUN apt-get update && apt-get install -y protobuf-compiler

RUN mkdir /protos 
COPY ../../backend .
COPY ../../protos /protos

RUN mkdir /backend_binary
RUN cargo build --bin backend --release
RUN cargo build --bin status_update_client --release

FROM debian:bookworm-slim
# RUN apt-get update && apt-get install -y install libc6
COPY --from=builder /build_dir/target/release/backend .
COPY --from=builder /build_dir/target/release/status_update_client .

ENTRYPOINT ["./backend"]
 
