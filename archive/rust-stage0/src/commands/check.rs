use anyhow::{bail, Result};
use colored::Colorize;

use kite::driver::{self, CheckOutcome};
use kite::project::{Project, SOURCE_DIR};

pub fn run(quiet: bool) -> Result<()> {
    let project = Project::discover(&std::env::current_dir()?)?;

    if !quiet {
        println!(
            "{:>12} {} v{} ({})",
            "Checking".green().bold(),
            project.manifest.package.name,
            project.manifest.package.version,
            project.root.display()
        );
    }

    let entry_path = project.main_source_path();
    let src_root = project.root.join(SOURCE_DIR);
    if !entry_path.is_file() {
        bail!(
            "`{}` not found -- does this project have a `src/main.ki`?",
            entry_path.display()
        );
    }

    let (outcome, _) = driver::check_project(&entry_path, &src_root);
    match outcome {
        CheckOutcome::Ok => {
            if !quiet {
                println!("{:>12} no errors found", "Checked".green().bold());
            }
            Ok(())
        }
        CheckOutcome::Errors => bail!("aborting due to previous error(s)"),
    }
}
