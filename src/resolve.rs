//! Multi-file module resolution.
//!
//! Kite projects aren't limited to a single `src/main.ki`: `use module`
//! and `from module import item` (see `ast::Import`) can reference
//! sibling `.ki` files anywhere under the project's `src/` directory.
//! `use shapes.circle` resolves to `src/shapes/circle.ki` -- dots map to
//! directory separators, always resolved from the project's `src/` root
//! (not relative to the importing file), the same way Python packages
//! work.
//!
//! v0.1's module system is intentionally simple: every function and
//! struct visible in an imported file becomes visible in the importing
//! file too (both `use module` and `from module import a, b` behave the
//! same way -- there is no per-symbol visibility/export list yet, and no
//! namespacing of imported calls like `module.function()`). This is
//! enough for real multi-file projects while keeping the change to the
//! rest of the compiler small: everything downstream of this module
//! (sema, IR lowering, codegen) still only ever sees one flat,
//! already-merged `ast::Program`, exactly as it did for a single file.
//! Per-symbol visibility and qualified `module.function()` calls are a
//! v0.2 roadmap item.

use crate::ast::{EnumDef, Function, Import, Program, StructDef};
use crate::diagnostics::{Diagnostic, DiagnosticBag, Span};
use crate::{lexer, parser};
use std::collections::{HashMap, HashSet};
use std::path::{Path, PathBuf};

/// A program merged from an entry file and every file it (transitively)
/// imports, plus enough bookkeeping to attribute diagnostics back to the
/// right file (see `sema::analyze_multi_file`).
pub struct MergedProgram {
    pub program: Program,
    /// function/struct name -> (display filename, full source text)
    pub origins: HashMap<String, (String, String)>,
    /// Every file that was actually read, in load order (entry file
    /// first) -- useful for `kite build`/`check` progress output.
    pub files_loaded: Vec<PathBuf>,
}

/// Loads `entry_path` and every file it imports (transitively), resolving
/// `use`/`from ... import` against `src_root`. On any lex/parse error in
/// any file, or an unresolvable import, prints the diagnostic(s) (with
/// correct per-file attribution) and returns `None`.
pub fn load_and_merge(entry_path: &Path, src_root: &Path) -> Option<MergedProgram> {
    let mut loader = Loader {
        src_root: src_root.to_path_buf(),
        visited: HashSet::new(),
        functions: Vec::new(),
        structs: Vec::new(),
        enums: Vec::new(),
        origins: HashMap::new(),
        files_loaded: Vec::new(),
        diagnostics: DiagnosticBag::new(),
    };

    let ok = loader.load_file(entry_path, true);

    if !ok || loader.diagnostics.had_errors() {
        // Diagnostics were already tagged with their origin file as they
        // were collected; emit against the entry file as a harmless
        // default for anything that somehow wasn't tagged.
        let entry_source = std::fs::read_to_string(entry_path).unwrap_or_default();
        loader
            .diagnostics
            .emit(&entry_path.display().to_string(), &entry_source);
        return None;
    }

    Some(MergedProgram {
        program: Program {
            imports: Vec::new(),
            structs: loader.structs,
            enums: loader.enums,
            functions: loader.functions,
        },
        origins: loader.origins,
        files_loaded: loader.files_loaded,
    })
}

struct Loader {
    src_root: PathBuf,
    visited: HashSet<PathBuf>,
    functions: Vec<Function>,
    structs: Vec<StructDef>,
    enums: Vec<EnumDef>,
    origins: HashMap<String, (String, String)>,
    files_loaded: Vec<PathBuf>,
    diagnostics: DiagnosticBag,
}

impl Loader {
    /// Loads one file, recursively loading its imports first (so a
    /// duplicate-definition error always reports at the *first* place
    /// wins the merge, source order). Returns `false` if this file (or
    /// anything it imports) failed to load.
    fn load_file(&mut self, path: &Path, is_entry: bool) -> bool {
        let canonical = path.canonicalize().unwrap_or_else(|_| path.to_path_buf());
        if self.visited.contains(&canonical) {
            return true; // already loaded (or a cycle) -- not an error
        }
        self.visited.insert(canonical);

        let display_name = display_path(path, &self.src_root);

        let source = match std::fs::read_to_string(path) {
            Ok(s) => s,
            Err(e) => {
                self.diagnostics.push(
                    Diagnostic::error(
                        "E0070",
                        format!("could not read `{}`: {e}", display_name),
                        Span::dummy(),
                    )
                    .with_file(display_name.clone(), String::new()),
                );
                return false;
            }
        };

        let (tokens, mut lex_diags) = lexer::lex(&source);
        lex_diags.retag_file(&display_name, &source);
        let had_lex_errors = lex_diags.had_errors();
        self.diagnostics.extend(lex_diags);
        if had_lex_errors {
            return false;
        }

        let (program, mut parse_diags) = parser::parse(tokens);
        parse_diags.retag_file(&display_name, &source);
        let had_parse_errors = parse_diags.had_errors();
        self.diagnostics.extend(parse_diags);
        let Some(program) = program else {
            return false;
        };
        if had_parse_errors {
            return false;
        }

        self.files_loaded.push(path.to_path_buf());

        // Resolve this file's imports before merging its own
        // functions/structs, so `origins` always reflects the first
        // (deepest) definition of a name in load order.
        let mut all_ok = true;
        for import in &program.imports {
            let (module_path_str, span) = match import {
                Import::Module { path, span } => (path.clone(), *span),
                Import::Items { path, span, .. } => (path.clone(), *span),
            };
            let resolved = self
                .src_root
                .join(module_path_str.replace('.', "/") + ".ki");
            if !resolved.is_file() {
                self.diagnostics.push(
                    Diagnostic::error(
                        "E0071",
                        format!(
                            "cannot find module `{module_path_str}` (looked for `{}`)",
                            display_path(&resolved, &self.src_root)
                        ),
                        span,
                    )
                    .with_file(display_name.clone(), source.clone())
                    .with_help("module paths are resolved from `src/`, with `.` as a directory separator (e.g. `use shapes.circle` -> `src/shapes/circle.ki`)"),
                );
                all_ok = false;
                continue;
            }
            if !self.load_file(&resolved, false) {
                all_ok = false;
            }
        }

        for func in &program.functions {
            if self.origins.contains_key(&func.name) {
                self.diagnostics.push(
                    Diagnostic::error(
                        "E0036",
                        format!(
                            "function `{}` is defined multiple times across the project",
                            func.name
                        ),
                        func.span,
                    )
                    .with_file(display_name.clone(), source.clone()),
                );
                all_ok = false;
                continue;
            }
            self.origins
                .insert(func.name.clone(), (display_name.clone(), source.clone()));
            self.functions.push(func.clone());
        }
        for s in &program.structs {
            if self.origins.contains_key(&s.name) {
                self.diagnostics.push(
                    Diagnostic::error(
                        "E0061",
                        format!(
                            "struct `{}` is defined multiple times across the project",
                            s.name
                        ),
                        s.span,
                    )
                    .with_file(display_name.clone(), source.clone()),
                );
                all_ok = false;
                continue;
            }
            self.origins
                .insert(s.name.clone(), (display_name.clone(), source.clone()));
            self.structs.push(s.clone());
        }
        for e in &program.enums {
            if self.origins.contains_key(&e.name) {
                self.diagnostics.push(
                    Diagnostic::error(
                        "E0069",
                        format!(
                            "enum `{}` is defined multiple times across the project",
                            e.name
                        ),
                        e.span,
                    )
                    .with_file(display_name.clone(), source.clone()),
                );
                all_ok = false;
                continue;
            }
            self.origins
                .insert(e.name.clone(), (display_name.clone(), source.clone()));
            self.enums.push(e.clone());
        }

        let _ = is_entry;
        all_ok
    }
}

/// A short, stable display path (relative to `src/` when possible) used
/// in diagnostics and progress output, instead of a long absolute path.
fn display_path(path: &Path, src_root: &Path) -> String {
    path.strip_prefix(src_root)
        .map(|p| p.display().to_string())
        .unwrap_or_else(|_| path.display().to_string())
}
