use anyhow::{Context, Result};
use colored::Colorize;
use std::process::Command;

use crate::commands::build;

pub fn run(target: Option<String>, release: bool, quiet: bool) -> Result<()> {
    let binary = build::run(
        target,
        release,
        quiet,
        build::Mode::Executable {
            static_link: false,
            extra_link_inputs: Vec::new(),
        },
        None,
        None,
    )?;

    if !quiet {
        println!("{:>12} `{}`", "Running".green().bold(), binary.display());
    }

    let status = Command::new(&binary)
        .status()
        .with_context(|| format!("failed to execute `{}`", binary.display()))?;

    std::process::exit(status.code().unwrap_or(1));
}
