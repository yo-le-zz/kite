use anyhow::Result;
use colored::Colorize;

use kite::project::Project;

pub fn run() -> Result<()> {
    let project = Project::discover(&std::env::current_dir()?)?;
    let build_dir = project.build_dir();

    if build_dir.exists() {
        std::fs::remove_dir_all(&build_dir)?;
        println!("{:>12} {}", "Removed".green().bold(), build_dir.display());
    } else {
        println!("{:>12} nothing to clean", "Clean".green().bold());
    }

    Ok(())
}
