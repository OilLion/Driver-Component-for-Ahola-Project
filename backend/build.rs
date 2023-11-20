fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::compile_protos("../protos/user_manager.proto")?;
    tonic_build::compile_protos("../protos/route_manager.proto")?;
    tonic_build::compile_protos("../protos/status_updater.proto")?;
    Ok(())
}
