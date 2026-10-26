use anyhow::{bail, Context, Result};
use colored::Colorize;
use std::path::{Path, PathBuf};

use kite::project::{Manifest, MAIN_FILE, MANIFEST_FILE, SOURCE_DIR};

const DEFAULT_MAIN: &str = "make main():\n    print(\"Hello, Kite!\")\n";

pub fn run(name: Option<String>) -> Result<()> {
    let (project_dir, package_name, creating_new_dir) = match name {
        Some(name) => {
            let project_dir = PathBuf::from(&name);
            // The package name is the directory's own name, not
            // whatever path the user typed to get there -- `kite init
            // /tmp/foo` and `kite init ../nested/foo` should both name
            // the package `foo`, exactly like `kite init` with no
            // argument names it after the current directory below.
            // Using the raw path string here would be wrong even for a
            // same-directory relative name like `sub/foo`, and
            // actively breaks the build for an absolute path: joining
            // an absolute path onto `target/` (see
            // `Project::output_binary_path`) replaces the whole thing
            // instead of appending, so the compiled binary's output
            // path collides with the project directory itself.
            let package_name = project_dir
                .file_name()
                .map(|n| n.to_string_lossy().to_string())
                .unwrap_or(name);
            (project_dir, package_name, true)
        }
        None => {
            let cwd = std::env::current_dir().context("failed to read current directory")?;
            let name = cwd
                .file_name()
                .map(|n| n.to_string_lossy().to_string())
                .unwrap_or_else(|| "kite_project".to_string());
            (cwd, name, false)
        }
    };

    if creating_new_dir {
        if project_dir.exists() {
            bail!(
                "destination `{}` already exists; choose a different name or `cd` into it and rerun without one",
                project_dir.display()
            );
        }
        std::fs::create_dir_all(&project_dir)
            .with_context(|| format!("failed to create directory {}", project_dir.display()))?;
    }

    let manifest_path = project_dir.join(MANIFEST_FILE);
    if manifest_path.exists() {
        bail!(
            "`{}` already exists in `{}` -- this is already a Kite project",
            MANIFEST_FILE,
            project_dir.display()
        );
    }

    scaffold(&project_dir, &package_name)?;

    println!(
        "{:>12} {} package `{}`",
        "Created".green().bold(),
        if creating_new_dir { "new" } else { "" },
        package_name
    );
    if creating_new_dir {
        println!("       cd {} && kite build", project_dir.display());
    } else {
        println!("       kite build");
    }

    Ok(())
}

fn scaffold(project_dir: &Path, package_name: &str) -> Result<()> {
    let manifest = Manifest::new(package_name);
    std::fs::write(project_dir.join(MANIFEST_FILE), manifest.to_toml_string()?)
        .with_context(|| "failed to write kite.toml")?;

    let src_dir = project_dir.join(SOURCE_DIR);
    std::fs::create_dir_all(&src_dir)
        .with_context(|| format!("failed to create {}", src_dir.display()))?;

    let main_path = src_dir.join(MAIN_FILE);
    std::fs::write(&main_path, DEFAULT_MAIN)
        .with_context(|| format!("failed to write {}", main_path.display()))?;

    let gitignore_path = project_dir.join(".gitignore");
    if !gitignore_path.exists() {
        std::fs::write(&gitignore_path, "/target\n/.kite-cache\n")?;
    }

    Ok(())
}
