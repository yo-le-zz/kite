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
        Command::Build { target, release } => commands::build::run(target, release).map(|_| ()),
        Command::Run { target, release } => commands::run::run(target, release),
        Command::Check => commands::check::run(),
        Command::Clean => commands::clean::run(),
        Command::Add { package } => commands::package::add(&package),
        Command::Remove { package } => commands::package::remove(&package),
        Command::Update => commands::package::update(),
    };

    if let Err(err) = result {
        eprintln!("{} {:#}", "error:".red().bold(), err);
        std::process::exit(1);
    }
}
