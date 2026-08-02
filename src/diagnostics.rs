//! Diagnostic reporting for the Kite compiler.
//!
//! Every pipeline stage (lexer, parser, sema, codegen) reports problems as
//! [`Diagnostic`] values instead of panicking or returning bare `String`s.
//! This keeps error *policy* (how things are displayed) separate from error
//! *detection* (where in the pipeline something went wrong), and makes it
//! possible to collect multiple diagnostics from a single compilation
//! instead of stopping at the first one.

use colored::Colorize;
use std::fmt;

/// A location in a source file.
///
/// `start`/`end` are byte offsets into the source (half-open range) and are
/// kept around for future tooling (e.g. LSP range mapping); `line`/`column`
/// are 1-based human-readable coordinates used for display.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct Span {
    pub start: usize,
    pub end: usize,
    pub line: usize,
    pub column: usize,
}

impl Span {
    pub fn new(start: usize, end: usize, line: usize, column: usize) -> Self {
        Self {
            start,
            end,
            line,
            column,
        }
    }

    /// A placeholder span for diagnostics that are not tied to a precise
    /// source location (e.g. "file not found").
    pub fn dummy() -> Self {
        Self {
            start: 0,
            end: 0,
            line: 0,
            column: 0,
        }
    }

    /// Merge two spans into one that covers both (used when combining
    /// tokens into larger AST nodes).
    pub fn to(self, other: Span) -> Span {
        Span {
            start: self.start.min(other.start),
            end: self.end.max(other.end),
            line: self.line,
            column: self.column,
        }
    }
}

/// Severity of a diagnostic. Only [`Severity::Error`] causes compilation to
/// fail; the others are reserved for future use (lints, notes attached to
/// an error).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Severity {
    Error,
    Warning,
    Note,
}

impl fmt::Display for Severity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Severity::Error => write!(f, "{}", "error".red().bold()),
            Severity::Warning => write!(f, "{}", "warning".yellow().bold()),
            Severity::Note => write!(f, "{}", "note".blue().bold()),
        }
    }
}

/// A single compiler diagnostic.
#[derive(Debug, Clone)]
pub struct Diagnostic {
    pub severity: Severity,
    /// Stable machine-readable code, e.g. `E0001`. `None` for notes.
    pub code: Option<&'static str>,
    pub title: String,
    pub span: Span,
    /// Short label printed under the caret pointing at `span`.
    pub label: Option<String>,
    /// A longer, optional suggestion printed below the snippet.
    pub help: Option<String>,
}

impl Diagnostic {
    pub fn error(code: &'static str, title: impl Into<String>, span: Span) -> Self {
        Self {
            severity: Severity::Error,
            code: Some(code),
            title: title.into(),
            span,
            label: None,
            help: None,
        }
    }

    pub fn warning(title: impl Into<String>, span: Span) -> Self {
        Self {
            severity: Severity::Warning,
            code: None,
            title: title.into(),
            span,
            label: None,
            help: None,
        }
    }

    pub fn with_label(mut self, label: impl Into<String>) -> Self {
        self.label = Some(label.into());
        self
    }

    pub fn with_help(mut self, help: impl Into<String>) -> Self {
        self.help = Some(help.into());
        self
    }

    /// Render this diagnostic as a human-readable, colored, multi-line
    /// string in the style of `rustc`/`cargo`:
    ///
    /// ```text
    /// error[E0001]: unexpected token
    ///   --> main.ki:4:9
    ///    |
    ///  4 | let x = ;
    ///    |         ^ expected an expression
    ///    |
    ///    = help: provide a value, e.g. `let x = 0;`
    /// ```
    pub fn render(&self, filename: &str, source: &str) -> String {
        let mut out = String::new();

        let code_part = match self.code {
            Some(c) => format!("[{}]", c),
            None => String::new(),
        };
        out.push_str(&format!(
            "{}{}: {}\n",
            self.severity,
            code_part.dimmed(),
            self.title.bold()
        ));

        let line_no = self.span.line.max(1);
        out.push_str(&format!(
            "{}{} {}:{}:{}\n",
            " ".repeat(gutter_width(line_no)),
            "-->".blue().bold(),
            filename,
            line_no,
            self.span.column
        ));

        let gutter = gutter_width(line_no);
        out.push_str(&format!("{} {}\n", " ".repeat(gutter), "|".blue().bold()));

        if let Some(source_line) = source.lines().nth(line_no.saturating_sub(1)) {
            out.push_str(&format!(
                "{} {} {}\n",
                line_no.to_string().blue().bold(),
                "|".blue().bold(),
                source_line
            ));

            let col = self.span.column.saturating_sub(1);
            let width = (self.span.end.saturating_sub(self.span.start)).max(1);
            let caret = "^".repeat(width.min(source_line.len().saturating_sub(col).max(1)));
            let mut pointer_line = format!(
                "{} {} {}{}",
                " ".repeat(gutter),
                "|".blue().bold(),
                " ".repeat(col),
                caret.red().bold()
            );
            if let Some(label) = &self.label {
                pointer_line.push(' ');
                pointer_line.push_str(&label.red().to_string());
            }
            out.push_str(&pointer_line);
            out.push('\n');
        }

        out.push_str(&format!("{} {}\n", " ".repeat(gutter), "|".blue().bold()));

        if let Some(help) = &self.help {
            out.push_str(&format!(
                "{}{} {}: {}\n",
                " ".repeat(gutter),
                "=".blue().bold(),
                "help".bold(),
                help
            ));
        }

        out
    }
}

fn gutter_width(line_no: usize) -> usize {
    line_no.to_string().len()
}

/// Accumulates diagnostics produced while running a compiler stage.
///
/// Stages prefer to keep going after a recoverable error (e.g. the parser
/// can often resynchronize at the next `;`) so that a single `kite build`
/// reports as many problems as possible, matching the UX of modern
/// compilers.
#[derive(Debug, Default)]
pub struct DiagnosticBag {
    diagnostics: Vec<Diagnostic>,
}

impl DiagnosticBag {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn push(&mut self, diagnostic: Diagnostic) {
        self.diagnostics.push(diagnostic);
    }

    pub fn had_errors(&self) -> bool {
        self.diagnostics
            .iter()
            .any(|d| d.severity == Severity::Error)
    }

    pub fn is_empty(&self) -> bool {
        self.diagnostics.is_empty()
    }

    pub fn iter(&self) -> impl Iterator<Item = &Diagnostic> {
        self.diagnostics.iter()
    }

    pub fn into_vec(self) -> Vec<Diagnostic> {
        self.diagnostics
    }

    /// Print every diagnostic to stderr.
    pub fn emit(&self, filename: &str, source: &str) {
        for diag in &self.diagnostics {
            eprint!("{}", diag.render(filename, source));
            eprintln!();
        }
    }
}
