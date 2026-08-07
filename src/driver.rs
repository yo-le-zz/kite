//! The compiler driver: wires the pipeline stages together
//! (lex -> parse -> sema -> IR -> codegen -> native executable) and is the
//! single place that knows the *order* those stages run in. Each stage
//! itself lives in its own module and knows nothing about its neighbors.

use crate::ast;
use crate::codegen::{self, CodegenOptions};
use crate::diagnostics::DiagnosticBag;
use crate::ir;
use crate::lexer;
use crate::parser;
use crate::resolve;
use crate::sema;
use anyhow::{bail, Context, Result};
use std::path::Path;
use std::process::Command;

/// Outcome of running the front end (everything up to and including
/// semantic analysis) over a source file.
pub enum CheckOutcome {
    Ok,
    Errors,
}

/// Runs lexing, parsing and semantic analysis, printing any diagnostics.
/// Single-file entry point: `filename`/`source` are an in-memory source
/// with no real file backing it (used directly by the test suite, and by
/// anything embedding the compiler); `use`/`from ... import` are parsed
/// but not resolved against a filesystem here. For a real multi-file
/// project on disk, use [`check_project`] instead.
pub fn check_source(filename: &str, source: &str) -> (CheckOutcome, Option<ir::IrProgram>) {
    let (tokens, lex_diags) = lexer::lex(source);
    if report_and_check(filename, source, &lex_diags) {
        return (CheckOutcome::Errors, None);
    }

    let (program, parse_diags) = parser::parse(tokens);
    let had_parse_errors = report_and_check(filename, source, &parse_diags);
    let Some(program) = program else {
        return (CheckOutcome::Errors, None);
    };
    if had_parse_errors {
        return (CheckOutcome::Errors, None);
    }

    let (typed, sema_diags) = sema::analyze(&program);
    let had_sema_errors = report_and_check(filename, source, &sema_diags);
    let Some(typed) = typed else {
        return (CheckOutcome::Errors, None);
    };
    if had_sema_errors {
        return (CheckOutcome::Errors, None);
    }

    let ast_program = crate::ast::Program {
        imports: Vec::new(),
        structs: typed.structs,
        enums: typed.enums,
        functions: typed.functions,
    };
    let ir_program = ir::lower_program(&ast_program);
    (CheckOutcome::Ok, Some(ir_program))
}

/// Runs the full front end over a real, on-disk project: loads
/// `entry_path` plus every file it (transitively) imports from
/// `src_root` (see `resolve.rs`), merges them, then type-checks the
/// result. Diagnostics from any file are attributed back to that file.
pub fn check_project(entry_path: &Path, src_root: &Path) -> (CheckOutcome, Option<ir::IrProgram>) {
    let (outcome, result) = check_project_impl(entry_path, src_root, false);
    (outcome, result.map(|(_, ir)| ir))
}

/// Like [`check_project`], but for `kite build --freestanding`/`--lib`:
/// doesn't require a `make main():` entry point, since that code is a
/// library of functions meant to be linked into another build rather
/// than run standalone. Also returns the merged, resolved `ast::Program`
/// (used by `kite build --lib` to generate a C header).
pub fn check_project_freestanding(
    entry_path: &Path,
    src_root: &Path,
) -> (CheckOutcome, Option<(ast::Program, ir::IrProgram)>) {
    check_project_impl(entry_path, src_root, true)
}

fn check_project_impl(
    entry_path: &Path,
    src_root: &Path,
    freestanding: bool,
) -> (CheckOutcome, Option<(ast::Program, ir::IrProgram)>) {
    let Some(merged) = resolve::load_and_merge(entry_path, src_root) else {
        return (CheckOutcome::Errors, None);
    };

    let (typed, sema_diags) = if freestanding {
        sema::analyze_multi_file_freestanding(&merged.program, &merged.origins)
    } else {
        sema::analyze_multi_file(&merged.program, &merged.origins)
    };
    if !sema_diags.is_empty() {
        let entry_source = std::fs::read_to_string(entry_path).unwrap_or_default();
        sema_diags.emit(&entry_path.display().to_string(), &entry_source);
    }
    let Some(typed) = typed else {
        return (CheckOutcome::Errors, None);
    };

    let ast_program = crate::ast::Program {
        imports: Vec::new(),
        structs: typed.structs,
        enums: typed.enums,
        functions: typed.functions,
    };
    let ir_program = ir::lower_program(&ast_program);
    (CheckOutcome::Ok, Some((ast_program, ir_program)))
}

fn report_and_check(filename: &str, source: &str, diags: &DiagnosticBag) -> bool {
    if !diags.is_empty() {
        diags.emit(filename, source);
    }
    diags.had_errors()
}

/// Compiles a single in-memory Kite source (no real file backing it, no
/// import resolution) all the way down to a native executable at
/// `output_path`. Used directly by the test suite; for a real on-disk
/// project, use [`build_project`].
pub fn build_executable(
    filename: &str,
    source: &str,
    output_path: &Path,
    opt_level: u8,
    target_triple: Option<&str>,
) -> Result<()> {
    let (outcome, ir_program) = check_source(filename, source);
    if matches!(outcome, CheckOutcome::Errors) {
        bail!("aborting build due to previous error(s)");
    }
    let ir_program = ir_program.expect("Ok outcome implies IR was produced");
    build_from_ir(
        &ir_program,
        output_path,
        opt_level,
        target_triple,
        BuildKind::Executable {
            static_link: false,
            extra_link_inputs: Vec::new(),
        },
    )
}

/// Compiles a real, on-disk (possibly multi-file) project all the way
/// down to a native executable at `output_path`. `static_link` passes
/// `-static` to clang so the result has no dynamic library dependencies
/// at runtime -- see `kite build --static`. `extra_link_inputs` are
/// additional object files/static libraries/C source files passed to
/// the final clang invocation, for calling C from Kite (`extern make
/// ...` declarations get their implementation from here) -- see
/// `kite build --link` and `docs/c-interop.md`.
pub fn build_project(
    entry_path: &Path,
    src_root: &Path,
    output_path: &Path,
    opt_level: u8,
    target_triple: Option<&str>,
    static_link: bool,
    extra_link_inputs: &[std::path::PathBuf],
) -> Result<()> {
    let (outcome, ir_program) = check_project(entry_path, src_root);
    if matches!(outcome, CheckOutcome::Errors) {
        bail!("aborting build due to previous error(s)");
    }
    let ir_program = ir_program.expect("Ok outcome implies IR was produced");
    build_from_ir(
        &ir_program,
        output_path,
        opt_level,
        target_triple,
        BuildKind::Executable {
            static_link,
            extra_link_inputs: extra_link_inputs.to_vec(),
        },
    )
}

/// Compiles a real, on-disk (possibly multi-file) project down to a
/// relocatable **object file** (`.o`) -- `kite build --freestanding`.
///
/// This is meant for embedding Kite code into another C/kernel/OS build
/// with no dependency on a hosted runtime: it skips linking entirely (so
/// there is no requirement that `printf`/`malloc`/etc. resolve at *this*
/// build's link time -- the embedding build provides its own
/// implementations, exactly like any other freestanding C object file),
/// and doesn't wrap `main` into the hosted-C `int main()` ABI (see
/// `codegen::CodegenOptions::freestanding`) or require one to exist at
/// all -- freestanding code is a library of functions, not a standalone
/// program.
pub fn build_project_freestanding(
    entry_path: &Path,
    src_root: &Path,
    output_path: &Path,
    opt_level: u8,
    target_triple: Option<&str>,
) -> Result<()> {
    let (outcome, result) = check_project_freestanding(entry_path, src_root);
    if matches!(outcome, CheckOutcome::Errors) {
        bail!("aborting build due to previous error(s)");
    }
    let (_, ir_program) = result.expect("Ok outcome implies IR was produced");
    build_from_ir(
        &ir_program,
        output_path,
        opt_level,
        target_triple,
        BuildKind::Object { bare_metal: true },
    )
}

/// Compiles a real, on-disk (possibly multi-file) project down to a
/// relocatable **object file** (`.o`) meant to be called *from* C (or
/// linked into a larger C/C++ program) -- `kite build --lib`. Unlike
/// [`build_project_freestanding`], this assumes a normal hosted
/// environment is available at the *final* link time (so `print`,
/// lists, etc. work exactly as they do in a normal executable) -- the
/// only difference from a normal build is that no `.o` -> executable
/// link happens here, and no `make main():` is required, since a
/// library is a set of callable functions rather than a standalone
/// program. Also writes a `<output>.h` C header declaring every
/// non-`extern` function. See `docs/c-interop.md` for the full story on
/// calling Kite from C and C from Kite.
pub fn build_project_lib(
    entry_path: &Path,
    src_root: &Path,
    output_path: &Path,
    opt_level: u8,
    target_triple: Option<&str>,
) -> Result<std::path::PathBuf> {
    let (outcome, result) = check_project_freestanding(entry_path, src_root);
    if matches!(outcome, CheckOutcome::Errors) {
        bail!("aborting build due to previous error(s)");
    }
    let (ast_program, ir_program) = result.expect("Ok outcome implies IR was produced");
    build_from_ir(
        &ir_program,
        output_path,
        opt_level,
        target_triple,
        BuildKind::Object { bare_metal: false },
    )?;

    let guard_name = output_path
        .file_stem()
        .and_then(|s| s.to_str())
        .unwrap_or("kite_lib");
    let header = crate::cheader::generate_c_header(guard_name, &ast_program);
    let header_path = output_path.with_extension("h");
    std::fs::write(&header_path, header)
        .with_context(|| format!("failed to write C header to {}", header_path.display()))?;
    Ok(header_path)
}

enum BuildKind {
    Executable {
        static_link: bool,
        extra_link_inputs: Vec<std::path::PathBuf>,
    },
    Object {
        bare_metal: bool,
    },
}

fn build_from_ir(
    ir_program: &ir::IrProgram,
    output_path: &Path,
    opt_level: u8,
    target_triple: Option<&str>,
    kind: BuildKind,
) -> Result<()> {
    let no_hosted_main = matches!(kind, BuildKind::Object { .. });
    let llvm_ir = codegen::emit_module(
        ir_program,
        &CodegenOptions {
            target_triple: target_triple.map(|s| s.to_string()),
            freestanding: no_hosted_main,
        },
    );

    match kind {
        BuildKind::Executable {
            static_link,
            extra_link_inputs,
        } => compile_llvm_ir_to_executable(
            &llvm_ir,
            output_path,
            opt_level,
            target_triple,
            static_link,
            &extra_link_inputs,
        ),
        BuildKind::Object { bare_metal } => {
            compile_llvm_ir_to_object(&llvm_ir, output_path, opt_level, target_triple, bare_metal)
        }
    }
}

/// Shells out to `clang` to turn textual LLVM IR into a native executable.
/// This is the one point where Kite depends on an external toolchain,
/// exactly as Rust depends on a system linker.
fn compile_llvm_ir_to_executable(
    llvm_ir: &str,
    output_path: &Path,
    opt_level: u8,
    target_triple: Option<&str>,
    static_link: bool,
    extra_link_inputs: &[std::path::PathBuf],
) -> Result<()> {
    if let Some(parent) = output_path.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("failed to create output directory {}", parent.display()))?;
    }

    let ir_path = output_path.with_extension("ll");
    std::fs::write(&ir_path, llvm_ir)
        .with_context(|| format!("failed to write LLVM IR to {}", ir_path.display()))?;

    let mut cmd = Command::new("clang");
    cmd.arg(&ir_path)
        .arg(format!("-O{opt_level}"))
        .arg("-o")
        .arg(output_path)
        .arg("-Wno-override-module");

    for extra in extra_link_inputs {
        if !extra.is_file() {
            bail!("--link input `{}` does not exist", extra.display());
        }
        cmd.arg(extra);
    }
    if static_link {
        cmd.arg("-static");
    }
    if let Some(triple) = target_triple {
        cmd.arg("--target").arg(triple);
    }

    let status = cmd.status().with_context(|| {
        "failed to invoke `clang` -- is LLVM/clang installed and on your PATH? \
         Kite uses clang as its backend to turn LLVM IR into a native executable."
            .to_string()
    })?;

    if !status.success() {
        bail!(
            "clang failed to compile the generated LLVM IR (see {} for the generated IR)",
            ir_path.display()
        );
    }

    Ok(())
}

/// Shells out to `clang -c` to turn textual LLVM IR into a relocatable
/// **object file**, without linking -- see [`build_project_freestanding`]
/// and [`build_project_lib`]. `bare_metal` additionally passes
/// `-ffreestanding -fno-builtin` for code with no hosted runtime at all
/// (`--freestanding`); a plain hosted `--lib` build leaves those off,
/// since it can safely assume a normal libc will be present when the
/// resulting object is finally linked.
fn compile_llvm_ir_to_object(
    llvm_ir: &str,
    output_path: &Path,
    opt_level: u8,
    target_triple: Option<&str>,
    bare_metal: bool,
) -> Result<()> {
    if let Some(parent) = output_path.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("failed to create output directory {}", parent.display()))?;
    }

    let ir_path = output_path.with_extension("ll");
    std::fs::write(&ir_path, llvm_ir)
        .with_context(|| format!("failed to write LLVM IR to {}", ir_path.display()))?;

    let mut cmd = Command::new("clang");
    cmd.arg(&ir_path)
        .arg(format!("-O{opt_level}"))
        .arg("-c") // compile only -- no linking, no libc/_start requirement
        .arg("-o")
        .arg(output_path)
        .arg("-Wno-override-module");

    if bare_metal {
        cmd.arg("-ffreestanding").arg("-fno-builtin");
    }
    if let Some(triple) = target_triple {
        cmd.arg("--target").arg(triple);
    }

    let status = cmd.status().with_context(|| {
        "failed to invoke `clang` -- is LLVM/clang installed and on your PATH? \
         Kite uses clang as its backend to turn LLVM IR into a relocatable object file."
            .to_string()
    })?;

    if !status.success() {
        bail!(
            "clang failed to compile the generated LLVM IR (see {} for the generated IR)",
            ir_path.display()
        );
    }

    Ok(())
}
