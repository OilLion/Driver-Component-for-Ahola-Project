fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::compile_protos("../protos/user_manager.proto")?;
    Ok(())
}
