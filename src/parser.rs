//! Recursive-descent parser: turns a token stream into an [`crate::ast::Program`].
//!
//! Blocks are delimited by `Indent`/`Dedent`/`Newline` tokens produced by
//! the lexer's layout pass rather than braces, so the block-level grammar
//! here mirrors Python's rather than C's. Expressions are parsed with a
//! standard precedence-climbing (Pratt-style) function.

use crate::ast::*;
use crate::diagnostics::{Diagnostic, DiagnosticBag, Span};
use crate::lexer::{Token, TokenKind};

pub struct Parser {
    tokens: Vec<Token>,
    pos: usize,
    diagnostics: DiagnosticBag,
}

type PResult<T> = Result<T, ()>;

impl Parser {
    pub fn new(tokens: Vec<Token>) -> Self {
        Self {
            tokens,
            pos: 0,
            diagnostics: DiagnosticBag::new(),
        }
    }

    pub fn parse_program(mut self) -> (Option<Program>, DiagnosticBag) {
        let mut imports = Vec::new();
        let mut structs = Vec::new();
        let mut enums = Vec::new();
        let mut functions = Vec::new();

        self.skip_blank_newlines();
        while !self.at(TokenKind::Eof) {
            let result = match self.peek() {
                TokenKind::Use | TokenKind::From => self.parse_import().map(|i| {
                    imports.push(i);
                }),
                TokenKind::Type => self.parse_struct_def().map(|s| {
                    structs.push(s);
                }),
                TokenKind::Enum => self.parse_enum_def().map(|e| {
                    enums.push(e);
                }),
                TokenKind::Async | TokenKind::Make | TokenKind::Extern => {
                    self.parse_function().map(|f| {
                        functions.push(f);
                    })
                }
                _ => {
                    let span = self.peek_span();
                    self.diagnostics.push(Diagnostic::error(
                        "E0010",
                        format!(
                            "expected `use`, `from`, `type`, `enum`, `extern`, or `make`, found {}",
                            self.peek()
                        ),
                        span,
                    ));
                    Err(())
                }
            };
            if result.is_err() {
                self.synchronize_to_top_level();
            }
            self.skip_blank_newlines();
        }

        let had_errors = self.diagnostics.had_errors();
        (
            if had_errors {
                None
            } else {
                Some(Program {
                    imports,
                    structs,
                    enums,
                    functions,
                })
            },
            self.diagnostics,
        )
    }

    // ---- token stream helpers -------------------------------------------------

    fn peek(&self) -> &TokenKind {
        &self.tokens[self.pos.min(self.tokens.len() - 1)].kind
    }

    fn peek_at(&self, offset: usize) -> &TokenKind {
        let idx = (self.pos + offset).min(self.tokens.len() - 1);
        &self.tokens[idx].kind
    }

    fn peek_span(&self) -> Span {
        self.tokens[self.pos.min(self.tokens.len() - 1)].span
    }

    fn at(&self, kind: TokenKind) -> bool {
        std::mem::discriminant(self.peek()) == std::mem::discriminant(&kind)
    }

    fn advance(&mut self) -> Token {
        let tok = self.tokens[self.pos.min(self.tokens.len() - 1)].clone();
        if self.pos < self.tokens.len() - 1 {
            self.pos += 1;
        }
        tok
    }

    fn expect(&mut self, kind: TokenKind) -> PResult<Token> {
        if self.at(kind.clone()) {
            Ok(self.advance())
        } else {
            let span = self.peek_span();
            self.diagnostics.push(
                Diagnostic::error(
                    "E0010",
                    format!("expected {}, found {}", kind, self.peek()),
                    span,
                )
                .with_label(format!("expected {kind} here")),
            );
            Err(())
        }
    }

    fn skip_blank_newlines(&mut self) {
        while self.at(TokenKind::Newline) {
            self.advance();
        }
    }

    fn synchronize_to_top_level(&mut self) {
        while !self.at(TokenKind::Eof)
            && !self.at(TokenKind::Make)
            && !self.at(TokenKind::Async)
            && !self.at(TokenKind::Extern)
            && !self.at(TokenKind::Type)
            && !self.at(TokenKind::Enum)
            && !self.at(TokenKind::Use)
            && !self.at(TokenKind::From)
        {
            self.advance();
        }
    }

    fn synchronize_to_next_stmt(&mut self) {
        while !self.at(TokenKind::Eof)
            && !self.at(TokenKind::Newline)
            && !self.at(TokenKind::Dedent)
        {
            self.advance();
        }
        if self.at(TokenKind::Newline) {
            self.advance();
        }
    }

    // ---- imports & structs --------------------------------------------------

    fn parse_import(&mut self) -> PResult<Import> {
        let start = self.peek_span();
        let import = if self.at(TokenKind::Use) {
            self.advance();
            let path = self.parse_dotted_path()?;
            Import::Module { path, span: start }
        } else {
            self.expect(TokenKind::From)?;
            let path = self.parse_dotted_path()?;
            self.expect(TokenKind::Import)?;
            let mut items = vec![self.expect_identifier_text()?];
            while self.at(TokenKind::Comma) {
                self.advance();
                items.push(self.expect_identifier_text()?);
            }
            Import::Items {
                path,
                items,
                span: start,
            }
        };
        self.expect(TokenKind::Newline)?;
        Ok(import)
    }

    fn parse_dotted_path(&mut self) -> PResult<String> {
        let mut path = self.expect_identifier_text()?;
        while self.at(TokenKind::Dot) {
            self.advance();
            path.push('.');
            path.push_str(&self.expect_identifier_text()?);
        }
        Ok(path)
    }

    fn parse_struct_def(&mut self) -> PResult<StructDef> {
        let start = self.expect(TokenKind::Type)?.span;
        let name = self.expect_identifier_text()?;
        self.expect(TokenKind::Colon)?;
        self.expect(TokenKind::Newline)?;
        self.expect(TokenKind::Indent)?;

        let mut fields = Vec::new();
        while !self.at(TokenKind::Dedent) && !self.at(TokenKind::Eof) {
            if self.at(TokenKind::Newline) {
                self.advance();
                continue;
            }
            let fname_tok = self.expect_identifier()?;
            self.expect(TokenKind::Colon)?;
            let ty = self.parse_type()?;
            self.expect(TokenKind::Newline)?;
            fields.push(StructField {
                name: ident_text(&fname_tok),
                ty,
                span: fname_tok.span,
            });
        }
        let end = self.expect(TokenKind::Dedent)?.span;

        Ok(StructDef {
            name,
            fields,
            span: start.to(end),
        })
    }

    fn parse_enum_def(&mut self) -> PResult<EnumDef> {
        let start = self.expect(TokenKind::Enum)?.span;
        let name = self.expect_identifier_text()?;
        self.expect(TokenKind::Colon)?;
        self.expect(TokenKind::Newline)?;
        self.expect(TokenKind::Indent)?;

        let mut variants = Vec::new();
        while !self.at(TokenKind::Dedent) && !self.at(TokenKind::Eof) {
            if self.at(TokenKind::Newline) {
                self.advance();
                continue;
            }
            let variant_tok = self.expect_identifier()?;
            self.expect(TokenKind::Newline)?;
            variants.push(EnumVariant {
                name: ident_text(&variant_tok),
                span: variant_tok.span,
            });
        }
        let end = self.expect(TokenKind::Dedent)?.span;

        if variants.is_empty() {
            self.diagnostics.push(
                Diagnostic::error("E0068", format!("enum `{name}` has no variants"), start.to(end))
                    .with_help("an enum needs at least one variant, e.g. `enum Color:\\n    Red\\n    Green\\n    Blue`"),
            );
        }

        Ok(EnumDef {
            name,
            variants,
            span: start.to(end),
        })
    }

    fn parse_type(&mut self) -> PResult<TypeName> {
        let span = self.peek_span();
        let ty = match self.peek().clone() {
            TokenKind::KwInt => TypeName::Int,
            TokenKind::KwFloat => TypeName::Float,
            TokenKind::KwBool => TypeName::Bool,
            TokenKind::KwString => TypeName::String,
            TokenKind::Identifier(name) => TypeName::Struct(name),
            other => {
                self.diagnostics.push(Diagnostic::error(
                    "E0011",
                    format!("expected a type, found {other}"),
                    span,
                ));
                return Err(());
            }
        };
        self.advance();
        Ok(ty)
    }

    // ---- functions ------------------------------------------------------------

    fn parse_function(&mut self) -> PResult<Function> {
        let is_extern = if self.at(TokenKind::Extern) {
            self.advance();
            true
        } else {
            false
        };
        let is_async = if self.at(TokenKind::Async) {
            self.advance();
            true
        } else {
            false
        };
        let start = self.expect(TokenKind::Make)?.span;
        let name = self.expect_identifier_text()?;

        self.expect(TokenKind::LParen)?;
        let mut params = Vec::new();
        if !self.at(TokenKind::RParen) {
            loop {
                let pname_tok = self.expect_identifier()?;
                self.expect(TokenKind::Colon)?;
                let ty = self.parse_type()?;
                params.push(Param {
                    name: ident_text(&pname_tok),
                    ty,
                    span: pname_tok.span,
                });
                if self.at(TokenKind::Comma) {
                    self.advance();
                } else {
                    break;
                }
            }
        }
        self.expect(TokenKind::RParen)?;

        let declared_return_type = if self.at(TokenKind::Arrow) {
            self.advance();
            Some(self.parse_type()?)
        } else {
            None
        };

        if is_extern {
            // `extern make name(params) [-> type]` -- a declaration with
            // no Kite body, implemented elsewhere (typically C) and
            // linked in at build time. Ends at the newline; no `:` and
            // no indented block.
            let end = self.expect(TokenKind::Newline)?.span;
            let span = start.to(end);
            return Ok(Function {
                name,
                params,
                declared_return_type,
                is_async,
                is_extern: true,
                body: None,
                span,
            });
        }

        self.expect(TokenKind::Colon)?;
        let body = self.parse_block()?;
        let span = start.to(body.span);

        Ok(Function {
            name,
            params,
            declared_return_type,
            is_async,
            is_extern: false,
            body: Some(body),
            span,
        })
    }

    // ---- blocks & statements ----------------------------------------------

    fn parse_block(&mut self) -> PResult<Block> {
        self.expect(TokenKind::Newline)?;
        let start = self.expect(TokenKind::Indent)?.span;
        let mut statements = Vec::new();
        while !self.at(TokenKind::Dedent) && !self.at(TokenKind::Eof) {
            if self.at(TokenKind::Newline) {
                self.advance();
                continue;
            }
            match self.parse_statement() {
                Ok(stmt) => statements.push(stmt),
                Err(()) => self.synchronize_to_next_stmt(),
            }
        }
        let end = self.expect(TokenKind::Dedent)?.span;
        Ok(Block {
            statements,
            span: start.to(end),
        })
    }

    fn parse_statement(&mut self) -> PResult<Stmt> {
        match self.peek().clone() {
            TokenKind::Return => self.parse_return(),
            TokenKind::Break => {
                let span = self.advance().span;
                self.expect(TokenKind::Newline)?;
                Ok(Stmt::Break(span))
            }
            TokenKind::Continue => {
                let span = self.advance().span;
                self.expect(TokenKind::Newline)?;
                Ok(Stmt::Continue(span))
            }
            TokenKind::If => self.parse_if(),
            TokenKind::Until => self.parse_until(),
            TokenKind::Infinit => self.parse_infinit(),
            TokenKind::For => self.parse_for(),
            TokenKind::Try => self.parse_try(),
            TokenKind::Thread => self.parse_thread(),
            TokenKind::Identifier(_) if self.looks_like_assignment() => self.parse_assign(),
            _ => {
                let expr = self.parse_expr()?;
                self.expect(TokenKind::Newline)?;
                Ok(Stmt::Expr(expr))
            }
        }
    }

    /// Scans forward (without consuming) past an identifier-rooted postfix
    /// chain (`ident`, `ident.field`, `ident[expr]`, chained) to see
    /// whether it is immediately followed by `=` or `: Type =`, which
    /// means this line is an assignment rather than an expression
    /// statement (e.g. a bare call like `print(x)`).
    fn looks_like_assignment(&self) -> bool {
        let mut i = self.pos;
        if !matches!(self.peek_at(0), TokenKind::Identifier(_)) {
            return false;
        }
        i += 1;
        loop {
            match self.token_at(i) {
                TokenKind::Dot => {
                    if matches!(self.token_at(i + 1), TokenKind::Identifier(_)) {
                        i += 2;
                        continue;
                    }
                    break;
                }
                TokenKind::LBracket => {
                    let mut depth = 1i32;
                    i += 1;
                    while depth > 0 {
                        match self.token_at(i) {
                            TokenKind::LBracket => depth += 1,
                            TokenKind::RBracket => depth -= 1,
                            TokenKind::Eof | TokenKind::Newline => return false,
                            _ => {}
                        }
                        i += 1;
                    }
                    continue;
                }
                _ => break,
            }
        }
        matches!(self.token_at(i), TokenKind::Eq | TokenKind::Colon)
    }

    fn token_at(&self, i: usize) -> &TokenKind {
        &self.tokens[i.min(self.tokens.len() - 1)].kind
    }

    fn parse_assign(&mut self) -> PResult<Stmt> {
        let start = self.peek_span();
        let target = self.parse_lvalue()?;

        let annotated_type = if self.at(TokenKind::Colon) {
            self.advance();
            Some(self.parse_type()?)
        } else {
            None
        };
        self.expect(TokenKind::Eq)?;
        let value = self.parse_expr()?;
        self.expect(TokenKind::Newline)?;
        let span = start.to(value.span());
        Ok(Stmt::Assign {
            target,
            annotated_type,
            value,
            span,
        })
    }

    fn parse_lvalue(&mut self) -> PResult<LValue> {
        let tok = self.expect_identifier()?;
        let mut lvalue = LValue::Ident(ident_text(&tok));
        loop {
            match self.peek().clone() {
                TokenKind::Dot => {
                    self.advance();
                    let field_tok = self.expect_identifier()?;
                    let base_expr = lvalue_to_expr(lvalue, tok.span);
                    lvalue = LValue::Field {
                        base: Box::new(base_expr),
                        field: ident_text(&field_tok),
                        span: field_tok.span,
                    };
                }
                TokenKind::LBracket => {
                    self.advance();
                    let index = self.parse_expr()?;
                    let end = self.expect(TokenKind::RBracket)?.span;
                    let base_expr = lvalue_to_expr(lvalue, tok.span);
                    lvalue = LValue::Index {
                        base: Box::new(base_expr),
                        index: Box::new(index),
                        span: tok.span.to(end),
                    };
                }
                _ => break,
            }
        }
        Ok(lvalue)
    }

    fn parse_return(&mut self) -> PResult<Stmt> {
        let start = self.expect(TokenKind::Return)?.span;
        let value = if self.at(TokenKind::Newline) {
            None
        } else {
            Some(self.parse_expr()?)
        };
        self.expect(TokenKind::Newline)?;
        Ok(Stmt::Return { value, span: start })
    }

    fn parse_if(&mut self) -> PResult<Stmt> {
        let start = self.expect(TokenKind::If)?.span;
        let condition = self.parse_expr()?;
        self.expect(TokenKind::Colon)?;
        let then_branch = self.parse_block()?;
        let mut span = start.to(then_branch.span);

        let mut orif_branches = Vec::new();
        while self.at(TokenKind::Orif) {
            let orif_start = self.advance().span;
            let cond = self.parse_expr()?;
            self.expect(TokenKind::Colon)?;
            let body = self.parse_block()?;
            span = span.to(body.span);
            orif_branches.push(OrifClause {
                condition: cond,
                span: orif_start.to(body.span),
                body,
            });
        }

        let else_branch = if self.at(TokenKind::Else) {
            self.advance();
            self.expect(TokenKind::Colon)?;
            let block = self.parse_block()?;
            span = span.to(block.span);
            Some(block)
        } else {
            None
        };

        Ok(Stmt::If {
            condition,
            then_branch,
            orif_branches,
            else_branch,
            span,
        })
    }

    fn parse_until(&mut self) -> PResult<Stmt> {
        let start = self.expect(TokenKind::Until)?.span;
        let condition = self.parse_expr()?;
        self.expect(TokenKind::Colon)?;
        let body = self.parse_block()?;
        let span = start.to(body.span);
        Ok(Stmt::Until {
            condition,
            body,
            span,
        })
    }

    fn parse_infinit(&mut self) -> PResult<Stmt> {
        let start = self.expect(TokenKind::Infinit)?.span;
        self.expect(TokenKind::Colon)?;
        let body = self.parse_block()?;
        let span = start.to(body.span);
        Ok(Stmt::Infinit { body, span })
    }

    fn parse_for(&mut self) -> PResult<Stmt> {
        let start = self.expect(TokenKind::For)?.span;
        let var_tok = self.expect_identifier()?;
        let var = ident_text(&var_tok);

        if self.at(TokenKind::Eq) {
            self.advance();
            let from = self.parse_expr()?;
            self.expect(TokenKind::To)?;
            let to = self.parse_expr()?;
            self.expect(TokenKind::Colon)?;
            let body = self.parse_block()?;
            let span = start.to(body.span);
            Ok(Stmt::ForRange {
                var,
                start: from,
                end: to,
                body,
                span,
            })
        } else {
            self.expect(TokenKind::In)?;
            let iterable = self.parse_expr()?;
            self.expect(TokenKind::Colon)?;
            let body = self.parse_block()?;
            let span = start.to(body.span);
            Ok(Stmt::ForEach {
                var,
                iterable,
                body,
                span,
            })
        }
    }

    fn parse_try(&mut self) -> PResult<Stmt> {
        let start = self.expect(TokenKind::Try)?.span;
        self.expect(TokenKind::Colon)?;
        let try_block = self.parse_block()?;
        let mut span = start.to(try_block.span);

        let (failed_var, failed_block) = if self.at(TokenKind::Failed) {
            self.advance();
            let var = if matches!(self.peek(), TokenKind::Identifier(_)) {
                Some(self.expect_identifier_text()?)
            } else {
                None
            };
            self.expect(TokenKind::Colon)?;
            let block = self.parse_block()?;
            span = span.to(block.span);
            (var, Some(block))
        } else {
            (None, None)
        };

        let finally_block = if self.at(TokenKind::Finally) {
            self.advance();
            self.expect(TokenKind::Colon)?;
            let block = self.parse_block()?;
            span = span.to(block.span);
            Some(block)
        } else {
            None
        };

        Ok(Stmt::Try {
            try_block,
            failed_var,
            failed_block,
            finally_block,
            span,
        })
    }

    fn parse_thread(&mut self) -> PResult<Stmt> {
        let start = self.expect(TokenKind::Thread)?.span;
        self.expect(TokenKind::Colon)?;
        let body = self.parse_block()?;
        let span = start.to(body.span);
        Ok(Stmt::Thread { body, span })
    }

    // ---- expressions (precedence climbing) --------------------------------

    fn parse_expr(&mut self) -> PResult<Expr> {
        self.parse_or()
    }

    fn parse_or(&mut self) -> PResult<Expr> {
        let mut lhs = self.parse_and()?;
        while self.at(TokenKind::Or) {
            self.advance();
            let rhs = self.parse_and()?;
            let span = lhs.span().to(rhs.span());
            lhs = Expr::Binary {
                op: BinOp::Or,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
                span,
            };
        }
        Ok(lhs)
    }

    fn parse_and(&mut self) -> PResult<Expr> {
        let mut lhs = self.parse_not()?;
        while self.at(TokenKind::And) {
            self.advance();
            let rhs = self.parse_not()?;
            let span = lhs.span().to(rhs.span());
            lhs = Expr::Binary {
                op: BinOp::And,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
                span,
            };
        }
        Ok(lhs)
    }

    fn parse_not(&mut self) -> PResult<Expr> {
        if self.at(TokenKind::Not) {
            let start = self.advance().span;
            let expr = self.parse_not()?;
            let span = start.to(expr.span());
            Ok(Expr::Unary {
                op: UnOp::Not,
                expr: Box::new(expr),
                span,
            })
        } else {
            self.parse_equality()
        }
    }

    fn parse_equality(&mut self) -> PResult<Expr> {
        let mut lhs = self.parse_comparison()?;
        loop {
            let op = match self.peek() {
                TokenKind::EqEq => BinOp::Eq,
                TokenKind::NotEq => BinOp::NotEq,
                _ => break,
            };
            self.advance();
            let rhs = self.parse_comparison()?;
            let span = lhs.span().to(rhs.span());
            lhs = Expr::Binary {
                op,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
                span,
            };
        }
        Ok(lhs)
    }

    fn parse_comparison(&mut self) -> PResult<Expr> {
        let mut lhs = self.parse_term()?;
        loop {
            let op = match self.peek() {
                TokenKind::Lt => BinOp::Lt,
                TokenKind::Gt => BinOp::Gt,
                TokenKind::LtEq => BinOp::LtEq,
                TokenKind::GtEq => BinOp::GtEq,
                _ => break,
            };
            self.advance();
            let rhs = self.parse_term()?;
            let span = lhs.span().to(rhs.span());
            lhs = Expr::Binary {
                op,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
                span,
            };
        }
        Ok(lhs)
    }

    fn parse_term(&mut self) -> PResult<Expr> {
        let mut lhs = self.parse_factor()?;
        loop {
            let op = match self.peek() {
                TokenKind::Plus => BinOp::Add,
                TokenKind::Minus => BinOp::Sub,
                _ => break,
            };
            self.advance();
            let rhs = self.parse_factor()?;
            let span = lhs.span().to(rhs.span());
            lhs = Expr::Binary {
                op,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
                span,
            };
        }
        Ok(lhs)
    }

    fn parse_factor(&mut self) -> PResult<Expr> {
        let mut lhs = self.parse_unary()?;
        loop {
            let op = match self.peek() {
                TokenKind::Star => BinOp::Mul,
                TokenKind::Slash => BinOp::Div,
                TokenKind::Percent => BinOp::Mod,
                _ => break,
            };
            self.advance();
            let rhs = self.parse_unary()?;
            let span = lhs.span().to(rhs.span());
            lhs = Expr::Binary {
                op,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
                span,
            };
        }
        Ok(lhs)
    }

    fn parse_unary(&mut self) -> PResult<Expr> {
        if self.at(TokenKind::Minus) {
            let start = self.advance().span;
            let expr = self.parse_unary()?;
            let span = start.to(expr.span());
            Ok(Expr::Unary {
                op: UnOp::Neg,
                expr: Box::new(expr),
                span,
            })
        } else {
            self.parse_postfix()
        }
    }

    fn parse_postfix(&mut self) -> PResult<Expr> {
        let mut expr = self.parse_primary()?;
        loop {
            match self.peek().clone() {
                TokenKind::Dot => {
                    self.advance();
                    let field_tok = self.expect_identifier()?;
                    let span = expr.span().to(field_tok.span);
                    expr = Expr::Field {
                        base: Box::new(expr),
                        field: ident_text(&field_tok),
                        span,
                    };
                }
                TokenKind::LBracket => {
                    self.advance();
                    let index = self.parse_expr()?;
                    let end = self.expect(TokenKind::RBracket)?.span;
                    let span = expr.span().to(end);
                    expr = Expr::Index {
                        base: Box::new(expr),
                        index: Box::new(index),
                        span,
                    };
                }
                TokenKind::LParen if matches!(expr, Expr::Identifier(..)) => {
                    let name = match &expr {
                        Expr::Identifier(n, _) => n.clone(),
                        _ => unreachable!(),
                    };
                    let start = expr.span();
                    self.advance();
                    let mut args = Vec::new();
                    if !self.at(TokenKind::RParen) {
                        loop {
                            args.push(self.parse_expr()?);
                            if self.at(TokenKind::Comma) {
                                self.advance();
                            } else {
                                break;
                            }
                        }
                    }
                    let end = self.expect(TokenKind::RParen)?.span;
                    expr = Expr::Call {
                        name,
                        args,
                        span: start.to(end),
                    };
                }
                _ => break,
            }
        }
        Ok(expr)
    }

    fn parse_primary(&mut self) -> PResult<Expr> {
        let span = self.peek_span();
        match self.peek().clone() {
            TokenKind::IntLiteral(v) => {
                self.advance();
                Ok(Expr::IntLiteral(v, span))
            }
            TokenKind::FloatLiteral(v) => {
                self.advance();
                Ok(Expr::FloatLiteral(v, span))
            }
            TokenKind::StringLiteral(v) => {
                self.advance();
                Ok(Expr::StringLiteral(v, span))
            }
            TokenKind::True => {
                self.advance();
                Ok(Expr::BoolLiteral(true, span))
            }
            TokenKind::False => {
                self.advance();
                Ok(Expr::BoolLiteral(false, span))
            }
            TokenKind::Identifier(name) => {
                self.advance();
                Ok(Expr::Identifier(name, span))
            }
            TokenKind::Await => {
                self.advance();
                let inner = self.parse_unary()?;
                let s = span.to(inner.span());
                Ok(Expr::Await {
                    expr: Box::new(inner),
                    span: s,
                })
            }
            TokenKind::LBracket => self.parse_list_literal(span),
            TokenKind::LBrace => self.parse_dict_literal(span),
            TokenKind::LParen => self.parse_paren_or_tuple(span),
            other => {
                self.diagnostics.push(
                    Diagnostic::error(
                        "E0012",
                        format!("expected an expression, found {other}"),
                        span,
                    )
                    .with_label("expected an expression here"),
                );
                Err(())
            }
        }
    }

    fn parse_list_literal(&mut self, start: Span) -> PResult<Expr> {
        self.advance(); // '['
        let mut items = Vec::new();
        if !self.at(TokenKind::RBracket) {
            loop {
                items.push(self.parse_expr()?);
                if self.at(TokenKind::Comma) {
                    self.advance();
                } else {
                    break;
                }
            }
        }
        let end = self.expect(TokenKind::RBracket)?.span;
        Ok(Expr::ListLiteral(items, start.to(end)))
    }

    fn parse_dict_literal(&mut self, start: Span) -> PResult<Expr> {
        self.advance(); // '{'
        self.skip_blank_newlines();
        let mut entries = Vec::new();
        if !self.at(TokenKind::RBrace) {
            loop {
                self.skip_blank_newlines();
                let key_tok = self.expect(TokenKind::StringLiteral(String::new()))?;
                let key = match key_tok.kind {
                    TokenKind::StringLiteral(s) => s,
                    _ => unreachable!(),
                };
                self.expect(TokenKind::Colon)?;
                let value = self.parse_expr()?;
                entries.push((key, value));
                self.skip_blank_newlines();
                if self.at(TokenKind::Comma) {
                    self.advance();
                    self.skip_blank_newlines();
                    if self.at(TokenKind::RBrace) {
                        break;
                    }
                } else {
                    break;
                }
            }
        }
        self.skip_blank_newlines();
        let end = self.expect(TokenKind::RBrace)?.span;
        Ok(Expr::DictLiteral(entries, start.to(end)))
    }

    fn parse_paren_or_tuple(&mut self, start: Span) -> PResult<Expr> {
        self.advance(); // '('
        if self.at(TokenKind::RParen) {
            let end = self.advance().span;
            return Ok(Expr::TupleLiteral(vec![], start.to(end)));
        }
        let first = self.parse_expr()?;
        if self.at(TokenKind::Comma) {
            let mut items = vec![first];
            while self.at(TokenKind::Comma) {
                self.advance();
                if self.at(TokenKind::RParen) {
                    break;
                }
                items.push(self.parse_expr()?);
            }
            let end = self.expect(TokenKind::RParen)?.span;
            Ok(Expr::TupleLiteral(items, start.to(end)))
        } else {
            self.expect(TokenKind::RParen)?;
            Ok(first)
        }
    }

    fn expect_identifier(&mut self) -> PResult<Token> {
        if let TokenKind::Identifier(_) = self.peek() {
            Ok(self.advance())
        } else {
            let span = self.peek_span();
            self.diagnostics.push(Diagnostic::error(
                "E0013",
                format!("expected an identifier, found {}", self.peek()),
                span,
            ));
            Err(())
        }
    }

    fn expect_identifier_text(&mut self) -> PResult<String> {
        let tok = self.expect_identifier()?;
        Ok(ident_text(&tok))
    }
}

fn lvalue_to_expr(lvalue: LValue, fallback_span: Span) -> Expr {
    match lvalue {
        LValue::Ident(name) => Expr::Identifier(name, fallback_span),
        LValue::Field { base, field, span } => Expr::Field { base, field, span },
        LValue::Index { base, index, span } => Expr::Index { base, index, span },
    }
}

fn ident_text(tok: &Token) -> String {
    match &tok.kind {
        TokenKind::Identifier(name) => name.clone(),
        _ => unreachable!("ident_text called on non-identifier token"),
    }
}

/// Convenience entry point used by the driver and tests.
pub fn parse(tokens: Vec<Token>) -> (Option<Program>, DiagnosticBag) {
    Parser::new(tokens).parse_program()
}
