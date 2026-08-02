//! The Kite compiler, as a library.
//!
//! ```text
//! source text
//!     │  lexer
//!     ▼
//! tokens
//!     │  parser
//!     ▼
//! AST                (ast.rs)
//!     │  sema
//!     ▼
//! typed AST          (sema.rs)
//!     │  ir::lower_program
//!     ▼
//! Kite IR            (ir.rs)
//!     │  codegen::emit_module
//!     ▼
//! LLVM IR text
//!     │  clang (external)
//!     ▼
//! native executable
//! ```
//!
//! The [`driver`] module wires these stages together; every other module
//! is usable independently (and is exercised independently in `tests/`).

pub mod ast;
pub mod codegen;
pub mod diagnostics;
pub mod driver;
pub mod ir;
pub mod lexer;
pub mod parser;
pub mod project;
pub mod sema;
