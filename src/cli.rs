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
        /// Suppress "Compiling"/"Finished" progress output
        #[arg(long, short = 'q')]
        quiet: bool,
        /// Compile to a relocatable object file (`.o`) instead of a
        /// linked executable, with no dependency on a hosted C runtime:
        /// no `_start`/libc requirement, and `main` is emitted as an
        /// ordinary function rather than the hosted `int main()` entry
        /// point (a `make main():` isn't even required). Meant for
        /// embedding Kite code into another C/kernel/OS build -- link
        /// the resulting `.o` the same way you'd link any other
        /// freestanding object file, providing your own implementations
        /// of whatever libc functions your code actually calls (e.g.
        /// `printf`/`malloc` if you use `print`/lists).
        #[arg(long)]
        freestanding: bool,
        /// Compile to a relocatable object file (`.o`) meant to be
        /// called *from* C in a normal hosted environment (unlike
        /// `--freestanding`, this assumes libc is available -- `print`,
        /// lists, etc. all work normally). No `make main():` is
        /// required. Also writes a `<name>.h` C header declaring every
        /// non-`extern` function, so C code can call into it directly.
        /// See `docs/c-interop.md`.
        #[arg(long)]
        lib: bool,
        /// Statically link the resulting executable (passes `-static`
        /// to clang), so it has no dynamic library dependencies at
        /// runtime. Ignored with `--freestanding`/`--lib` (those never
        /// link at all).
        #[arg(long)]
        r#static: bool,
        /// Write the build output to this exact path instead of the
        /// default `target/<package-name>[.o]`
        #[arg(long, short = 'o')]
        output: Option<std::path::PathBuf>,
        /// Write build output into this directory instead of `target/`
        /// (ignored if `--output` is also given)
        #[arg(long)]
        out_dir: Option<std::path::PathBuf>,
        /// Additional object file, static library, or C/C++ source file
        /// to link in alongside the compiled Kite code -- this is how a
        /// full Kite program calls into C: declare the C functions with
        /// `extern make ...`, then pass their implementation here (e.g.
        /// `--link helpers.c` or `--link libhelpers.a`). Repeatable.
        /// Ignored with `--freestanding`/`--lib` (those don't link).
        #[arg(long = "link")]
        link: Vec<std::path::PathBuf>,
    },
    /// Compile and immediately run the current project
    Run {
        #[arg(long)]
        target: Option<String>,
        #[arg(long)]
        release: bool,
        /// Suppress "Compiling"/"Finished"/"Running" progress output --
        /// only the program's own stdout/stderr is shown
        #[arg(long, short = 'q')]
        quiet: bool,
    },
    /// Type-check the current project without producing an executable
    Check {
        /// Suppress "Checking"/"Checked" progress output (errors still print)
        #[arg(long, short = 'q')]
        quiet: bool,
    },
    /// Remove build artifacts
    Clean,
    /// Compile once (always optimized) and run the resulting binary
    /// several times to measure wall-clock execution time, in isolation
    /// from compilation. Reports min/max/average over the run.
    Bench {
        /// Number of times to run the compiled binary
        #[arg(long, default_value_t = 20)]
        runs: u32,
        #[arg(long)]
        target: Option<String>,
    },
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
