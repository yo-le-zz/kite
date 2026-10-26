//! `kite` -- the command-line entry point for the Kite compiler and
//! project manager. This binary is intentionally thin: argument parsing
//! lives in [`cli`], command logic lives in [`commands`], and all
//! compiler internals live in the `kite` library crate (`src/lib.rs`).

mod cli;
mod commands;

use clap::Parser;
use cli::{Cli, Command};
use colored::Colorize;

fn main() {
    let cli = Cli::parse();

    let result = match cli.command {
        Command::Init { name } => commands::init::run(name),
        Command::Build {
            target,
            release,
            quiet,
            freestanding,
            lib,
            r#static,
            output,
            out_dir,
            link,
        } => {
            if freestanding && lib {
                Err(anyhow::anyhow!(
                    "--freestanding and --lib are mutually exclusive"
                ))
            } else {
                let mode = if freestanding {
                    commands::build::Mode::Freestanding
                } else if lib {
                    commands::build::Mode::Lib
                } else {
                    commands::build::Mode::Executable {
                        static_link: r#static,
                        extra_link_inputs: link,
                    }
                };
                commands::build::run(target, release, quiet, mode, output, out_dir).map(|_| ())
            }
        }
        Command::Run {
            target,
            release,
            quiet,
        } => commands::run::run(target, release, quiet),
        Command::Check { quiet } => commands::check::run(quiet),
        Command::Clean => commands::clean::run(),
        Command::Add { package } => commands::package::add(&package),
        Command::Remove { package } => commands::package::remove(&package),
        Command::Update => commands::package::update(),
        Command::Bench { runs, target } => commands::bench::run(runs, target),
    };

    if let Err(err) = result {
        eprintln!("{} {:#}", "error:".red().bold(), err);
        std::process::exit(1);
    }
}
