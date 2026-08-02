//! The compiler driver: wires the pipeline stages together
//! (lex -> parse -> sema -> IR -> codegen -> native executable) and is the
//! single place that knows the *order* those stages run in. Each stage
//! itself lives in its own module and knows nothing about its neighbors.

use crate::codegen::{self, CodegenOptions};
use crate::diagnostics::DiagnosticBag;
use crate::ir;
use crate::lexer;
use crate::parser;
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
/// Used by `kite check` and as the first phase of `kite build`.
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
        functions: typed.functions,
    };
    let ir_program = ir::lower_program(&ast_program);
    (CheckOutcome::Ok, Some(ir_program))
}

fn report_and_check(filename: &str, source: &str, diags: &DiagnosticBag) -> bool {
    if !diags.is_empty() {
        diags.emit(filename, source);
    }
    diags.had_errors()
}

/// Compiles a single Kite source file all the way down to a native
/// executable at `output_path`. Returns the generated LLVM IR text length
/// (for diagnostics/logging) on success.
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

    let llvm_ir = codegen::emit_module(
        &ir_program,
        &CodegenOptions {
            target_triple: target_triple.map(|s| s.to_string()),
        },
    );

    compile_llvm_ir_to_executable(&llvm_ir, output_path, opt_level, target_triple)
}

/// Shells out to `clang` to turn textual LLVM IR into a native executable.
/// This is the one point where Kite depends on an external toolchain,
/// exactly as Rust depends on a system linker.
fn compile_llvm_ir_to_executable(
    llvm_ir: &str,
    output_path: &Path,
    opt_level: u8,
    target_triple: Option<&str>,
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
