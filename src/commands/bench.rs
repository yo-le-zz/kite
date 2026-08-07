//! `kite bench` -- compiles the project once (always optimized, so the
//! measurement reflects `--release`-quality code), then runs the
//! resulting binary several times to measure *pure execution* wall-clock
//! time, in isolation from compilation/linking. This is what `time kite
//! run --release` conflates: that measures compiling, LLVM IR generation,
//! clang/linking, *and* execution as one number.

use anyhow::{Context, Result};
use colored::Colorize;
use std::process::Command;
use std::time::Instant;

use crate::commands::build;

pub fn run(runs: u32, target: Option<String>) -> Result<()> {
    if runs == 0 {
        anyhow::bail!("--runs must be at least 1");
    }

    // Always build in release mode for a benchmark, and quietly (the
    // compile step isn't part of what we're measuring).
    let binary = build::run(
        target,
        true,
        true,
        build::Mode::Executable {
            static_link: false,
            extra_link_inputs: Vec::new(),
        },
        None,
        None,
    )?;

    println!("{:>12} {}", "Benchmarking".green().bold(), binary.display());

    let mut durations = Vec::with_capacity(runs as usize);
    for i in 1..=runs {
        let start = Instant::now();
        let status = Command::new(&binary)
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .status()
            .with_context(|| format!("failed to execute `{}`", binary.display()))?;
        let elapsed = start.elapsed();

        if !status.success() {
            anyhow::bail!(
                "run {i}/{runs} exited with a non-zero status ({:?}) -- aborting benchmark",
                status.code()
            );
        }
        durations.push(elapsed);
    }

    let millis: Vec<f64> = durations.iter().map(|d| d.as_secs_f64() * 1000.0).collect();
    let sum: f64 = millis.iter().sum();
    let avg = sum / millis.len() as f64;
    let min = millis.iter().cloned().fold(f64::INFINITY, f64::min);
    let max = millis.iter().cloned().fold(f64::NEG_INFINITY, f64::max);
    let variance = millis.iter().map(|v| (v - avg).powi(2)).sum::<f64>() / millis.len() as f64;
    let stddev = variance.sqrt();

    println!();
    println!("{}", "Kite benchmark".bold());
    println!("{:>12} {}", "Runs:", runs);
    println!("{:>12} {:.3} ms", "Average:", avg);
    println!("{:>12} {:.3} ms", "Min:", min);
    println!("{:>12} {:.3} ms", "Max:", max);
    println!("{:>12} {:.3} ms", "Std dev:", stddev);

    Ok(())
}
