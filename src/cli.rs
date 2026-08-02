//! Command-line interface surface for `kite`, defined declaratively with
//! `clap`. Keeping argument parsing in its own module (separate from
//! `commands/`, which contains the actual command *implementations*)
//! mirrors how Cargo separates its CLI shape from its command logic.

use clap::{Parser, Subcommand};

#[derive(Parser, Debug)]
#[command(
    name = "kite",
    version,
    about = "The Kite programming language compiler and project manager",
    long_about = "kite is the official compiler and build tool for the Kite \
programming language. It compiles `.ki` source files ahead-of-time to \
native executables via LLVM.",
    propagate_version = true
)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Command,
}

#[derive(Subcommand, Debug)]
pub enum Command {
    /// Create a new Kite project in the current directory
    Init {
        /// Name of the project. Defaults to the current directory's name.
        name: Option<String>,
    },
    /// Compile the current project into a native executable
    Build {
        /// Target triple to compile for, e.g. x86_64-unknown-linux-gnu
        #[arg(long)]
        target: Option<String>,
        /// Build with optimizations enabled (equivalent to opt-level 3)
        #[arg(long)]
        release: bool,
    },
    /// Compile and immediately run the current project
    Run {
        #[arg(long)]
        target: Option<String>,
        #[arg(long)]
        release: bool,
    },
    /// Type-check the current project without producing an executable
    Check,
    /// Remove build artifacts
    Clean,
    /// Add a dependency to `kite.toml`
    Add {
        /// Package name, optionally with an `@version` suffix (e.g. `http@1.2.0`)
        package: String,
    },
    /// Remove a dependency from `kite.toml`
    Remove { package: String },
    /// Re-resolve dependency versions and refresh `kite.lock`
    Update,
}
