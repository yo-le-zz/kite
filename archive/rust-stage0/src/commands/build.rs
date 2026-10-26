use anyhow::Result;
use colored::Colorize;
use std::path::PathBuf;
use std::time::Instant;

use kite::driver;
use kite::project::{Project, SOURCE_DIR};

/// What kind of artifact this build should produce.
pub enum Mode {
    /// A normal, linked, runnable executable.
    Executable {
        static_link: bool,
        extra_link_inputs: Vec<PathBuf>,
    },
    /// A relocatable object file with no dependency on a hosted runtime
    /// (`kite build --freestanding`).
    Freestanding,
    /// A relocatable object file (plus a generated C header) meant to be
    /// called from C in a normal hosted environment (`kite build --lib`).
    Lib,
}

/// Runs the build pipeline and returns the path to the produced artifact
/// on success, so `kite run`/`kite bench` can reuse this without
/// duplicating logic.
#[allow(clippy::too_many_arguments)]
pub fn run(
    target: Option<String>,
    release: bool,
    quiet: bool,
    mode: Mode,
    output: Option<PathBuf>,
    out_dir: Option<PathBuf>,
) -> Result<PathBuf> {
    let project = Project::discover(&std::env::current_dir()?)?;

    let mode_label = match &mode {
        Mode::Executable { .. } => "",
        Mode::Freestanding => " [freestanding]",
        Mode::Lib => " [lib]",
    };
    if !quiet {
        println!(
            "{:>12} {} v{} ({}){}",
            "Compiling".green().bold(),
            project.manifest.package.name,
            project.manifest.package.version,
            project.root.display(),
            mode_label
        );
    }

    let entry_path = project.main_source_path();
    let src_root = project.root.join(SOURCE_DIR);

    let opt_level = if release {
        3
    } else {
        project.manifest.build.opt_level
    };
    let target = target.or_else(|| project.manifest.build.target.clone());

    let default_path = project.output_binary_path();
    let base_output_path = match (output, out_dir) {
        (Some(explicit), _) => explicit,
        (None, Some(dir)) => dir.join(default_path.file_name().expect("package name is non-empty")),
        (None, None) => default_path,
    };
    let mut output_path = match &mode {
        // The default (unexplicit) name gets `.exe` filled in on
        // Windows for an executable, `.o` for freestanding/lib -- an
        // explicit `-o out.bin` is always left alone. For the
        // executable case, this is only a *guess* pending confirmation
        // below: the authoritative answer is whatever
        // `driver::build_project` actually names the file on disk (see
        // `driver::normalized_executable_path`), which is what
        // `output_path` gets reassigned to right after the build call.
        Mode::Executable { .. } => base_output_path,
        Mode::Freestanding | Mode::Lib => {
            if base_output_path.extension().is_none() {
                base_output_path.with_extension("o")
            } else {
                base_output_path
            }
        }
    };

    let start = Instant::now();
    let mut header_path: Option<PathBuf> = None;
    match &mode {
        Mode::Executable {
            static_link,
            extra_link_inputs,
        } => {
            output_path = driver::build_project(
                &entry_path,
                &src_root,
                &output_path,
                opt_level,
                target.as_deref(),
                *static_link,
                extra_link_inputs,
            )?;
        }
        Mode::Freestanding => {
            driver::build_project_freestanding(
                &entry_path,
                &src_root,
                &output_path,
                opt_level,
                target.as_deref(),
            )?;
        }
        Mode::Lib => {
            header_path = Some(driver::build_project_lib(
                &entry_path,
                &src_root,
                &output_path,
                opt_level,
                target.as_deref(),
            )?);
        }
    }
    let elapsed = start.elapsed();

    if !quiet {
        let extra = match (&mode, &header_path) {
            (Mode::Freestanding, _) => {
                format!(" -> {} (object file, not linked)", output_path.display())
            }
            (Mode::Lib, Some(h)) => format!(
                " -> {} + {} (object file + C header)",
                output_path.display(),
                h.display()
            ),
            _ => String::new(),
        };
        println!(
            "{:>12} {} target(s) in {:.2}s{}",
            "Finished".green().bold(),
            if release {
                "release [optimized]"
            } else {
                "dev [unoptimized]"
            },
            elapsed.as_secs_f32(),
            extra
        );
    }

    Ok(output_path)
}
