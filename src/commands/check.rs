use anyhow::{bail, Context, Result};
use colored::Colorize;

use kite::driver::{self, CheckOutcome};
use kite::project::Project;

pub fn run() -> Result<()> {
    let project = Project::discover(&std::env::current_dir()?)?;

    println!(
        "{:>12} {} v{} ({})",
        "Checking".green().bold(),
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

    let filename = source_path.to_string_lossy().to_string();
    let (outcome, _) = driver::check_source(&filename, &source);
    match outcome {
        CheckOutcome::Ok => {
            println!("{:>12} no errors found", "Checked".green().bold());
            Ok(())
        }
        CheckOutcome::Errors => bail!("aborting due to previous error(s)"),
    }
}
