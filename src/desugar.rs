//! Front-end desugaring: rewrites conveniences into the core language
//! before semantic analysis, so sema / IR / codegen never see them.
//!
//! * default parameters (`make f(x: int = 3)`)
//! * named arguments (`f(x=1)`)
//! * variadic parameters (`make f(*xs: int)` -> `xs: [int]`)
//! * tuple / list unpacking (`a, b = pair()`)

use crate::ast::*;
use crate::diagnostics::{Diagnostic, DiagnosticBag, Span};
use std::collections::HashMap;

struct Desugarer {
    /// data enum name -> variants
    data_enums: HashMap<String, Vec<EnumVariant>>,
    /// variant name -> (enum, index)
    variant_of: HashMap<String, (String, usize)>,
    /// class name -> base class
    bases: HashMap<String, Option<String>>,
    /// class name -> methods it declares itself
    methods: HashMap<String, Vec<String>>,
    /// (owner class, method) pairs that have a virtual-call dispatcher
    vcalls: std::collections::HashSet<(String, String)>,
    /// functions' declared return types (for receiver inference)
    rets: HashMap<String, TypeName>,
    /// variable -> class, flow-insensitive, reset per function
    env: HashMap<String, String>,
    sigs: HashMap<String, Vec<Param>>,
    diags: DiagnosticBag,
    tmp: u32,
}

/// Runs every desugaring over `program` in place. Errors (unknown named
/// argument, missing argument, ...) are returned as diagnostics.
pub fn desugar_program(program: &mut Program) -> DiagnosticBag {
    let mut d = Desugarer {
        data_enums: HashMap::new(),
        variant_of: HashMap::new(),
        bases: HashMap::new(),
        methods: HashMap::new(),
        vcalls: std::collections::HashSet::new(),
        rets: HashMap::new(),
        env: HashMap::new(),
        sigs: HashMap::new(),
        diags: DiagnosticBag::new(),
        tmp: 0,
    };
    d.prepare_enums(program);
    let extra = d.prepare_classes(program);
    for f in program.functions.iter().chain(extra.iter()) {
        d.sigs.insert(f.name.clone(), f.params.clone());
        if let Some(rt) = &f.declared_return_type {
            d.rets.insert(f.name.clone(), rt.clone());
        }
    }
    for f in &mut program.functions {
        d.env.clear();
        for p in &f.params {
            if let TypeName::Struct(c) = &p.ty {
                d.env.insert(p.name.clone(), c.clone());
            }
        }
        if let Some(body) = &mut f.body {
            d.block(body);
        }
        // Variadic parameters become lists *after* call sites were
        // normalized against the original signatures.
        for p in &mut f.params {
            if p.variadic {
                p.ty = TypeName::List(Box::new(p.ty.clone()));
            }
        }
    }
    program.functions.extend(extra);
    // A function with no `return <value>` anywhere returns nothing:
    // saying so explicitly spares sema the (cycle-prone) inference.
    for f in &mut program.functions {
        if f.declared_return_type.is_none() && !f.is_extern {
            if let Some(b) = &f.body {
                if !block_returns_value(b) {
                    f.declared_return_type = Some(TypeName::Void);
                }
            }
        }
    }
    d.diags
}

fn block_returns_value(b: &Block) -> bool {
    b.statements.iter().any(|s| match s {
        Stmt::Return { value: Some(_), .. } => true,
        Stmt::If {
            then_branch,
            orif_branches,
            else_branch,
            ..
        } => {
            block_returns_value(then_branch)
                || orif_branches.iter().any(|o| block_returns_value(&o.body))
                || else_branch.as_ref().is_some_and(block_returns_value)
        }
        Stmt::Until { body, .. }
        | Stmt::While { body, .. }
        | Stmt::Infinit { body, .. }
        | Stmt::ForRange { body, .. }
        | Stmt::ForEach { body, .. }
        | Stmt::Thread { body, .. } => block_returns_value(body),
        Stmt::Try {
            try_block,
            failed_block,
            finally_block,
            ..
        } => {
            block_returns_value(try_block)
                || failed_block.as_ref().is_some_and(block_returns_value)
                || finally_block.as_ref().is_some_and(block_returns_value)
        }
        _ => false,
    })
}

impl Desugarer {
    /// Turns every enum with payload variants into a flat tagged struct
    /// `E { tag: int, Variant__field: T, .. }` plus constructor functions
    /// `E__Variant(..) -> E`.
    fn prepare_enums(&mut self, program: &mut Program) {
        let (data, plain): (Vec<EnumDef>, Vec<EnumDef>) = program
            .enums
            .drain(..)
            .partition(|e| e.variants.iter().any(|v| !v.fields.is_empty()));
        program.enums = plain;
        for e in data {
            let span = e.span;
            let mut fields = vec![StructField {
                name: "tag".to_string(),
                ty: TypeName::Int,
                span,
            }];
            for v in &e.variants {
                for (f, t) in &v.fields {
                    fields.push(StructField {
                        name: format!("{}__{}", v.name, f),
                        ty: t.clone(),
                        span,
                    });
                }
            }
            program.structs.push(StructDef {
                name: e.name.clone(),
                fields,
                base: None,
                span,
            });
            for (i, v) in e.variants.iter().enumerate() {
                self.variant_of.insert(v.name.clone(), (e.name.clone(), i));
                let params: Vec<Param> = v
                    .fields
                    .iter()
                    .map(|(n, t)| Param {
                        name: n.clone(),
                        ty: t.clone(),
                        default: None,
                        variadic: false,
                        span,
                    })
                    .collect();
                let r = || Box::new(Expr::Identifier("__r".to_string(), span));
                let mut stmts = vec![
                    Stmt::Assign {
                        target: LValue::Ident("__r".to_string()),
                        annotated_type: None,
                        value: Expr::Call {
                            name: e.name.clone(),
                            args: vec![],
                            span,
                        },
                        span,
                    },
                    Stmt::Assign {
                        target: LValue::Field {
                            base: r(),
                            field: "tag".to_string(),
                            span,
                        },
                        annotated_type: None,
                        value: Expr::IntLiteral(i as i64, span),
                        span,
                    },
                ];
                for (f, _) in &v.fields {
                    stmts.push(Stmt::Assign {
                        target: LValue::Field {
                            base: r(),
                            field: format!("{}__{}", v.name, f),
                            span,
                        },
                        annotated_type: None,
                        value: Expr::Identifier(f.clone(), span),
                        span,
                    });
                }
                stmts.push(Stmt::Return {
                    value: Some(*r()),
                    span,
                });
                program.functions.push(Function {
                    name: format!("{}__{}", e.name, v.name),
                    params,
                    declared_return_type: Some(TypeName::Struct(e.name.clone())),
                    is_async: false,
                    is_extern: false,
                    body: Some(Block {
                        statements: stmts,
                        span,
                    }),
                    span,
                });
            }
            self.data_enums.insert(e.name.clone(), e.variants.clone());
        }
    }

    /// `match` -> `tmp = subject; if tmp.tag == k: binds; body orif ...`.
    fn expand_match(
        &mut self,
        subject: Expr,
        arms: Vec<MatchArm>,
        else_body: Option<Block>,
        span: Span,
    ) -> Vec<Stmt> {
        let tmp = format!("__match{}", self.tmp);
        self.tmp += 1;
        let mut out = vec![Stmt::Assign {
            target: LValue::Ident(tmp.clone()),
            annotated_type: None,
            value: subject,
            span,
        }];
        let mut clauses: Vec<(Expr, Block)> = Vec::new();
        for arm in arms {
            let Some((en, idx)) = self.variant_of.get(&arm.variant).cloned() else {
                self.err(
                    "E0108",
                    format!("`{}` is not a variant of any data enum", arm.variant),
                    arm.span,
                );
                continue;
            };
            let variant = self.data_enums[&en][idx].clone();
            if variant.fields.len() != arm.binds.len() {
                self.err(
                    "E0109",
                    format!(
                        "variant `{}` has {} field(s), but the pattern binds {}",
                        arm.variant,
                        variant.fields.len(),
                        arm.binds.len()
                    ),
                    arm.span,
                );
                continue;
            }
            let tmp_id = || Box::new(Expr::Identifier(tmp.clone(), span));
            let cond = Expr::Binary {
                op: BinOp::Eq,
                lhs: Box::new(Expr::Field {
                    base: tmp_id(),
                    field: "tag".to_string(),
                    span,
                }),
                rhs: Box::new(Expr::IntLiteral(idx as i64, span)),
                span,
            };
            let mut stmts: Vec<Stmt> = Vec::new();
            for (b, (f, _)) in arm.binds.iter().zip(variant.fields.iter()) {
                if b == "_" {
                    continue;
                }
                stmts.push(Stmt::Assign {
                    target: LValue::Ident(b.clone()),
                    annotated_type: None,
                    value: Expr::Field {
                        base: tmp_id(),
                        field: format!("{}__{}", arm.variant, f),
                        span,
                    },
                    span,
                });
            }
            let mut body = arm.body;
            stmts.append(&mut body.statements);
            body.statements = stmts;
            clauses.push((cond, body));
        }
        if clauses.is_empty() {
            if let Some(b) = else_body {
                out.extend(b.statements);
            }
            return out;
        }
        let (first_cond, first_body) = clauses.remove(0);
        out.push(Stmt::If {
            condition: first_cond,
            then_branch: first_body,
            orif_branches: clauses
                .into_iter()
                .map(|(c, b)| OrifClause {
                    span: b.span,
                    condition: c,
                    body: b,
                })
                .collect(),
            else_branch: else_body,
            span,
        });
        out
    }

    /// First class in `c`'s inheritance chain that declares `m`.
    fn owner_of(&self, c: &str, m: &str) -> Option<String> {
        let mut cur = Some(c.to_string());
        let mut guard = 0;
        while let Some(name) = cur {
            if self.methods.get(&name).is_some_and(|ms| ms.iter().any(|x| x == m)) {
                return Some(name);
            }
            cur = self.bases.get(&name).cloned().flatten();
            guard += 1;
            if guard > 64 {
                break;
            }
        }
        None
    }

    /// Static class of an expression, when it is cheaply knowable.
    fn class_of(&self, e: &Expr) -> Option<String> {
        match e {
            Expr::Identifier(n, _) => self.env.get(n).cloned(),
            Expr::Call { name, .. } => {
                if self.bases.contains_key(name) {
                    return Some(name.clone());
                }
                if let Some(base) = name.strip_suffix("__new") {
                    if self.bases.contains_key(base) {
                        return Some(base.to_string());
                    }
                }
                match self.rets.get(name) {
                    Some(TypeName::Struct(c)) => Some(c.clone()),
                    _ => None,
                }
            }
            _ => None,
        }
    }

    /// Flattens inherited fields, records class tables and builds the
    /// `Class__new` constructor for every class that has an `init`.
    fn prepare_classes(&mut self, program: &mut Program) -> Vec<Function> {
        for st in &program.structs {
            self.bases.insert(st.name.clone(), st.base.clone());
        }
        for f in &program.functions {
            if let Some((c, m)) = f.name.split_once("__") {
                if self.bases.contains_key(c) {
                    self.methods
                        .entry(c.to_string())
                        .or_default()
                        .push(m.to_string());
                }
            }
        }
        // Classes taking part in an inheritance hierarchy carry a hidden
        // `__cls` tag (first field of the root) used for virtual dispatch.
        let mut hier: std::collections::HashSet<String> = std::collections::HashSet::new();
        for st in &program.structs {
            if let Some(b) = &st.base {
                hier.insert(st.name.clone());
                let mut cur = Some(b.clone());
                let mut guard = 0;
                while let Some(n) = cur {
                    hier.insert(n.clone());
                    cur = self.bases.get(&n).cloned().flatten();
                    guard += 1;
                    if guard > 64 {
                        break;
                    }
                }
            }
        }
        for st in &mut program.structs {
            if hier.contains(&st.name) && st.base.is_none() {
                st.fields.insert(
                    0,
                    StructField {
                        name: "__cls".to_string(),
                        ty: TypeName::Int,
                        span: st.span,
                    },
                );
            }
        }
        let class_ids: HashMap<String, i64> = program
            .structs
            .iter()
            .enumerate()
            .map(|(i, s)| (s.name.clone(), i as i64))
            .collect();

        // Flatten fields (base first). Iterate to a fixpoint-free order
        // by resolving each class recursively.
        let originals: HashMap<String, Vec<StructField>> = program
            .structs
            .iter()
            .map(|s| (s.name.clone(), s.fields.clone()))
            .collect();
        for st in &mut program.structs {
            let mut chain = Vec::new();
            let mut cur = st.base.clone();
            let mut guard = 0;
            while let Some(b) = cur {
                if b == st.name || guard > 64 {
                    self.diags.push(Diagnostic::error(
                        "E0104",
                        format!("class `{}` inherits from itself", st.name),
                        st.span,
                    ));
                    break;
                }
                if !originals.contains_key(&b) {
                    self.diags.push(Diagnostic::error(
                        "E0105",
                        format!("unknown base class `{b}`"),
                        st.span,
                    ));
                    break;
                }
                chain.push(b.clone());
                cur = self.bases.get(&b).cloned().flatten();
                guard += 1;
            }
            let mut fields: Vec<StructField> = Vec::new();
            for b in chain.iter().rev() {
                for f in &originals[b] {
                    if !fields.iter().any(|x| x.name == f.name) {
                        fields.push(f.clone());
                    }
                }
            }
            for f in &st.fields {
                if !fields.iter().any(|x| x.name == f.name) {
                    fields.push(f.clone());
                }
            }
            st.fields = fields;
        }

        // Constructors.
        let mut extra = Vec::new();
        let names: Vec<(String, Span)> = program
            .structs
            .iter()
            .map(|s| (s.name.clone(), s.span))
            .collect();
        for (cname, span) in names {
            let owner = self.owner_of(&cname, "init");
            if owner.is_none() && !hier.contains(&cname) {
                continue;
            }
            let init = owner.as_ref().and_then(|o| {
                program
                    .functions
                    .iter()
                    .find(|f| f.name == format!("{o}__init"))
                    .cloned()
            });
            let params: Vec<Param> = init
                .as_ref()
                .map(|i| i.params.iter().skip(1).cloned().collect())
                .unwrap_or_default();
            let mut stmts = vec![Stmt::Assign {
                target: LValue::Ident("self".to_string()),
                annotated_type: None,
                value: Expr::Call {
                    name: cname.clone(),
                    args: vec![],
                    span,
                },
                span,
            }];
            if hier.contains(&cname) {
                stmts.push(Stmt::Assign {
                    target: LValue::Field {
                        base: Box::new(Expr::Identifier("self".to_string(), span)),
                        field: "__cls".to_string(),
                        span,
                    },
                    annotated_type: None,
                    value: Expr::IntLiteral(class_ids[&cname], span),
                    span,
                });
            }
            if let Some(owner) = &owner {
                let mut args = vec![Expr::Identifier("self".to_string(), span)];
                args.extend(
                    params
                        .iter()
                        .map(|p| Expr::Identifier(p.name.clone(), span)),
                );
                stmts.push(Stmt::Expr(Expr::Call {
                    name: format!("{owner}__init"),
                    args,
                    span,
                }));
            }
            stmts.push(Stmt::Return {
                value: Some(Expr::Identifier("self".to_string(), span)),
                span,
            });
            extra.push(Function {
                name: format!("{cname}__new"),
                params,
                declared_return_type: Some(TypeName::Struct(cname.clone())),
                is_async: false,
                is_extern: false,
                body: Some(Block {
                    statements: stmts,
                    span,
                }),
                span,
            });
        }

        // Virtual-call dispatchers for overridden methods.
        let all: Vec<String> = program.structs.iter().map(|s| s.name.clone()).collect();
        let is_ancestor = |d: &Desugarer, c: &str, x: &str| -> bool {
            let mut cur = d.bases.get(x).cloned().flatten();
            let mut guard = 0;
            while let Some(n) = cur {
                if n == c {
                    return true;
                }
                cur = d.bases.get(&n).cloned().flatten();
                guard += 1;
                if guard > 64 {
                    break;
                }
            }
            false
        };
        let mut disp_fns = Vec::new();
        for c in &all {
            let own = self.methods.get(c).cloned().unwrap_or_default();
            for m in own {
                if m == "init" || !hier.contains(c) {
                    continue;
                }
                let mut arms: Vec<(i64, String)> = Vec::new();
                for d in &all {
                    if d != c && is_ancestor(self, c, d) {
                        if let Some(o) = self.owner_of(d, &m) {
                            if &o != c {
                                arms.push((class_ids[d], o));
                            }
                        }
                    }
                }
                if arms.is_empty() {
                    continue;
                }
                let Some(base_fn) = program
                    .functions
                    .iter()
                    .find(|f| f.name == format!("{c}__{m}"))
                    .cloned()
                else {
                    continue;
                };
                let span = base_fn.span;
                let returns_value = base_fn
                    .declared_return_type
                    .as_ref()
                    .is_some_and(|t| *t != TypeName::Void)
                    || block_returns_value(base_fn.body.as_ref().unwrap());
                let args_of = |p: &Vec<Param>| -> Vec<Expr> {
                    p.iter()
                        .map(|x| Expr::Identifier(x.name.clone(), span))
                        .collect()
                };
                let call = |target: String| -> Vec<Stmt> {
                    let c = Expr::Call {
                        name: target,
                        args: args_of(&base_fn.params),
                        span,
                    };
                    if returns_value {
                        vec![Stmt::Return {
                            value: Some(c),
                            span,
                        }]
                    } else {
                        vec![
                            Stmt::Expr(c),
                            Stmt::Return { value: None, span },
                        ]
                    }
                };
                let tag = || Expr::Field {
                    base: Box::new(Expr::Identifier("self".to_string(), span)),
                    field: "__cls".to_string(),
                    span,
                };
                let mut stmts: Vec<Stmt> = Vec::new();
                for (id, owner) in &arms {
                    stmts.push(Stmt::If {
                        condition: Expr::Binary {
                            op: BinOp::Eq,
                            lhs: Box::new(tag()),
                            rhs: Box::new(Expr::IntLiteral(*id, span)),
                            span,
                        },
                        then_branch: Block {
                            statements: call(format!("{owner}__{m}")),
                            span,
                        },
                        orif_branches: vec![],
                        else_branch: None,
                        span,
                    });
                }
                stmts.extend(call(format!("{c}__{m}")));
                disp_fns.push(Function {
                    name: format!("{c}__{m}__vcall"),
                    params: base_fn.params.clone(),
                    declared_return_type: base_fn.declared_return_type.clone().or(
                        if returns_value { None } else { Some(TypeName::Void) },
                    ),
                    is_async: false,
                    is_extern: false,
                    body: Some(Block {
                        statements: stmts,
                        span,
                    }),
                    span,
                });
                self.vcalls.insert((c.clone(), m.clone()));
            }
        }
        extra.extend(disp_fns);
        extra
    }

    fn err(&mut self, code: &'static str, msg: String, span: Span) {
        self.diags.push(Diagnostic::error(code, msg, span));
    }

    fn block(&mut self, b: &mut Block) {
        let old = std::mem::take(&mut b.statements);
        let mut out = Vec::with_capacity(old.len());
        for mut st in old {
            if let Stmt::Match {
                subject,
                arms,
                else_body,
                span,
            } = st
            {
                let mut expanded = self.expand_match(subject, arms, else_body, span);
                // Re-run desugaring on the generated statements (bodies,
                // calls) so nothing is left un-normalized.
                let mut tmp_block = Block {
                    statements: std::mem::take(&mut expanded),
                    span,
                };
                self.block(&mut tmp_block);
                out.extend(tmp_block.statements);
                continue;
            }
            self.stmt(&mut st);
            match st {
                Stmt::Unpack {
                    targets,
                    value,
                    span,
                } => {
                    let tmp = format!("__unpack{}", self.tmp);
                    self.tmp += 1;
                    out.push(Stmt::Assign {
                        target: LValue::Ident(tmp.clone()),
                        annotated_type: None,
                        value,
                        span,
                    });
                    for (i, name) in targets.into_iter().enumerate() {
                        out.push(Stmt::Assign {
                            target: LValue::Ident(name),
                            annotated_type: None,
                            value: Expr::Index {
                                base: Box::new(Expr::Identifier(tmp.clone(), span)),
                                index: Box::new(Expr::IntLiteral(i as i64, span)),
                                span,
                            },
                            span,
                        });
                    }
                }
                other => out.push(other),
            }
        }
        b.statements = out;
    }

    fn stmt(&mut self, st: &mut Stmt) {
        match st {
            Stmt::Assign {
                target,
                value,
                annotated_type,
                ..
            } => {
                // `xs: [T] = []` -- a typed empty list.
                if let (Some(TypeName::List(el)), Expr::ListLiteral(items, sp)) =
                    (&*annotated_type, &*value)
                {
                    if items.is_empty() {
                        *value = Expr::EmptyList {
                            elem: (**el).clone(),
                            span: *sp,
                        };
                    }
                }
                if let LValue::Ident(n) = target {
                    if let Some(TypeName::Struct(c)) = annotated_type {
                        self.env.insert(n.clone(), c.clone());
                    }
                }
                match target {
                    LValue::Ident(_) => {}
                    LValue::Field { base, .. } => self.expr(base),
                    LValue::Index { base, index, .. } => {
                        self.expr(base);
                        self.expr(index);
                    }
                    LValue::Deref { target, .. } => self.expr(target),
                }
                self.expr(value);
                if let LValue::Ident(n) = target {
                    if let Some(c) = self.class_of(value) {
                        self.env.insert(n.clone(), c);
                    }
                }
            }
            Stmt::Unpack { value, .. } => self.expr(value),
            Stmt::Match { .. } => {}
            Stmt::Expr(e) => self.expr(e),
            Stmt::Return { value, .. } => {
                if let Some(v) = value {
                    self.expr(v);
                }
            }
            Stmt::Break(_) | Stmt::Continue(_) => {}
            Stmt::If {
                condition,
                then_branch,
                orif_branches,
                else_branch,
                ..
            } => {
                self.expr(condition);
                self.block(then_branch);
                for o in orif_branches {
                    self.expr(&mut o.condition);
                    self.block(&mut o.body);
                }
                if let Some(e) = else_branch {
                    self.block(e);
                }
            }
            Stmt::Until {
                condition, body, ..
            }
            | Stmt::While {
                condition, body, ..
            } => {
                self.expr(condition);
                self.block(body);
            }
            Stmt::Infinit { body, .. } | Stmt::Thread { body, .. } => self.block(body),
            Stmt::ForRange {
                start, end, body, ..
            } => {
                self.expr(start);
                self.expr(end);
                self.block(body);
            }
            Stmt::ForEach { iterable, body, .. } => {
                self.expr(iterable);
                self.block(body);
            }
            Stmt::Try {
                try_block,
                failed_block,
                finally_block,
                ..
            } => {
                self.block(try_block);
                if let Some(b) = failed_block {
                    self.block(b);
                }
                if let Some(b) = finally_block {
                    self.block(b);
                }
            }
        }
    }

    fn expr(&mut self, e: &mut Expr) {
        match e {
            Expr::ListLiteral(xs, _) | Expr::TupleLiteral(xs, _) => {
                for x in xs {
                    self.expr(x);
                }
            }
            Expr::DictLiteral(kv, _) => {
                for (_, v) in kv {
                    self.expr(v);
                }
            }
            Expr::Index { base, index, .. } => {
                self.expr(base);
                self.expr(index);
            }
            Expr::Unary { expr, .. } | Expr::Await { expr, .. } => self.expr(expr),
            Expr::Binary { lhs, rhs, .. } => {
                self.expr(lhs);
                self.expr(rhs);
            }
            Expr::Named { value, .. } => self.expr(value),
            Expr::Field { base, field, span } if matches!(&**base, Expr::Identifier(en, _)
                if self.data_enums.contains_key(en) && !self.env.contains_key(en)
                    && self.variant_of.get(field.as_str()).is_some_and(|(e2, _)| e2 == en)) =>
            {
                let Expr::Identifier(en, _) = &**base else { unreachable!() };
                *e = Expr::Call {
                    name: format!("{en}__{field}"),
                    args: vec![],
                    span: *span,
                };
            }
            Expr::Field { base, .. } => self.expr(base),
            Expr::AllocN { count, .. } => self.expr(count),
            Expr::MethodCall {
                recv,
                name,
                args,
                span,
            } => {
                self.expr(recv);
                for a in args.iter_mut() {
                    self.expr(a);
                }
                let span = *span;
                // `Enum.Variant(args)` -- data-enum constructor.
                if let Expr::Identifier(en, _) = &**recv {
                    if self.data_enums.contains_key(en)
                        && !self.env.contains_key(en)
                        && self.variant_of.get(name.as_str()).is_some_and(|(e2, _)| e2 == en)
                    {
                        *e = Expr::Call {
                            name: format!("{en}__{name}"),
                            args: std::mem::take(args),
                            span,
                        };
                        self.expr(e);
                        return;
                    }
                }
                // `Base.method(self, ..)` -- explicit class-qualified call.
                let qualified = match &**recv {
                    Expr::Identifier(c, _)
                        if !self.env.contains_key(c) && self.bases.contains_key(c) =>
                    {
                        self.owner_of(c, name)
                    }
                    _ => None,
                };
                if let Some(owner) = qualified {
                    let new = Expr::Call {
                        name: format!("{owner}__{name}"),
                        args: std::mem::take(args),
                        span,
                    };
                    *e = new;
                    self.expr(e);
                } else if let Some(cls) = self.class_of(recv) {
                    if let Some(owner) = self.owner_of(&cls, name) {
                        let mut full = vec![(**recv).clone()];
                        full.append(args);
                        let target = if self.vcalls.contains(&(owner.clone(), name.clone())) {
                            format!("{owner}__{name}__vcall")
                        } else {
                            format!("{owner}__{name}")
                        };
                        *e = Expr::Call {
                            name: target,
                            args: full,
                            span,
                        };
                        // Normalize defaults/named args of the new call.
                        if let Expr::Call { name, args, span } = e {
                            if let Some(params) = self.sigs.get(name.as_str()).cloned() {
                                let taken = std::mem::take(args);
                                let n = name.clone();
                                *args = self.normalize_call(&n, &params, taken, *span);
                            }
                        }
                    } else {
                        self.err(
                            "E0106",
                            format!("class `{cls}` has no method `{name}`"),
                            span,
                        );
                    }
                }
            }
            Expr::Call { name, args, span } => {
                for a in args.iter_mut() {
                    self.expr(a);
                }
                // `Class(args)` -> `Class__new(args)` when the class has `init`.
                if self.sigs.contains_key(&format!("{name}__new")) {
                    *name = format!("{name}__new");
                }
                let (name, span) = (name.clone(), *span);
                if let Some(params) = self.sigs.get(&name).cloned() {
                    let taken = std::mem::take(args);
                    *args = self.normalize_call(&name, &params, taken, span);
                }
            }
            _ => {}
        }
    }

    fn normalize_call(
        &mut self,
        fname: &str,
        params: &[Param],
        args: Vec<Expr>,
        span: Span,
    ) -> Vec<Expr> {
        let mut positional: Vec<Expr> = Vec::new();
        let mut named: Vec<(String, Expr, Span)> = Vec::new();
        for a in args {
            match a {
                Expr::Named { name, value, span } => {
                    if named.iter().any(|(n, _, _)| *n == name) {
                        self.err(
                            "E0095",
                            format!("argument `{name}` given twice in call to `{fname}`"),
                            span,
                        );
                    } else {
                        named.push((name, *value, span));
                    }
                }
                other => {
                    if !named.is_empty() {
                        self.err(
                            "E0096",
                            "positional argument after a named argument".to_string(),
                            other.span(),
                        );
                    }
                    positional.push(other);
                }
            }
        }

        let mut out: Vec<Expr> = Vec::new();
        let mut pos = positional.into_iter();
        for p in params {
            if p.variadic {
                let rest: Vec<Expr> = pos.by_ref().collect();
                if rest.is_empty() {
                    out.push(Expr::EmptyList {
                        elem: p.ty.clone(),
                        span,
                    });
                } else {
                    out.push(Expr::ListLiteral(rest, span));
                }
                continue;
            }
            if let Some(a) = pos.next() {
                if named.iter().any(|(n, _, _)| *n == p.name) {
                    self.err(
                        "E0095",
                        format!("argument `{}` given twice in call to `{fname}`", p.name),
                        span,
                    );
                }
                out.push(a);
            } else if let Some(i) = named.iter().position(|(n, _, _)| *n == p.name) {
                out.push(named.remove(i).1);
            } else if let Some(d) = &p.default {
                out.push(d.clone());
            } else {
                self.err(
                    "E0097",
                    format!("missing argument `{}` in call to `{fname}`", p.name),
                    span,
                );
            }
        }
        let leftover: Vec<Expr> = pos.collect();
        if let Some(extra) = leftover.first() {
            self.err(
                "E0099",
                format!(
                    "`{fname}` takes {} argument(s), but {} were given",
                    params.len(),
                    params.len() + leftover.len()
                ),
                extra.span(),
            );
        }
        for (n, _, sp) in named {
            self.err(
                "E0100",
                format!("`{fname}` has no parameter named `{n}`"),
                sp,
            );
        }
        out
    }
}
