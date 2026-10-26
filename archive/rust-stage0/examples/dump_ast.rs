//! Canonical dumps of tokens and AST, for differential testing against
//! the Kite compiler written in Kite (`kitec tokens|ast FILE`).
use kite::ast::*;
use kite::diagnostics::Span;
use kite::lexer::{lex, TokenKind};

fn q(s: &str) -> String {
    let mut o = String::from("\"");
    for c in s.chars() {
        match c {
            '"' => o.push_str("\\\""),
            '\\' => o.push_str("\\\\"),
            '\n' => o.push_str("\\n"),
            '\t' => o.push_str("\\t"),
            '\r' => o.push_str("\\r"),
            c => o.push(c),
        }
    }
    o.push('"');
    o
}
fn sp(s: Span) -> String {
    format!("@{}:{}:{}-{}", s.line, s.column, s.start, s.end)
}
fn node(kind: &str, text: &str, span: Span, kids: &[String]) -> String {
    let no_span = matches!(kind, "List" | "Flags" | "Name" | "Program" | "Entry" | "Type" | "VField");
    let shown = if no_span { "@-".to_string() } else { sp(span) };
    let mut o = format!("({} {} {}", kind, q(text), shown);
    for k in kids {
        o.push(' ');
        o.push_str(k);
    }
    o.push(')');
    o
}
const DUMMY: Span = Span { start: 0, end: 0, line: 0, column: 0 };
fn list(span: Span, kids: Vec<String>) -> String {
    node("List", "", span, &kids)
}
fn ty(t: &TypeName, span: Span) -> String {
    node("Type", &format!("{t}"), span, &[])
}
fn opt(s: Option<String>) -> String {
    s.unwrap_or_else(|| "nil".to_string())
}
fn flags(s: &str, span: Span) -> String {
    node("Flags", s, span, &[])
}
fn lval(l: &LValue, fb: Span) -> String {
    match l {
        LValue::Ident(n) => node("LIdent", n, DUMMY, &[]),
        LValue::Field { base, field, span } => node("LField", field, *span, &[expr(base)]),
        LValue::Index { base, index, span } => node("LIndex", "", *span, &[expr(base), expr(index)]),
        LValue::Deref { target, span } => node("LDeref", "", *span, &[expr(target)]),
    }
    .to_string()
    + if fb.start == 0 && false { "" } else { "" }
}
fn float_text(v: f64) -> String {
    format!("{:?}", v)
}
fn expr(e: &Expr) -> String {
    match e {
        Expr::IntLiteral(v, s) => node("Int", &v.to_string(), *s, &[]),
        Expr::FloatLiteral(v, s) => node("Float", &float_text(*v), *s, &[]),
        Expr::BoolLiteral(v, s) => node("Bool", &v.to_string(), *s, &[]),
        Expr::StringLiteral(v, s) => node("Str", v, *s, &[]),
        Expr::Identifier(n, s) => node("Ident", n, *s, &[]),
        Expr::NullLit(s) => node("Null", "", *s, &[]),
        Expr::ListLiteral(xs, s) => node("ListLit", "", *s, &xs.iter().map(expr).collect::<Vec<_>>()),
        Expr::TupleLiteral(xs, s) => node("TupleLit", "", *s, &xs.iter().map(expr).collect::<Vec<_>>()),
        Expr::DictLiteral(kv, s) => node(
            "DictLit",
            "",
            *s,
            &kv.iter().map(|(k, v)| node("Entry", k, expr_span(v), &[expr(v)])).collect::<Vec<_>>(),
        ),
        Expr::Index { base, index, span } => node("Index", "", *span, &[expr(base), expr(index)]),
        Expr::Field { base, field, span } => node("Field", field, *span, &[expr(base)]),
        Expr::Unary { op, expr: x, span } => node("Unary", &format!("{:?}", op), *span, &[expr(x)]),
        Expr::Binary { op, lhs, rhs, span } => node("Binary", &format!("{:?}", op), *span, &[expr(lhs), expr(rhs)]),
        Expr::Call { name, args, span } => node("Call", name, *span, &args.iter().map(expr).collect::<Vec<_>>()),
        Expr::MethodCall { recv, name, args, span } => {
            let mut k = vec![expr(recv)];
            k.extend(args.iter().map(expr));
            node("MethodCall", name, *span, &k)
        }
        Expr::Named { name, value, span } => node("Named", name, *span, &[expr(value)]),
        Expr::Await { expr: x, span } => node("Await", "", *span, &[expr(x)]),
        Expr::Alloc { ty: t, span } => node("Alloc", "", *span, &[ty(t, *span)]),
        Expr::AllocN { ty: t, count, span } => node("AllocN", "", *span, &[ty(t, *span), expr(count)]),
        Expr::EmptyList { elem, span } => node("EmptyList", "", *span, &[ty(elem, *span)]),
    }
}
fn expr_span(e: &Expr) -> Span {
    e.span()
}
fn block(b: &Block) -> String {
    node("Block", "", b.span, &b.statements.iter().map(stmt).collect::<Vec<_>>())
}
fn stmt(s: &Stmt) -> String {
    match s {
        Stmt::Assign { target, annotated_type, value, span } => node(
            "Assign",
            "",
            *span,
            &[
                lval(target, *span),
                opt(annotated_type.as_ref().map(|t| ty(t, *span))),
                expr(value),
            ],
        ),
        Stmt::Unpack { targets, value, span } => node(
            "Unpack",
            "",
            *span,
            &[
                list(*span, targets.iter().map(|n| node("Name", n, DUMMY, &[])).collect()),
                expr(value),
            ],
        ),
        Stmt::Expr(e) => node("ExprStmt", "", e.span(), &[expr(e)]),
        Stmt::Match { subject, arms, else_body, span } => node(
            "Match",
            "",
            *span,
            &[
                expr(subject),
                list(
                    *span,
                    arms.iter()
                        .map(|a| {
                            let mut k: Vec<String> =
                                a.binds.iter().map(|b| node("Name", b, DUMMY, &[])).collect();
                            k.push(block(&a.body));
                            node("Arm", &a.variant, a.span, &k)
                        })
                        .collect(),
                ),
                opt(else_body.as_ref().map(block)),
            ],
        ),
        Stmt::Return { value, span } => node("Return", "", *span, &[opt(value.as_ref().map(expr))]),
        Stmt::Break(s) => node("Break", "", *s, &[]),
        Stmt::Continue(s) => node("Continue", "", *s, &[]),
        Stmt::If { condition, then_branch, orif_branches, else_branch, span } => node(
            "If",
            "",
            *span,
            &[
                expr(condition),
                block(then_branch),
                list(
                    *span,
                    orif_branches
                        .iter()
                        .map(|o| node("Orif", "", o.span, &[expr(&o.condition), block(&o.body)]))
                        .collect(),
                ),
                opt(else_branch.as_ref().map(block)),
            ],
        ),
        Stmt::Until { condition, body, span } => node("Until", "", *span, &[expr(condition), block(body)]),
        Stmt::While { condition, body, span } => node("While", "", *span, &[expr(condition), block(body)]),
        Stmt::Infinit { body, span } => node("Infinit", "", *span, &[block(body)]),
        Stmt::Thread { body, span } => node("Thread", "", *span, &[block(body)]),
        Stmt::ForRange { var, start, end, body, span } => {
            node("ForRange", var, *span, &[expr(start), expr(end), block(body)])
        }
        Stmt::ForEach { var, iterable, body, span } => {
            node("ForEach", var, *span, &[expr(iterable), block(body)])
        }
        Stmt::Try { try_block, failed_var, failed_block, finally_block, span } => node(
            "Try",
            failed_var.as_deref().unwrap_or(""),
            *span,
            &[
                block(try_block),
                opt(failed_block.as_ref().map(block)),
                opt(finally_block.as_ref().map(block)),
            ],
        ),
    }
}
fn function(f: &Function) -> String {
    let flags_s = match (f.is_extern, f.is_async) {
        (true, true) => "extern async",
        (true, false) => "extern",
        (false, true) => "async",
        _ => "",
    };
    let params = list(
        f.span,
        f.params
            .iter()
            .map(|p| {
                node(
                    "Param",
                    &p.name,
                    p.span,
                    &[
                        ty(&p.ty, p.span),
                        opt(p.default.as_ref().map(expr)),
                        flags(if p.variadic { "variadic" } else { "" }, p.span),
                    ],
                )
            })
            .collect(),
    );
    node(
        "Function",
        &f.name,
        f.span,
        &[
            params,
            opt(f.declared_return_type.as_ref().map(|t| ty(t, f.span))),
            flags(flags_s, f.span),
            opt(f.body.as_ref().map(block)),
        ],
    )
}
fn main() {
    let mut args = std::env::args().skip(1);
    let cmd = args.next().unwrap();
    let path = args.next().unwrap();
    let src = std::fs::read_to_string(path).unwrap();
    let (toks, d) = lex(&src);
    if cmd == "tokens" {
        for t in toks {
            let (kind, text, ival) = match &t.kind {
                TokenKind::IntLiteral(v) => ("IntLiteral".to_string(), v.to_string(), *v),
                TokenKind::FloatLiteral(v) => ("FloatLiteral".to_string(), format!("{:?}", v), 0),
                TokenKind::StringLiteral(s) => ("StringLiteral".to_string(), s.clone(), 0),
                TokenKind::FStringLiteral(s) => ("FStringLiteral".to_string(), s.clone(), 0),
                TokenKind::Identifier(s) => ("Identifier".to_string(), s.clone(), 0),
                other => {
                    let dbg = format!("{:?}", other);
                    (dbg, String::new(), 0)
                }
            };
            println!(
                "{} {} {} @{}:{}:{}-{}",
                kind,
                q(&text),
                ival,
                t.span.line,
                t.span.column,
                t.span.start,
                t.span.end
            );
        }
        return;
    }
    if d.had_errors() {
        eprintln!("lex errors");
        std::process::exit(1);
    }
    let (prog, d2) = kite::parser::parse(toks);
    if d2.had_errors() || prog.is_none() {
        eprintln!("parse errors");
        std::process::exit(1);
    }
    let p = prog.unwrap();
    let s0 = Span { start: 0, end: 0, line: 0, column: 0 };
    let imports = list(
        s0,
        p.imports
            .iter()
            .map(|i| match i {
                Import::Module { path, span } => node("ImportModule", path, *span, &[]),
                Import::Items { path, items, span } => node(
                    "ImportItems",
                    path,
                    *span,
                    &items.iter().map(|n| node("Name", n, DUMMY, &[])).collect::<Vec<_>>(),
                ),
            })
            .collect(),
    );
    let structs = list(
        s0,
        p.structs
            .iter()
            .map(|s| {
                node(
                    "Struct",
                    &s.name,
                    s.span,
                    &[
                        opt(s.base.as_ref().map(|b| node("Name", b, DUMMY, &[]))),
                        list(
                            s.span,
                            s.fields.iter().map(|f| node("Field", &f.name, f.span, &[ty(&f.ty, f.span)])).collect(),
                        ),
                    ],
                )
            })
            .collect(),
    );
    let enums = list(
        s0,
        p.enums
            .iter()
            .map(|e| {
                node(
                    "Enum",
                    &e.name,
                    e.span,
                    &[list(
                        e.span,
                        e.variants
                            .iter()
                            .map(|v| {
                                node(
                                    "Variant",
                                    &v.name,
                                    v.span,
                                    &v.fields.iter().map(|(n, t)| node("VField", n, v.span, &[ty(t, v.span)])).collect::<Vec<_>>(),
                                )
                            })
                            .collect(),
                    )],
                )
            })
            .collect(),
    );
    let fns = list(s0, p.functions.iter().map(function).collect());
    println!("{}", node("Program", "", s0, &[imports, structs, enums, fns]));
}
