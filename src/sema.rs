//! Semantic analysis.
//!
//! Walks the AST after parsing and:
//! - resolves every identifier to a declaration and checks for
//!   use-before-declaration / undefined names,
//! - infers types for `name = expr` bindings (and checks explicit
//!   `name: Type = expr` annotations against them),
//! - infers function return types from `return` statements when no
//!   explicit `-> Type` is written (see `Analyzer::check_function` for
//!   how inference is locked in, in source order),
//! - type-checks expressions, collection indexing (1-based, with
//!   compile-time bounds checks wherever the index is a literal),
//!   struct field access, and function call arity/argument types,
//! - enforces `break`/`continue` only appear inside a loop.
//!
//! The output is a [`TypedProgram`], the same shape as the AST, guaranteed
//! (if analysis succeeded) to be well-typed. IR lowering re-derives types
//! structurally rather than threading a symbol table through, so it relies
//! on this guarantee rather than re-checking anything itself.

use crate::ast::*;
use crate::diagnostics::{Diagnostic, DiagnosticBag, Span};
use std::cell::RefCell;
use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct TypedProgram {
    pub structs: Vec<StructDef>,
    pub enums: Vec<EnumDef>,
    pub functions: Vec<Function>,
}

#[derive(Debug, Clone)]
struct VarInfo {
    ty: TypeName,
}

#[derive(Debug, Clone)]
struct FnSig {
    params: Vec<TypeName>,
    /// `None` while this function's return type is still being inferred
    /// (see the return-type-inference docs on `Analyzer::check_function`); always `Some` once analysis of that
    /// function completes.
    return_type: Option<TypeName>,
}

struct Scope {
    vars: HashMap<String, VarInfo>,
}

/// Shared, mutable tables consulted (and, for return types, updated) while
/// checking every function -- wrapped in `RefCell` so that checking
/// function `B` can observe a return type that function `A` locked in
/// earlier in the same pass.
struct Tables {
    functions: RefCell<HashMap<String, FnSig>>,
    structs: HashMap<String, Vec<(String, TypeName)>>,
    /// enum name -> variant names, in declaration order (their index is
    /// the runtime `int` tag -- see `TypeName::Enum`).
    enums: HashMap<String, Vec<String>>,
}

struct Analyzer<'a> {
    tables: &'a Tables,
    scopes: Vec<Scope>,
    /// The return type of the function currently being checked. `None`
    /// means it is still being inferred (see [`Self::check_return`]).
    current_fn: String,
    current_return_type: Option<TypeName>,
    /// Set when a `return <recursive self-call>` was skipped for
    /// inference purposes (see [`Self::is_unresolved_marker`]) -- if the
    /// function's return type is *still* unknown at the end of its body
    /// because of this, that's a genuine "couldn't infer it" error, not
    /// an implicit `Void` function.
    return_inference_blocked: bool,
    loop_depth: u32,
    diagnostics: DiagnosticBag,
}

impl<'a> Analyzer<'a> {
    fn new(tables: &'a Tables) -> Self {
        Self {
            tables,
            scopes: vec![],
            current_fn: String::new(),
            current_return_type: None,
            return_inference_blocked: false,
            loop_depth: 0,
            diagnostics: DiagnosticBag::new(),
        }
    }

    fn push_scope(&mut self) {
        self.scopes.push(Scope {
            vars: HashMap::new(),
        });
    }

    fn pop_scope(&mut self) {
        self.scopes.pop();
    }

    fn declare(&mut self, name: &str, ty: TypeName) {
        self.scopes
            .last_mut()
            .expect("scope active")
            .vars
            .insert(name.to_string(), VarInfo { ty });
    }

    /// Looks up a variable, searching only the current function's scopes
    /// (Kite has no closures in v0.1; each function's scope stack is
    /// fresh).
    fn lookup(&self, name: &str) -> Option<TypeName> {
        for scope in self.scopes.iter().rev() {
            if let Some(info) = scope.vars.get(name) {
                return Some(info.ty.clone());
            }
        }
        None
    }

    fn error(&mut self, code: &'static str, msg: impl Into<String>, span: Span) {
        self.diagnostics.push(Diagnostic::error(code, msg, span));
    }

    fn check_function(&mut self, func: &Function) {
        if func.is_extern {
            // No body to check; the signature was already validated and
            // registered when building the function table.
            return;
        }
        self.push_scope();
        self.current_fn = func.name.clone();
        self.current_return_type = self
            .tables
            .functions
            .borrow()
            .get(&func.name)
            .and_then(|s| s.return_type.clone());
        self.return_inference_blocked = false;
        for param in &func.params {
            self.declare(&param.name, param.ty.clone());
        }

        let body = func
            .body
            .as_ref()
            .expect("non-extern function always has a body");
        let falls_through = self.check_block(body);

        // If we finished the whole body and still don't know the return
        // type: either nothing ever returned a value (a genuine `Void`
        // function), or every `return` we saw was blocked because it
        // depended on this function's own not-yet-known return type
        // (e.g. `return loop(n)` with no base case) -- that's a real
        // inference failure, not an implicit `Void`.
        if self.current_return_type.is_none() {
            if self.return_inference_blocked {
                self.error(
                    "E0060",
                    format!(
                        "cannot infer the return type of `{}` -- no `return` statement resolves without depending on its own return type; add an explicit `-> Type`",
                        func.name
                    ),
                    func.span,
                );
            }
            self.lock_return_type(TypeName::Void);
        }
        let return_type = self.current_return_type.clone().unwrap();

        if falls_through && return_type != TypeName::Void {
            self.error(
                "E0030",
                format!(
                    "function `{}` is declared to return `{return_type}` but does not return a value on all paths",
                    func.name
                ),
                func.span,
            );
        }
        self.pop_scope();
    }

    /// Locks in the current function's return type (used the first time
    /// it can be fully determined) so that later statements in this
    /// function -- and other functions checked afterward -- can see it,
    /// including recursive self-calls.
    fn lock_return_type(&mut self, ty: TypeName) {
        if self.current_return_type.is_none() {
            self.current_return_type = Some(ty.clone());
            self.tables
                .functions
                .borrow_mut()
                .get_mut(&self.current_fn)
                .expect("current function registered")
                .return_type = Some(ty);
        }
    }

    fn check_block(&mut self, block: &Block) -> bool {
        self.push_scope();
        let mut falls_through = true;
        for stmt in &block.statements {
            falls_through = self.check_stmt(stmt);
        }
        self.pop_scope();
        falls_through
    }

    fn check_stmt(&mut self, stmt: &Stmt) -> bool {
        match stmt {
            Stmt::Assign {
                target,
                annotated_type,
                value,
                span,
            } => {
                self.check_assign(target, annotated_type.as_ref(), value, *span);
                true
            }
            Stmt::Expr(expr) => {
                self.check_expr(expr);
                true
            }
            Stmt::Return { value, span } => {
                self.check_return(value.as_ref(), *span);
                false
            }
            Stmt::Break(span) => {
                if self.loop_depth == 0 {
                    self.error("E0040", "`break` outside of a loop", *span);
                }
                false
            }
            Stmt::Continue(span) => {
                if self.loop_depth == 0 {
                    self.error("E0041", "`continue` outside of a loop", *span);
                }
                false
            }
            Stmt::If {
                condition,
                then_branch,
                orif_branches,
                else_branch,
                ..
            } => {
                let cond_ty = self.check_expr(condition);
                self.expect_bool(&cond_ty, condition.span());
                // A branch's own `check_block` returns "falls through"
                // (true = might not return). The if/orif/else chain as a
                // whole falls through if *any* branch does (any path
                // that skips a `return` is a real path through the
                // program) -- so this has to be an OR across branches,
                // not an AND. A missing `else` always falls through
                // unconditionally, since "none of the conditions held"
                // is itself a real path that reaches no `return` at all.
                let mut any_branch_falls_through = self.check_block(then_branch);
                for clause in orif_branches {
                    let ty = self.check_expr(&clause.condition);
                    self.expect_bool(&ty, clause.condition.span());
                    any_branch_falls_through |= self.check_block(&clause.body);
                }
                match else_branch {
                    Some(block) => any_branch_falls_through |= self.check_block(block),
                    None => any_branch_falls_through = true,
                }
                any_branch_falls_through
            }
            Stmt::Until {
                condition, body, ..
            } => {
                let ty = self.check_expr(condition);
                self.expect_bool(&ty, condition.span());
                self.loop_depth += 1;
                self.check_block(body);
                self.loop_depth -= 1;
                true
            }
            Stmt::Infinit { body, .. } => {
                self.loop_depth += 1;
                self.check_block(body);
                self.loop_depth -= 1;
                // An infinite loop with no `break` never falls through;
                // conservatively treat it as always falling through since
                // detecting "definitely no break" isn't load-bearing for
                // correctness (only affects a downstream missing-return
                // lint, and erring toward requiring one final `return` is
                // the safer default).
                true
            }
            Stmt::ForRange {
                var,
                start,
                end,
                body,
                ..
            } => {
                let sty = self.check_expr(start);
                let ety = self.check_expr(end);
                if sty != TypeName::Int {
                    self.error(
                        "E0042",
                        format!("`for` range start must be `int`, found `{sty}`"),
                        start.span(),
                    );
                }
                if ety != TypeName::Int {
                    self.error(
                        "E0042",
                        format!("`for` range end must be `int`, found `{ety}`"),
                        end.span(),
                    );
                }
                self.push_scope();
                self.declare(var, TypeName::Int);
                self.loop_depth += 1;
                self.check_block(body);
                self.loop_depth -= 1;
                self.pop_scope();
                true
            }
            Stmt::ForEach {
                var,
                iterable,
                body,
                ..
            } => {
                let iter_ty = self.check_expr(iterable);
                let elem_ty = match &iter_ty {
                    TypeName::List(elem) => (**elem).clone(),
                    other => {
                        self.error(
                            "E0043",
                            format!("`for ... in` requires a list, found `{other}`"),
                            iterable.span(),
                        );
                        TypeName::Int
                    }
                };
                self.push_scope();
                self.declare(var, elem_ty);
                self.loop_depth += 1;
                self.check_block(body);
                self.loop_depth -= 1;
                self.pop_scope();
                true
            }
            Stmt::Try {
                try_block,
                failed_var,
                failed_block,
                finally_block,
                ..
            } => {
                let try_falls_through = self.check_block(try_block);
                if let Some(fblock) = failed_block {
                    self.push_scope();
                    if let Some(name) = failed_var {
                        self.declare(name, TypeName::String);
                    }
                    self.check_block(fblock);
                    self.pop_scope();
                }
                if let Some(fin) = finally_block {
                    self.check_block(fin);
                }
                try_falls_through
            }
            Stmt::Thread { body, .. } => {
                self.check_block(body);
                true
            }
        }
    }

    fn check_assign(
        &mut self,
        target: &LValue,
        annotated: Option<&TypeName>,
        value: &Expr,
        span: Span,
    ) {
        match target {
            LValue::Ident(name) => {
                // `null` (see `check_expr_expecting`) needs to know what
                // pointer type it's being assigned into *before* it's
                // checked -- an explicit `p: ptr<int> = null` annotation
                // if this is a fresh declaration, or `p`'s already-known
                // type on a plain reassignment (`p = null`).
                let expected = annotated.cloned().or_else(|| self.lookup(name));
                let value_ty = self.check_expr_expecting(value, expected.as_ref());

                if let Some(declared) = annotated {
                    if *declared != value_ty {
                        self.error(
                            "E0020",
                            format!("type mismatch in `{name}`: declared `{declared}`, found `{value_ty}`"),
                            span,
                        );
                    }
                }
                match self.lookup(name) {
                    Some(existing) if existing != value_ty => {
                        self.error(
                            "E0023",
                            format!("type mismatch: `{name}` is `{existing}`, found `{value_ty}`"),
                            span,
                        );
                    }
                    Some(_) => {}
                    None => {
                        let final_ty = annotated.cloned().unwrap_or(value_ty);
                        self.declare(name, final_ty);
                    }
                }
            }
            LValue::Field { base, field, span } => {
                let value_ty = self.check_expr(value);
                let base_ty = self.check_expr(base);
                if matches!(
                    base.as_ref(),
                    Expr::Unary {
                        op: UnOp::Deref,
                        ..
                    }
                ) {
                    self.error(
                        "E0099",
                        "assigning a field through a dereferenced pointer isn't supported yet -- \
                         write `s = *p` first, then assign `s.field = ...` (this copies the \
                         struct rather than mutating through `p`, see docs/pointers.md)",
                        *span,
                    );
                    return;
                }
                if let Some(field_ty) = self.resolve_field(&base_ty, field, *span) {
                    if field_ty != value_ty {
                        self.error(
                            "E0044",
                            format!("type mismatch: field `{field}` is `{field_ty}`, found `{value_ty}`"),
                            *span,
                        );
                    }
                }
            }
            LValue::Index { base, index, span } => {
                let value_ty = self.check_expr(value);
                let base_ty = self.check_expr(base);
                if matches!(
                    base.as_ref(),
                    Expr::Unary {
                        op: UnOp::Deref,
                        ..
                    }
                ) {
                    self.error(
                        "E0099",
                        "assigning an element through a dereferenced pointer isn't supported yet -- \
                         write `s = *p` first, then assign `s[i] = ...`",
                        *span,
                    );
                    return;
                }
                let elem_ty = self.check_index(&base_ty, index, *span);
                if let Some(elem_ty) = elem_ty {
                    if elem_ty != value_ty {
                        self.error(
                            "E0045",
                            format!("type mismatch: element is `{elem_ty}`, found `{value_ty}`"),
                            *span,
                        );
                    }
                }
            }
            LValue::Deref {
                target: ptr_expr,
                span,
            } => {
                let ptr_ty = self.check_expr(ptr_expr);
                let pointee = match &ptr_ty {
                    TypeName::Ptr(inner) => Some((**inner).clone()),
                    other => {
                        self.error(
                            "E0089",
                            format!("cannot dereference `{other}`: not a pointer"),
                            *span,
                        );
                        None
                    }
                };
                let value_ty = self.check_expr_expecting(value, pointee.as_ref());
                if let Some(pointee) = pointee {
                    if pointee != value_ty {
                        self.error(
                            "E0090",
                            format!(
                                "type mismatch: writing `{value_ty}` through a `ptr<{pointee}>`"
                            ),
                            *span,
                        );
                    }
                }
            }
        }
    }

    /// Like `check_expr`, but resolves `null` from `expected` (used
    /// where the expected pointer type is already known: an annotated
    /// or already-declared assignment target, or the other side of a
    /// `==`/`!=` comparison) instead of always erroring on it. Every
    /// other expression kind behaves exactly like `check_expr`.
    fn check_expr_expecting(&mut self, expr: &Expr, expected: Option<&TypeName>) -> TypeName {
        if let Expr::NullLit(span) = expr {
            return match expected {
                Some(TypeName::Ptr(inner)) => TypeName::Ptr(inner.clone()),
                Some(other) => {
                    self.error("E0091", format!("`null` is not a valid `{other}`"), *span);
                    TypeName::Int
                }
                None => {
                    self.error(
                        "E0091",
                        "cannot infer the pointer type of `null` here -- annotate it, e.g. `p: ptr<int> = null`",
                        *span,
                    );
                    TypeName::Int
                }
            };
        }
        self.check_expr(expr)
    }

    fn check_return(&mut self, value: Option<&Expr>, span: Span) {
        let actual = value.map(|e| self.check_expr(e)).unwrap_or(TypeName::Void);
        match self.current_return_type.clone() {
            Some(expected) => {
                if actual != expected {
                    self.error(
                        "E0031",
                        format!("mismatched return type: expected `{expected}`, found `{actual}`"),
                        span,
                    );
                }
            }
            None => {
                // First (resolvable) return statement in this function:
                // lock in its type. `actual` can only be `Void`-via-error
                // if `check_expr` hit an unresolved self-referential call;
                // in that case we deliberately do NOT lock, so a later
                // `return` statement gets a chance to establish the type.
                if self.is_unresolved_marker(value) {
                    self.return_inference_blocked = true;
                } else if !is_first_class_value(&actual) {
                    self.error(
                        "E0039",
                        format!(
                            "function `{}` may not return `{actual}` -- functions may only return `int`/`float`/`bool`/`string`/nothing in Kite v0.1",
                            self.current_fn
                        ),
                        span,
                    );
                    self.lock_return_type(TypeName::Void);
                } else {
                    self.lock_return_type(actual);
                }
            }
        }
    }

    /// True if `expr` is exactly a call to the function currently being
    /// inferred (or transitively depends on one) such that its type
    /// couldn't be resolved. We detect this narrowly: `check_call` returns
    /// `TypeName::Void` for a call whose callee return type is still
    /// unknown, so a bare recursive call used directly as `return
    /// self_call(...)` is recognized here and skipped for inference
    /// purposes rather than incorrectly locking in `Void`.
    fn is_unresolved_marker(&self, value: Option<&Expr>) -> bool {
        matches!(value, Some(Expr::Call { name, .. }) if *name == self.current_fn && self.current_return_type.is_none())
    }

    fn expect_bool(&mut self, ty: &TypeName, span: Span) {
        if *ty != TypeName::Bool {
            self.error(
                "E0024",
                format!("expected `bool` condition, found `{ty}`"),
                span,
            );
        }
    }

    fn check_expr(&mut self, expr: &Expr) -> TypeName {
        match expr {
            Expr::IntLiteral(..) => TypeName::Int,
            Expr::FloatLiteral(..) => TypeName::Float,
            Expr::BoolLiteral(..) => TypeName::Bool,
            Expr::StringLiteral(..) => TypeName::String,
            Expr::Identifier(name, span) => match self.lookup(name) {
                Some(ty) => ty,
                None => {
                    self.error(
                        "E0021",
                        format!("cannot find variable `{name}` in this scope"),
                        *span,
                    );
                    TypeName::Int
                }
            },
            Expr::ListLiteral(items, span) => self.check_list_literal(items, *span),
            Expr::TupleLiteral(items, _) => {
                let tys: Vec<TypeName> = items.iter().map(|i| self.check_expr(i)).collect();
                for (item, ty) in items.iter().zip(tys.iter()) {
                    if !is_scalar(ty) {
                        self.error(
                            "E0047c",
                            format!("tuple elements must be `int`, `float`, `bool`, or `string` in Kite v0.1, found `{ty}` (nested collections are planned for v0.2)"),
                            item.span(),
                        );
                    }
                }
                TypeName::Tuple(tys)
            }
            Expr::DictLiteral(entries, span) => self.check_dict_literal(entries, *span),
            Expr::Index { base, index, span } => {
                let base_ty = self.check_expr(base);
                self.check_index(&base_ty, index, *span)
                    .unwrap_or(TypeName::Int)
            }
            Expr::Field { base, field, span } => {
                // `EnumName.Variant` -- the base is a *type* name, not a
                // variable, so it must be resolved before falling back to
                // the normal (struct instance) field-access path, which
                // would otherwise report "cannot find variable EnumName".
                if let Expr::Identifier(name, _) = base.as_ref() {
                    if let Some(variants) = self.tables.enums.get(name) {
                        if !variants.iter().any(|v| v == field) {
                            self.error(
                                "E0072",
                                format!("enum `{name}` has no variant `{field}`"),
                                *span,
                            );
                        }
                        return TypeName::Enum(name.clone());
                    }
                }
                let base_ty = self.check_expr(base);
                if matches!(
                    base.as_ref(),
                    Expr::Unary {
                        op: UnOp::Deref,
                        ..
                    }
                ) {
                    self.error(
                        "E0099",
                        "reading a field through a dereferenced pointer isn't supported yet -- \
                         write `s = *p` first, then use `s.field` (this copies the struct rather \
                         than reading through `p`, see docs/pointers.md)",
                        *span,
                    );
                    return TypeName::Int;
                }
                self.resolve_field(&base_ty, field, *span)
                    .unwrap_or(TypeName::Int)
            }
            Expr::Unary { op, expr, span } => self.check_unary(*op, expr, *span),
            Expr::Binary { op, lhs, rhs, span } => self.check_binary(*op, lhs, rhs, *span),
            Expr::Call { name, args, span } => self.check_call(name, args, *span),
            Expr::Await { expr, .. } => self.check_expr(expr),
            Expr::NullLit(span) => {
                self.error(
                    "E0091",
                    "cannot infer the pointer type of `null` here -- annotate it, e.g. `p: ptr<int> = null`",
                    *span,
                );
                TypeName::Int
            }
            Expr::Alloc { ty, span } => self.check_alloc(ty, *span),
            Expr::AllocN { ty, count, span } => {
                let count_ty = self.check_expr(count);
                if count_ty != TypeName::Int {
                    self.error(
                        "E0093",
                        format!("`alloc_n` expects an `int` count, found `{count_ty}`"),
                        count.span(),
                    );
                }
                self.check_alloc(ty, *span)
            }
        }
    }

    /// Shared validation for `alloc(T)`/`alloc_n(T, ...)`: `T` must be a
    /// scalar or a known struct -- `ptr<ptr<T>>` (allocating storage for
    /// a pointer-to-a-pointer) and allocating a list/tuple/dict aren't
    /// supported yet (see `docs/pointers.md`).
    fn check_alloc(&mut self, ty: &TypeName, span: Span) -> TypeName {
        match ty {
            TypeName::Ptr(_) => {
                self.error(
                    "E0092",
                    "`alloc`/`alloc_n` of a `ptr<...>` isn't supported yet -- pointers to pointers aren't implemented",
                    span,
                );
            }
            TypeName::List(_) | TypeName::Tuple(_) | TypeName::Dict(_) => {
                self.error(
                    "E0092",
                    format!("`alloc`/`alloc_n` of `{ty}` isn't supported yet -- only scalar types and structs can be allocated"),
                    span,
                );
            }
            TypeName::Struct(name) if !self.tables.structs.contains_key(name) => {
                self.error("E0058", format!("unknown type `{name}`"), span);
            }
            _ => {}
        }
        TypeName::Ptr(Box::new(ty.clone()))
    }

    fn check_list_literal(&mut self, items: &[Expr], span: Span) -> TypeName {
        if items.is_empty() {
            self.error(
                "E0046",
                "empty list literals need a type; write at least one element (e.g. `[0]` then remove it with future list ops)",
                span,
            );
            return TypeName::List(Box::new(TypeName::Int));
        }
        let first_ty = self.check_expr(&items[0]);
        if !is_scalar(&first_ty) {
            self.error(
                "E0047b",
                format!("list elements must be `int`, `float`, `bool`, or `string` in Kite v0.1, found `{first_ty}` (nested collections are planned for v0.2)"),
                items[0].span(),
            );
        }
        for item in &items[1..] {
            let ty = self.check_expr(item);
            if ty != first_ty {
                self.error(
                    "E0047",
                    format!("list elements must share one type: found `{first_ty}` and `{ty}`"),
                    item.span(),
                );
            }
        }
        TypeName::List(Box::new(first_ty))
    }

    fn check_dict_literal(&mut self, entries: &[(String, Expr)], span: Span) -> TypeName {
        let mut fields = Vec::new();
        let mut seen = std::collections::HashSet::new();
        for (key, value) in entries {
            if !seen.insert(key.clone()) {
                self.error("E0048", format!("duplicate dictionary key \"{key}\""), span);
            }
            let ty = self.check_expr(value);
            if !is_scalar(&ty) {
                self.error(
                    "E0047d",
                    format!("dictionary values must be `int`, `float`, `bool`, or `string` in Kite v0.1, found `{ty}` (nested collections are planned for v0.2)"),
                    value.span(),
                );
            }
            fields.push((key.clone(), ty));
        }
        TypeName::Dict(fields)
    }

    /// Checks a collection index expression (`base[index]`), enforcing
    /// Kite's 1-based indexing and returning the resulting element type.
    fn check_index(&mut self, base_ty: &TypeName, index: &Expr, span: Span) -> Option<TypeName> {
        let index_ty = self.check_expr(index);
        if index_ty != TypeName::Int {
            match base_ty {
                TypeName::Dict(_) if index_ty == TypeName::String => {}
                _ => {
                    self.error(
                        "E0049",
                        format!("index must be `int`, found `{index_ty}`"),
                        index.span(),
                    );
                }
            }
        }

        match base_ty {
            // Lists are dynamically sized (see `TypeName::List`), so
            // out-of-range indices can't be ruled out at compile time even
            // for a literal index; codegen always emits a runtime bounds
            // check (Kite lists are 1-indexed: valid indices are
            // `1..=len(list)`).
            TypeName::List(elem) => Some((**elem).clone()),
            TypeName::Tuple(elems) => match index {
                Expr::IntLiteral(v, ispan) => {
                    if *v < 1 || *v as usize > elems.len() {
                        self.error(
                                "E0051",
                                format!("index {v} is out of range for a tuple of size {} (tuples are 1-indexed)", elems.len()),
                                *ispan,
                            );
                        None
                    } else {
                        Some(elems[*v as usize - 1].clone())
                    }
                }
                _ => {
                    self.error("E0052", "tuple index must be an integer literal (tuple elements can have different types)", index.span());
                    None
                }
            },
            TypeName::Dict(fields) => match index {
                Expr::StringLiteral(key, kspan) => match fields.iter().find(|(k, _)| k == key) {
                    Some((_, ty)) => Some(ty.clone()),
                    None => {
                        self.error("E0053", format!("dictionary has no key \"{key}\""), *kspan);
                        None
                    }
                },
                _ => {
                    self.error(
                        "E0054",
                        "dictionary index must be a string literal key",
                        index.span(),
                    );
                    None
                }
            },
            other => {
                self.error(
                    "E0055",
                    format!("cannot index into a value of type `{other}`"),
                    span,
                );
                None
            }
        }
    }

    fn resolve_field(&mut self, base_ty: &TypeName, field: &str, span: Span) -> Option<TypeName> {
        match base_ty {
            TypeName::Struct(name) => match self.tables.structs.get(name) {
                Some(fields) => match fields.iter().find(|(f, _)| f == field) {
                    Some((_, ty)) => Some(ty.clone()),
                    None => {
                        self.error(
                            "E0056",
                            format!("struct `{name}` has no field `{field}`"),
                            span,
                        );
                        None
                    }
                },
                None => {
                    self.error("E0057", format!("unknown struct type `{name}`"), span);
                    None
                }
            },
            other => {
                self.error(
                    "E0058",
                    format!("cannot access field `{field}` on a value of type `{other}`"),
                    span,
                );
                None
            }
        }
    }

    fn check_unary(&mut self, op: UnOp, expr: &Expr, span: Span) -> TypeName {
        if op == UnOp::AddrOf {
            // `&x` -- only a plain local variable is addressable in
            // v0.1.3 (not `&(x + 1)`, not yet `&struct_var` -- see
            // `docs/pointers.md`). Checked before `check_expr(expr)`
            // below so the "not addressable" error doesn't also drag in
            // an unrelated one from evaluating a non-identifier
            // sub-expression.
            let Expr::Identifier(name, ident_span) = expr else {
                self.error(
                    "E0094",
                    "`&` can only take the address of a local variable, e.g. `&x`",
                    span,
                );
                return TypeName::Ptr(Box::new(TypeName::Int));
            };
            let ty = match self.lookup(name) {
                Some(ty) => ty,
                None => {
                    self.error(
                        "E0021",
                        format!("cannot find variable `{name}` in this scope"),
                        *ident_span,
                    );
                    TypeName::Int
                }
            };
            if !is_scalar(&ty) {
                self.error(
                    "E0095",
                    format!("cannot take the address of a `{ty}` yet -- only `int`/`float`/`bool`/`string` locals are addressable in v0.1.3"),
                    span,
                );
            }
            return TypeName::Ptr(Box::new(ty));
        }

        let ty = self.check_expr(expr);
        match op {
            UnOp::Neg => {
                if ty != TypeName::Int && ty != TypeName::Float {
                    self.error(
                        "E0025",
                        format!("cannot negate a value of type `{ty}`"),
                        span,
                    );
                }
                ty
            }
            UnOp::Not => {
                if ty != TypeName::Bool {
                    self.error(
                        "E0026",
                        format!("cannot apply `not` to a value of type `{ty}`"),
                        span,
                    );
                }
                TypeName::Bool
            }
            UnOp::Deref => match ty {
                TypeName::Ptr(inner) => *inner,
                other => {
                    self.error(
                        "E0089",
                        format!("cannot dereference `{other}`: not a pointer"),
                        span,
                    );
                    TypeName::Int
                }
            },
            UnOp::AddrOf => unreachable!("handled above"),
        }
    }

    fn check_binary(&mut self, op: BinOp, lhs: &Expr, rhs: &Expr, span: Span) -> TypeName {
        use BinOp::*;

        // `null` needs to borrow its type from the *other* operand (see
        // `check_expr_expecting`) -- so for `==`/`!=` specifically,
        // check one side first and feed its type in as a hint for the
        // other, instead of checking both sides context-free like every
        // other operator does.
        if matches!(op, Eq | NotEq) {
            let (lty, rty) = match (lhs, rhs) {
                (Expr::NullLit(_), _) => {
                    let rty = self.check_expr(rhs);
                    let lty = self.check_expr_expecting(lhs, Some(&rty));
                    (lty, rty)
                }
                _ => {
                    let lty = self.check_expr(lhs);
                    let rty = self.check_expr_expecting(rhs, Some(&lty));
                    (lty, rty)
                }
            };
            if lty != rty {
                self.error(
                    "E0028",
                    format!(
                        "cannot compare `{lty}` and `{rty}` with `{}`",
                        op_symbol(op)
                    ),
                    span,
                );
            }
            return TypeName::Bool;
        }

        let lty = self.check_expr(lhs);
        let rty = self.check_expr(rhs);
        match op {
            Add | Sub => {
                if op == Add && lty == TypeName::String && rty == TypeName::String {
                    return TypeName::String;
                }
                // Pointer arithmetic: `p + n`/`p - n` moves `p` by `n`
                // elements (not bytes -- codegen scales by `sizeof(T)`).
                // `n + p` is accepted too (matches C); `n - p` is not,
                // same as C, since "int minus an address" isn't a
                // pointer.
                match (&lty, &rty) {
                    (TypeName::Ptr(_), TypeName::Int) => return lty,
                    (TypeName::Int, TypeName::Ptr(_)) if op == Add => return rty,
                    _ => {}
                }
                if lty != rty || (lty != TypeName::Int && lty != TypeName::Float) {
                    self.error(
                        "E0027",
                        format!("cannot apply arithmetic operator to `{lty}` and `{rty}`"),
                        span,
                    );
                    TypeName::Int
                } else {
                    lty
                }
            }
            Mul | Div | Mod => {
                if lty != rty || (lty != TypeName::Int && lty != TypeName::Float) {
                    self.error(
                        "E0027",
                        format!("cannot apply arithmetic operator to `{lty}` and `{rty}`"),
                        span,
                    );
                    TypeName::Int
                } else if op == Mod && lty == TypeName::Float {
                    self.error("E0027", "the `%` operator requires `int` operands", span);
                    TypeName::Float
                } else {
                    lty
                }
            }
            Lt | Gt | LtEq | GtEq => {
                if lty != rty || (lty != TypeName::Int && lty != TypeName::Float) {
                    self.error(
                        "E0028",
                        format!(
                            "cannot compare `{lty}` and `{rty}` with `{}`",
                            op_symbol(op)
                        ),
                        span,
                    );
                }
                TypeName::Bool
            }
            Eq | NotEq => unreachable!("handled above"),
            And | Or => {
                if lty != TypeName::Bool || rty != TypeName::Bool {
                    self.error(
                        "E0029",
                        format!(
                            "operator `{}` requires `bool` operands, found `{lty}` and `{rty}`",
                            op_symbol(op)
                        ),
                        span,
                    );
                }
                TypeName::Bool
            }
        }
    }

    fn check_call(&mut self, name: &str, args: &[Expr], span: Span) -> TypeName {
        if name == "print" {
            if args.len() != 1 {
                self.error(
                    "E0032",
                    format!("`print` takes exactly 1 argument, found {}", args.len()),
                    span,
                );
            }
            for arg in args {
                self.check_expr(arg);
            }
            return TypeName::Void;
        }

        if name == "append" {
            if args.len() != 2 {
                self.error(
                    "E0062",
                    format!(
                        "`append` takes exactly 2 arguments (list, value), found {}",
                        args.len()
                    ),
                    span,
                );
                for a in args {
                    self.check_expr(a);
                }
                return TypeName::Void;
            }
            let list_ty = self.check_expr(&args[0]);
            let value_ty = self.check_expr(&args[1]);
            match &list_ty {
                TypeName::List(elem) => {
                    if **elem != value_ty {
                        self.error(
                            "E0063",
                            format!("cannot append a `{value_ty}` to a list of `{elem}`"),
                            args[1].span(),
                        );
                    }
                }
                other => {
                    self.error(
                        "E0064",
                        format!("`append` expects a list as its first argument, found `{other}`"),
                        args[0].span(),
                    );
                }
            }
            return TypeName::Void;
        }

        if name == "len" {
            if args.len() != 1 {
                self.error(
                    "E0065",
                    format!("`len` takes exactly 1 argument, found {}", args.len()),
                    span,
                );
            }
            if let Some(arg) = args.first() {
                let ty = self.check_expr(arg);
                if !matches!(ty, TypeName::List(_) | TypeName::String) {
                    self.error(
                        "E0066",
                        format!("`len` expects a list or string, found `{ty}`"),
                        arg.span(),
                    );
                }
            }
            return TypeName::Int;
        }

        if name == "char_at" {
            if args.len() != 2 {
                self.error(
                    "E0075",
                    format!(
                        "`char_at` takes exactly 2 arguments (string, index), found {}",
                        args.len()
                    ),
                    span,
                );
            }
            if let Some(s) = args.first() {
                let ty = self.check_expr(s);
                if ty != TypeName::String {
                    self.error(
                        "E0076",
                        format!("`char_at` expects a string, found `{ty}`"),
                        s.span(),
                    );
                }
            }
            if let Some(i) = args.get(1) {
                let ty = self.check_expr(i);
                if ty != TypeName::Int {
                    self.error(
                        "E0077",
                        format!("`char_at` expects an `int` index, found `{ty}`"),
                        i.span(),
                    );
                }
            }
            return TypeName::Int;
        }

        if name == "substr" {
            if args.len() != 3 {
                self.error(
                    "E0078",
                    format!(
                        "`substr` takes exactly 3 arguments (string, start, end), found {}",
                        args.len()
                    ),
                    span,
                );
            }
            if let Some(s) = args.first() {
                let ty = self.check_expr(s);
                if ty != TypeName::String {
                    self.error(
                        "E0079",
                        format!("`substr` expects a string, found `{ty}`"),
                        s.span(),
                    );
                }
            }
            for a in args.iter().skip(1) {
                let ty = self.check_expr(a);
                if ty != TypeName::Int {
                    self.error(
                        "E0080",
                        format!("`substr` expects `int` bounds, found `{ty}`"),
                        a.span(),
                    );
                }
            }
            return TypeName::String;
        }

        if name == "read_file" {
            if args.len() != 1 {
                self.error(
                    "E0081",
                    format!(
                        "`read_file` takes exactly 1 argument (path), found {}",
                        args.len()
                    ),
                    span,
                );
            }
            if let Some(a) = args.first() {
                let ty = self.check_expr(a);
                if ty != TypeName::String {
                    self.error(
                        "E0082",
                        format!("`read_file` expects a string path, found `{ty}`"),
                        a.span(),
                    );
                }
            }
            // No real error type exists yet (see docs/architecture.md) --
            // a missing/unreadable file yields `""` rather than aborting
            // or raising. Callers that need to tell "empty file" apart
            // from "couldn't open it" have no way to today; that's a
            // real gap, not an oversight.
            return TypeName::String;
        }

        if name == "write_file" {
            if args.len() != 2 {
                self.error(
                    "E0083",
                    format!(
                        "`write_file` takes exactly 2 arguments (path, content), found {}",
                        args.len()
                    ),
                    span,
                );
            }
            if let Some(a) = args.first() {
                let ty = self.check_expr(a);
                if ty != TypeName::String {
                    self.error(
                        "E0084",
                        format!("`write_file` expects a string path, found `{ty}`"),
                        a.span(),
                    );
                }
            }
            if let Some(a) = args.get(1) {
                let ty = self.check_expr(a);
                if ty != TypeName::String {
                    self.error(
                        "E0085",
                        format!("`write_file` expects string content, found `{ty}`"),
                        a.span(),
                    );
                }
            }
            return TypeName::Bool;
        }

        if name == "arg_count" {
            if !args.is_empty() {
                self.error(
                    "E0086",
                    format!("`arg_count` takes no arguments, found {}", args.len()),
                    span,
                );
            }
            return TypeName::Int;
        }

        if name == "arg" {
            if args.len() != 1 {
                self.error(
                    "E0087",
                    format!(
                        "`arg` takes exactly 1 argument (a 1-based index), found {}",
                        args.len()
                    ),
                    span,
                );
            }
            if let Some(a) = args.first() {
                let ty = self.check_expr(a);
                if ty != TypeName::Int {
                    self.error(
                        "E0088",
                        format!("`arg` expects an `int` index, found `{ty}`"),
                        a.span(),
                    );
                }
            }
            return TypeName::String;
        }

        if name == "free" {
            if args.len() != 1 {
                self.error(
                    "E0096",
                    format!(
                        "`free` takes exactly 1 argument (a pointer), found {}",
                        args.len()
                    ),
                    span,
                );
            }
            if let Some(a) = args.first() {
                let ty = self.check_expr(a);
                if !matches!(ty, TypeName::Ptr(_)) {
                    self.error(
                        "E0097",
                        format!("`free` expects a `ptr<T>`, found `{ty}`"),
                        a.span(),
                    );
                }
            }
            return TypeName::Void;
        }

        // Struct construction: `User()`.
        if self.tables.structs.contains_key(name) {
            if !args.is_empty() {
                self.error(
                    "E0059",
                    format!("struct constructor `{name}()` takes no arguments"),
                    span,
                );
            }
            return TypeName::Struct(name.to_string());
        }

        let sig = self.tables.functions.borrow().get(name).cloned();
        let Some(sig) = sig else {
            self.error(
                "E0033",
                format!("cannot find function `{name}` in this scope"),
                span,
            );
            for arg in args {
                self.check_expr(arg);
            }
            return TypeName::Int;
        };

        if args.len() != sig.params.len() {
            self.error(
                "E0034",
                format!(
                    "function `{name}` expects {} argument(s), found {}",
                    sig.params.len(),
                    args.len()
                ),
                span,
            );
        }
        for (i, arg) in args.iter().enumerate() {
            let arg_ty = self.check_expr(arg);
            if let Some(expected) = sig.params.get(i) {
                if *expected != arg_ty {
                    self.error(
                        "E0035",
                        format!(
                            "argument {} to `{name}` has type `{arg_ty}`, expected `{expected}`",
                            i + 1
                        ),
                        arg.span(),
                    );
                }
            }
        }

        // `sig.return_type` is `None` exactly when `name` is the function
        // currently being inferred and we've recursed back into it before
        // its first resolvable `return`. Report that call site as `Void`
        // for now; `check_return`'s `is_unresolved_marker` recognizes this
        // shape (`return name(...)`) and defers locking instead of
        // treating it as a real `Void` result. Any *other* use of such a
        // call (e.g. `let x = name(...) + 1`) genuinely cannot be
        // typed yet, so it is reported as a real error.
        match sig.return_type {
            Some(ty) => ty,
            None => {
                if name != self.current_fn {
                    self.error(
                        "E0060",
                        format!(
                            "cannot infer the return type of `{name}` here because it is still being inferred; \
                             add an explicit `-> Type` to `{name}` (or to `{}`) to break the cycle",
                            self.current_fn
                        ),
                        span,
                    );
                }
                TypeName::Void
            }
        }
    }
}

fn is_scalar(ty: &TypeName) -> bool {
    matches!(
        ty,
        TypeName::Int
            | TypeName::Float
            | TypeName::Bool
            | TypeName::String
            | TypeName::Enum(_)
            | TypeName::Ptr(_)
    )
}

/// Kite v0.1 keeps lists/tuples/dicts/structs local to the function that
/// creates them -- they can never be passed as an argument or returned
/// (this is what lets IR lowering assume an aggregate is always addressed
/// by a plain local name; see `ir.rs` module docs). Passing them across a
/// function boundary isn't supported yet -- doing that needs a real
/// calling convention for aggregates, not designed yet.
fn is_first_class_value(ty: &TypeName) -> bool {
    is_scalar(ty) || matches!(ty, TypeName::Void)
}

fn op_symbol(op: BinOp) -> &'static str {
    use BinOp::*;
    match op {
        Add => "+",
        Sub => "-",
        Mul => "*",
        Div => "/",
        Mod => "%",
        Eq => "==",
        NotEq => "!=",
        Lt => "<",
        Gt => ">",
        LtEq => "<=",
        GtEq => ">=",
        And => "and",
        Or => "or",
    }
}

/// Runs semantic analysis over an entire (single-file) program.
pub fn analyze(program: &Program) -> (Option<TypedProgram>, DiagnosticBag) {
    analyze_impl(program, |_name| None, true)
}

/// Runs semantic analysis over a program merged from multiple files (see
/// `driver.rs`'s multi-file loader), attributing each function's and
/// struct's own diagnostics back to the file it was actually declared in
/// -- `origins` maps a function or struct name to `(filename, source
/// text)`. Whole-program diagnostics that aren't about one specific
/// function/struct (duplicate definitions, a missing `main`) render
/// against whichever file the driver treats as "primary" (the entry
/// file), same as before.
pub fn analyze_multi_file(
    program: &Program,
    origins: &HashMap<String, (String, String)>,
) -> (Option<TypedProgram>, DiagnosticBag) {
    analyze_impl(program, |name| origins.get(name).cloned(), true)
}

/// Like [`analyze_multi_file`], but for `kite build --freestanding`:
/// freestanding code is a library of functions meant to be linked into
/// another (typically C/kernel) build, not a standalone program, so it
/// doesn't need a `make main():` entry point.
pub fn analyze_multi_file_freestanding(
    program: &Program,
    origins: &HashMap<String, (String, String)>,
) -> (Option<TypedProgram>, DiagnosticBag) {
    analyze_impl(program, |name| origins.get(name).cloned(), false)
}

fn analyze_impl(
    program: &Program,
    origin_of: impl Fn(&str) -> Option<(String, String)>,
    require_main: bool,
) -> (Option<TypedProgram>, DiagnosticBag) {
    let mut diagnostics = DiagnosticBag::new();

    // Pass 0: enum tables, then rewrite every type annotation the parser
    // wrote as `TypeName::Struct(name)` (its default guess for *any*
    // bare identifier in type position, since the grammar can't tell a
    // struct name from an enum name apart without a symbol table) into
    // `TypeName::Enum(name)` wherever `name` actually names an enum. This
    // gives every later pass (including IR lowering, which re-derives
    // types structurally from this rewritten AST) an unambiguous type.
    let mut enum_variants = HashMap::new();
    for e in &program.enums {
        let before = diagnostics_len(&diagnostics);
        let mut seen = std::collections::HashSet::new();
        for v in &e.variants {
            if !seen.insert(v.name.clone()) {
                diagnostics.push(Diagnostic::error(
                    "E0073",
                    format!("enum `{}` has a duplicate variant `{}`", e.name, v.name),
                    v.span,
                ));
            }
        }
        if enum_variants
            .insert(
                e.name.clone(),
                e.variants
                    .iter()
                    .map(|v| v.name.clone())
                    .collect::<Vec<_>>(),
            )
            .is_some()
        {
            diagnostics.push(Diagnostic::error(
                "E0069",
                format!("enum `{}` is defined multiple times", e.name),
                e.span,
            ));
        }
        tag_new_diagnostics(&mut diagnostics, before, &origin_of, &e.name);
    }
    let struct_names: std::collections::HashSet<&str> =
        program.structs.iter().map(|s| s.name.as_str()).collect();
    for e in &program.enums {
        if struct_names.contains(e.name.as_str()) {
            diagnostics.push(Diagnostic::error(
                "E0074",
                format!("`{}` is defined as both a struct and an enum", e.name),
                e.span,
            ));
        }
    }
    let program = resolve_named_types(program, &enum_variants);
    let program = &program;

    // Pass 1: struct field tables (field types are restricted to scalars
    // and other struct names by the parser, so no forward-reference
    // resolution is needed here beyond existence checks, done lazily on
    // first field access).
    let mut structs = HashMap::new();
    for s in &program.structs {
        let before = diagnostics_len(&diagnostics);
        for field in &s.fields {
            if !is_scalar(&field.ty) {
                diagnostics.push(Diagnostic::error(
                    "E0067",
                    format!("field `{}` of struct `{}` has type `{}`, but struct fields must be `int`/`float`/`bool`/`string` in Kite v0.1", field.name, s.name, field.ty),
                    field.span,
                ).with_help("nested structs/collections are planned for v0.2"));
            }
        }
        if structs
            .insert(
                s.name.clone(),
                s.fields
                    .iter()
                    .map(|f| (f.name.clone(), f.ty.clone()))
                    .collect::<Vec<_>>(),
            )
            .is_some()
        {
            diagnostics.push(Diagnostic::error(
                "E0061",
                format!("struct `{}` is defined multiple times", s.name),
                s.span,
            ));
        }
        tag_new_diagnostics(&mut diagnostics, before, &origin_of, &s.name);
    }

    // Pass 2: function signatures. Declared return types are registered
    // immediately; inferred ones start as `None` and get locked in by
    // `Analyzer::check_function` while bodies are checked below, in
    // declaration order.
    let mut functions = HashMap::new();
    for func in &program.functions {
        let before = diagnostics_len(&diagnostics);
        for param in &func.params {
            if !is_scalar(&param.ty) {
                diagnostics.push(Diagnostic::error(
                    "E0038",
                    format!("parameter `{}` has type `{}`, but functions may only take `int`/`float`/`bool`/`string` parameters in Kite v0.1", param.name, param.ty),
                    param.span,
                ).with_help("lists, tuples, dicts, and structs are local-only in v0.1 (planned for v0.2)"));
            }
        }
        if let Some(rt) = &func.declared_return_type {
            if !is_first_class_value(rt) {
                diagnostics.push(Diagnostic::error(
                    "E0039",
                    format!("function `{}` may not return `{rt}` -- functions may only return `int`/`float`/`bool`/`string`/nothing in Kite v0.1", func.name),
                    func.span,
                ).with_help("lists, tuples, dicts, and structs are local-only in v0.1 (planned for v0.2)"));
            }
        }
        let return_type = if func.is_extern {
            Some(func.declared_return_type.clone().unwrap_or(TypeName::Void))
        } else {
            func.declared_return_type.clone()
        };
        if functions
            .insert(
                func.name.clone(),
                FnSig {
                    params: func.params.iter().map(|p| p.ty.clone()).collect(),
                    return_type,
                },
            )
            .is_some()
        {
            diagnostics.push(Diagnostic::error(
                "E0036",
                format!("function `{}` is defined multiple times", func.name),
                func.span,
            ));
        }
        tag_new_diagnostics(&mut diagnostics, before, &origin_of, &func.name);
    }

    if require_main && !functions.contains_key("main") {
        diagnostics.push(
            Diagnostic::error("E0037", "no `main` function found", Span::dummy())
                .with_help("every Kite program needs a `make main():` entry point"),
        );
    }

    let tables = Tables {
        functions: RefCell::new(functions),
        structs,
        enums: enum_variants,
    };
    let mut analyzer = Analyzer::new(&tables);
    for func in &program.functions {
        let before = analyzer.diagnostics.iter().count();
        analyzer.check_function(func);
        tag_new_diagnostics(&mut analyzer.diagnostics, before, &origin_of, &func.name);
    }
    for d in diagnostics.into_vec() {
        analyzer.diagnostics.push(d);
    }

    let had_errors = analyzer.diagnostics.had_errors();
    let typed = if had_errors {
        None
    } else {
        Some(TypedProgram {
            structs: program.structs.clone(),
            enums: program.enums.clone(),
            functions: program.functions.clone(),
        })
    };
    (typed, analyzer.diagnostics)
}

fn diagnostics_len(bag: &DiagnosticBag) -> usize {
    bag.iter().count()
}

/// Retroactively attributes every diagnostic added to `bag` since index
/// `before` to the file `name` (a function or struct name) originated
/// from, if `origin_of` knows one -- used so multi-file compilation
/// reports each error against the actual file it came from rather than
/// whichever file the driver treats as "primary".
fn tag_new_diagnostics(
    bag: &mut DiagnosticBag,
    before: usize,
    origin_of: &impl Fn(&str) -> Option<(String, String)>,
    name: &str,
) {
    let Some((file, src)) = origin_of(name) else {
        return;
    };
    let mut all: Vec<Diagnostic> = std::mem::take(bag).into_vec();
    for d in all.iter_mut().skip(before) {
        if d.file_override.is_none() {
            d.file_override = Some((file.clone(), src.clone()));
        }
    }
    for d in all {
        bag.push(d);
    }
}

/// Rewrites every `TypeName::Struct(name)` type annotation in `program`
/// into `TypeName::Enum(name)` wherever `name` is actually an enum (the
/// parser can't distinguish the two at parse time -- both a struct name
/// and an enum name are just a bare identifier in type position -- so
/// this is where that ambiguity gets resolved, once, before any other
/// pass or IR lowering sees the AST). Returns an owned, rewritten copy;
/// `program` itself is never mutated.
fn resolve_named_types(program: &Program, enums: &HashMap<String, Vec<String>>) -> Program {
    if enums.is_empty() {
        return program.clone();
    }

    let fix_ty = |ty: &TypeName| -> TypeName {
        if let TypeName::Struct(name) = ty {
            if enums.contains_key(name) {
                return TypeName::Enum(name.clone());
            }
        }
        ty.clone()
    };

    let mut structs = program.structs.clone();
    for s in &mut structs {
        for field in &mut s.fields {
            field.ty = fix_ty(&field.ty);
        }
    }

    let mut functions = program.functions.clone();
    for f in &mut functions {
        for param in &mut f.params {
            param.ty = fix_ty(&param.ty);
        }
        if let Some(rt) = &f.declared_return_type {
            f.declared_return_type = Some(fix_ty(rt));
        }
        if let Some(body) = &mut f.body {
            fix_block(body, &fix_ty);
        }
    }

    Program {
        imports: program.imports.clone(),
        structs,
        enums: program.enums.clone(),
        functions,
    }
}

fn fix_block(block: &mut Block, fix_ty: &impl Fn(&TypeName) -> TypeName) {
    for stmt in &mut block.statements {
        fix_stmt(stmt, fix_ty);
    }
}

fn fix_stmt(stmt: &mut Stmt, fix_ty: &impl Fn(&TypeName) -> TypeName) {
    match stmt {
        Stmt::Assign { annotated_type, .. } => {
            if let Some(ty) = annotated_type {
                *annotated_type = Some(fix_ty(ty));
            }
        }
        Stmt::If {
            then_branch,
            orif_branches,
            else_branch,
            ..
        } => {
            fix_block(then_branch, fix_ty);
            for clause in orif_branches {
                fix_block(&mut clause.body, fix_ty);
            }
            if let Some(block) = else_branch {
                fix_block(block, fix_ty);
            }
        }
        Stmt::Until { body, .. }
        | Stmt::Infinit { body, .. }
        | Stmt::ForRange { body, .. }
        | Stmt::ForEach { body, .. }
        | Stmt::Thread { body, .. } => fix_block(body, fix_ty),
        Stmt::Try {
            try_block,
            failed_block,
            finally_block,
            ..
        } => {
            fix_block(try_block, fix_ty);
            if let Some(block) = failed_block {
                fix_block(block, fix_ty);
            }
            if let Some(block) = finally_block {
                fix_block(block, fix_ty);
            }
        }
        Stmt::Expr(_) | Stmt::Return { .. } | Stmt::Break(_) | Stmt::Continue(_) => {}
    }
}
