//! `kite add` / `kite remove` / `kite update` -- a Cargo-inspired package
//! manager.
//!
//! v0.1 has no package *registry* to talk to (and this sandbox's network
//! policy wouldn't let it reach one even if it existed), so these
//! commands manage the local bookkeeping a real resolver would sit on
//! top of: the `[dependencies]` table in `kite.toml`, a `kite.lock`
//! snapshot of resolved versions, and a local `.kite-cache/` directory
//! where downloaded package sources would land. Actually fetching and
//! compiling a dependency's sources isn't implemented yet.

use anyhow::{bail, Result};
use colored::Colorize;

use kite::project::{Lockfile, Project};

pub fn add(package_spec: &str) -> Result<()> {
    let mut project = Project::discover(&std::env::current_dir()?)?;
    let (name, version) = match package_spec.split_once('@') {
        Some((n, v)) => (n.to_string(), v.to_string()),
        None => (package_spec.to_string(), "*".to_string()),
    };
    if name.is_empty() {
        bail!("package name cannot be empty");
    }

    let already_present = project.manifest.dependencies.contains_key(&name);
    project
        .manifest
        .dependencies
        .insert(name.clone(), version.clone());
    project.manifest.save(&project.manifest_path())?;
    refresh_lockfile(&project)?;
    std::fs::create_dir_all(project.cache_dir())?;

    let verb = if already_present { "Updated" } else { "Added" };
    println!("{:>12} {name} = \"{version}\"", verb.green().bold());
    println!(
        "{:>12} v0.1 records dependencies in `kite.toml` but does not yet fetch or compile them",
        "Note".yellow().bold()
    );
    Ok(())
}

pub fn remove(package_name: &str) -> Result<()> {
    let mut project = Project::discover(&std::env::current_dir()?)?;
    if project.manifest.dependencies.remove(package_name).is_none() {
        bail!(
            "package `{package_name}` is not a dependency of `{}`",
            project.manifest.package.name
        );
    }
    project.manifest.save(&project.manifest_path())?;
    refresh_lockfile(&project)?;

    println!("{:>12} {package_name}", "Removed".green().bold());
    Ok(())
}

pub fn update() -> Result<()> {
    let project = Project::discover(&std::env::current_dir()?)?;
    refresh_lockfile(&project)?;

    if project.manifest.dependencies.is_empty() {
        println!("{:>12} no dependencies to update", "Update".green().bold());
    } else {
        for (name, version) in &project.manifest.dependencies {
            println!(
                "{:>12} {name} v{version} (up to date -- no registry configured)",
                "Checked".green().bold()
            );
        }
    }
    Ok(())
}

fn refresh_lockfile(project: &Project) -> Result<()> {
    let lock = Lockfile::from_manifest(&project.manifest);
    lock.save(&project.lock_path())?;
    Ok(())
}
