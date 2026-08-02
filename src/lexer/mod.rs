//! Lexical analysis: turns raw Kite source text into a stream of [`Token`]s.
//!
//! Kite uses Python-style significant indentation, so this lexer runs in
//! two passes conceptually (though implemented in one): first it scans
//! ordinary tokens line by line, then a second pass (`layout`) walks the
//! raw token stream and inserts `Indent`/`Dedent`/`Newline` tokens based on
//! each logical line's leading whitespace. Tokens inside brackets
//! (`(...)`, `[...]`, `{...}`) never trigger layout changes, mirroring
//! Python's implicit line-joining rule, so multi-line list/dict/tuple
//! literals and call argument lists work naturally.

pub mod token;

use crate::diagnostics::{Diagnostic, DiagnosticBag, Span};
pub use token::{Token, TokenKind};

/// A raw token plus the information the layout pass needs: whether it is
/// the first token on its physical line, and that line's indentation
/// width (in columns).
struct RawLine {
    indent: usize,
    tokens: Vec<Token>,
}

pub struct Lexer {
    chars: Vec<char>,
    pos: usize,
    line: usize,
    column: usize,
    diagnostics: DiagnosticBag,
}

impl Lexer {
    pub fn new(source: &str) -> Self {
        Self {
            chars: source.chars().collect(),
            pos: 0,
            line: 1,
            column: 1,
            diagnostics: DiagnosticBag::new(),
        }
    }

    /// Lex the entire source into a token stream, always ending with `Eof`.
    pub fn tokenize(mut self) -> (Vec<Token>, DiagnosticBag) {
        let raw_lines = self.scan_logical_lines();
        let tokens = self.apply_layout(raw_lines);
        (tokens, self.diagnostics)
    }

    // ---- pass 1: scan raw tokens, grouped by physical/logical line -------

    fn scan_logical_lines(&mut self) -> Vec<RawLine> {
        let mut lines = Vec::new();
        let mut bracket_depth: i32 = 0;

        loop {
            // Measure indentation of this physical line.
            let mut indent = 0usize;
            let line_start = self.pos;
            while let Some(c) = self.peek() {
                match c {
                    ' ' => {
                        indent += 1;
                        self.advance();
                    }
                    '\t' => {
                        self.diagnostics.push(
                            Diagnostic::error(
                                "E0004",
                                "tabs are not allowed for indentation",
                                Span::new(self.pos, self.pos + 1, self.line, self.column),
                            )
                            .with_help("use spaces instead of tabs"),
                        );
                        self.advance();
                    }
                    _ => break,
                }
            }

            // Skip a blank or comment-only line entirely (does not affect
            // indentation tracking).
            if self.peek().is_none() {
                break;
            }
            if self.peek() == Some('\n') {
                self.advance();
                continue;
            }
            if self.peek() == Some('/') && self.peek_at(1) == Some('/') {
                while self.peek().is_some() && self.peek() != Some('\n') {
                    self.advance();
                }
                continue;
            }
            let _ = line_start;

            // Scan tokens for this logical line (which may span several
            // physical lines while bracket_depth > 0).
            let mut tokens = Vec::new();
            loop {
                self.skip_intraline_whitespace_and_comments();
                match self.peek() {
                    None => break,
                    Some('\n') => {
                        if bracket_depth > 0 {
                            self.advance();
                            continue;
                        } else {
                            self.advance();
                            break;
                        }
                    }
                    Some(c) => {
                        let start_pos = self.pos;
                        let start_line = self.line;
                        let start_col = self.column;

                        let kind = if c.is_ascii_digit() {
                            self.lex_number()
                        } else if c == '"' {
                            self.lex_string(start_line, start_col)
                        } else if is_ident_start(c) {
                            self.lex_identifier()
                        } else {
                            self.lex_operator(start_line, start_col, &mut bracket_depth)
                        };

                        if let Some(kind) = kind {
                            let span = Span::new(start_pos, self.pos, start_line, start_col);
                            tokens.push(Token::new(kind, span));
                        }
                    }
                }
            }

            if !tokens.is_empty() {
                lines.push(RawLine { indent, tokens });
            }
        }

        lines
    }

    fn skip_intraline_whitespace_and_comments(&mut self) {
        loop {
            match self.peek() {
                Some(' ') | Some('\t') | Some('\r') => {
                    self.advance();
                }
                Some('/') if self.peek_at(1) == Some('/') => {
                    while self.peek().is_some() && self.peek() != Some('\n') {
                        self.advance();
                    }
                }
                _ => break,
            }
        }
    }

    // ---- pass 2: turn indentation widths into Indent/Dedent/Newline -----

    fn apply_layout(&mut self, lines: Vec<RawLine>) -> Vec<Token> {
        let mut out = Vec::new();
        let mut indent_stack = vec![0usize];

        for raw_line in &lines {
            let indent = raw_line.indent;
            let current = *indent_stack.last().unwrap();

            match indent.cmp(&current) {
                std::cmp::Ordering::Greater => {
                    indent_stack.push(indent);
                    out.push(Token::new(TokenKind::Indent, raw_line.tokens[0].span));
                }
                std::cmp::Ordering::Less => {
                    while *indent_stack.last().unwrap() > indent {
                        indent_stack.pop();
                        out.push(Token::new(TokenKind::Dedent, raw_line.tokens[0].span));
                    }
                    if *indent_stack.last().unwrap() != indent {
                        self.diagnostics.push(
                            Diagnostic::error(
                                "E0005",
                                "inconsistent indentation",
                                raw_line.tokens[0].span,
                            )
                            .with_help("indentation must match an enclosing block's level"),
                        );
                    }
                }
                std::cmp::Ordering::Equal => {}
            }

            out.extend(raw_line.tokens.iter().cloned());
            out.push(Token::new(
                TokenKind::Newline,
                raw_line.tokens.last().unwrap().span,
            ));
        }

        let eof_span = Span::new(self.pos, self.pos, self.line, self.column);
        while indent_stack.len() > 1 {
            indent_stack.pop();
            out.push(Token::new(TokenKind::Dedent, eof_span));
        }
        out.push(Token::new(TokenKind::Eof, eof_span));
        out
    }

    // ---- char-level helpers ------------------------------------------------

    fn peek(&self) -> Option<char> {
        self.chars.get(self.pos).copied()
    }

    fn peek_at(&self, offset: usize) -> Option<char> {
        self.chars.get(self.pos + offset).copied()
    }

    fn advance(&mut self) -> Option<char> {
        let c = self.peek()?;
        self.pos += 1;
        if c == '\n' {
            self.line += 1;
            self.column = 1;
        } else {
            self.column += 1;
        }
        Some(c)
    }

    fn lex_number(&mut self) -> Option<TokenKind> {
        let start = self.pos;
        while self.peek().map_or(false, |c| c.is_ascii_digit()) {
            self.advance();
        }
        let mut is_float = false;
        if self.peek() == Some('.') && self.peek_at(1).map_or(false, |c| c.is_ascii_digit()) {
            is_float = true;
            self.advance();
            while self.peek().map_or(false, |c| c.is_ascii_digit()) {
                self.advance();
            }
        }
        let text: String = self.chars[start..self.pos].iter().collect();
        if is_float {
            Some(TokenKind::FloatLiteral(text.parse().ok()?))
        } else {
            match text.parse::<i64>() {
                Ok(v) => Some(TokenKind::IntLiteral(v)),
                Err(_) => {
                    self.diagnostics.push(Diagnostic::error(
                        "E0001",
                        format!("integer literal `{text}` is too large"),
                        Span::new(start, self.pos, self.line, self.column),
                    ));
                    None
                }
            }
        }
    }

    fn lex_string(&mut self, start_line: usize, start_col: usize) -> Option<TokenKind> {
        self.advance(); // opening quote
        let mut value = String::new();
        loop {
            match self.peek() {
                None | Some('\n') => {
                    self.diagnostics.push(
                        Diagnostic::error(
                            "E0002",
                            "unterminated string literal",
                            Span::new(self.pos, self.pos, start_line, start_col),
                        )
                        .with_label("string was never closed with `\"`"),
                    );
                    return None;
                }
                Some('"') => {
                    self.advance();
                    break;
                }
                Some('\\') => {
                    self.advance();
                    match self.advance() {
                        Some('n') => value.push('\n'),
                        Some('t') => value.push('\t'),
                        Some('"') => value.push('"'),
                        Some('\\') => value.push('\\'),
                        Some(other) => value.push(other),
                        None => break,
                    }
                }
                Some(c) => {
                    value.push(c);
                    self.advance();
                }
            }
        }
        Some(TokenKind::StringLiteral(value))
    }

    fn lex_identifier(&mut self) -> Option<TokenKind> {
        let start = self.pos;
        while self.peek().map_or(false, is_ident_continue) {
            self.advance();
        }
        let text: String = self.chars[start..self.pos].iter().collect();
        Some(token::lookup_keyword(&text).unwrap_or(TokenKind::Identifier(text)))
    }

    fn lex_operator(
        &mut self,
        line: usize,
        col: usize,
        bracket_depth: &mut i32,
    ) -> Option<TokenKind> {
        let c = self.advance()?;
        use TokenKind::*;
        let kind = match c {
            '(' => {
                *bracket_depth += 1;
                LParen
            }
            ')' => {
                *bracket_depth -= 1;
                RParen
            }
            '[' => {
                *bracket_depth += 1;
                LBracket
            }
            ']' => {
                *bracket_depth -= 1;
                RBracket
            }
            '{' => {
                *bracket_depth += 1;
                LBrace
            }
            '}' => {
                *bracket_depth -= 1;
                RBrace
            }
            ',' => Comma,
            ':' => Colon,
            '.' => Dot,
            '+' => Plus,
            '*' => Star,
            '/' => Slash,
            '%' => Percent,
            '-' => {
                if self.peek() == Some('>') {
                    self.advance();
                    Arrow
                } else {
                    Minus
                }
            }
            '=' => {
                if self.peek() == Some('=') {
                    self.advance();
                    EqEq
                } else {
                    Eq
                }
            }
            '!' => {
                if self.peek() == Some('=') {
                    self.advance();
                    NotEq
                } else {
                    self.diagnostics.push(Diagnostic::error(
                        "E0003",
                        "unexpected character `!` (use `not` for boolean negation)",
                        Span::new(self.pos - 1, self.pos, line, col),
                    ));
                    return None;
                }
            }
            '<' => {
                if self.peek() == Some('=') {
                    self.advance();
                    LtEq
                } else {
                    Lt
                }
            }
            '>' => {
                if self.peek() == Some('=') {
                    self.advance();
                    GtEq
                } else {
                    Gt
                }
            }
            other => {
                self.diagnostics.push(Diagnostic::error(
                    "E0003",
                    format!("unexpected character `{other}`"),
                    Span::new(self.pos - 1, self.pos, line, col),
                ));
                return None;
            }
        };
        Some(kind)
    }
}

fn is_ident_start(c: char) -> bool {
    c.is_alphabetic() || c == '_'
}

fn is_ident_continue(c: char) -> bool {
    c.is_alphanumeric() || c == '_'
}

/// Convenience entry point used by the driver and tests.
pub fn lex(source: &str) -> (Vec<Token>, DiagnosticBag) {
    Lexer::new(source).tokenize()
}
