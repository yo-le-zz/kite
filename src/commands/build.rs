use anyhow::{Context, Result};
use colored::Colorize;
use std::time::Instant;

use kite::driver;
use kite::project::Project;

/// Runs the build pipeline and returns the path to the produced executable
/// on success, so `kite run` can reuse this without duplicating logic.
pub fn run(target: Option<String>, release: bool) -> Result<std::path::PathBuf> {
    let project = Project::discover(&std::env::current_dir()?)?;

    println!(
        "{:>12} {} v{} ({})",
        "Compiling".green().bold(),
        project.manifest.package.name,
        project.manifest.package.version,
        project.root.display()
    );

    let source_path = project.main_source_path();
    let source = std::fs::read_to_string(&source_path).with_context(|| {
        format!(
            "failed to read `{}` -- does this project have a `src/main.ki`?",
            source_path.display()
        )
    })?;

    let opt_level = if release {
        3
    } else {
        project.manifest.build.opt_level
    };
    let target = target.or_else(|| project.manifest.build.target.clone());
    let output_path = project.output_binary_path();

    let start = Instant::now();
    let filename = source_path.to_string_lossy().to_string();
    driver::build_executable(
        &filename,
        &source,
        &output_path,
        opt_level,
        target.as_deref(),
    )?;
    let elapsed = start.elapsed();

    println!(
        "{:>12} {} target(s) in {:.2}s",
        "Finished".green().bold(),
        if release {
            "release [optimized]"
        } else {
            "dev [unoptimized]"
        },
        elapsed.as_secs_f32()
    );

    Ok(output_path)
}
