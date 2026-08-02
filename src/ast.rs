//! Abstract syntax tree produced by the parser and consumed by semantic
//! analysis.
//!
//! Every node carries a [`Span`] so later stages (sema, codegen) can point
//! back at the original source when they report a problem.

use crate::diagnostics::Span;

/// A Kite type, as written by the programmer or inferred by sema.
///
/// v0.1 keeps collection element/field types restricted to the scalar
/// types (`int`/`float`/`bool`/`string`) -- nested collections and
/// collections-of-structs are a v0.2 roadmap item (see `docs/roadmap.md`)
/// since they require a more general LLVM aggregate-layout system than the
/// flat one implemented here.
#[derive(Debug, Clone, PartialEq)]
pub enum TypeName {
    Int,
    Float,
    Bool,
    String,
    /// A growable, homogeneous list, backed at runtime by a heap-allocated
    /// buffer (length and capacity are runtime properties, not part of
    /// the static type) -- Kite lists behave like Python lists: `numbers
    /// = [1, 2, 3]` then `append(numbers, 4)` grows it in place, and
    /// `b = numbers` aliases the same underlying buffer.
    List(Box<TypeName>),
    /// A fixed-arity heterogeneous tuple.
    Tuple(Vec<TypeName>),
    /// A named struct type declared with `type Name: ...`.
    Struct(String),
    /// A dictionary literal's type: v0.1 dictionaries have a fixed,
    /// compile-time-known set of string keys (inferred from the literal
    /// that created them) each with their own value type -- structurally
    /// identical to an anonymous struct. Indexing requires a string
    /// *literal* key, resolved at compile time. General dynamic hash maps
    /// are a v0.2 roadmap item.
    Dict(Vec<(String, TypeName)>),
    /// Functions with no inferable/declared return type return unit.
    Void,
}

impl std::fmt::Display for TypeName {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            TypeName::Int => write!(f, "int"),
            TypeName::Float => write!(f, "float"),
            TypeName::Bool => write!(f, "bool"),
            TypeName::String => write!(f, "string"),
            TypeName::List(elem) => write!(f, "[{elem}]"),
            TypeName::Tuple(elems) => {
                write!(f, "(")?;
                for (i, e) in elems.iter().enumerate() {
                    if i > 0 {
                        write!(f, ", ")?;
                    }
                    write!(f, "{e}")?;
                }
                write!(f, ")")
            }
            TypeName::Struct(name) => write!(f, "{name}"),
            TypeName::Dict(fields) => {
                write!(f, "{{")?;
                for (i, (k, v)) in fields.iter().enumerate() {
                    if i > 0 {
                        write!(f, ", ")?;
                    }
                    write!(f, "{k:?}: {v}")?;
                }
                write!(f, "}}")
            }
            TypeName::Void => write!(f, "()"),
        }
    }
}

#[derive(Debug, Clone)]
pub struct Program {
    pub imports: Vec<Import>,
    pub structs: Vec<StructDef>,
    pub functions: Vec<Function>,
}

#[derive(Debug, Clone)]
pub enum Import {
    /// `use module`
    Module { path: String, span: Span },
    /// `from module import a, b`
    Items {
        path: String,
        items: Vec<String>,
        span: Span,
    },
}

#[derive(Debug, Clone)]
pub struct StructField {
    pub name: String,
    pub ty: TypeName,
    pub span: Span,
}

#[derive(Debug, Clone)]
pub struct StructDef {
    pub name: String,
    pub fields: Vec<StructField>,
    pub span: Span,
}

#[derive(Debug, Clone)]
pub struct Param {
    pub name: String,
    pub ty: TypeName,
    pub span: Span,
}

#[derive(Debug, Clone)]
pub struct Function {
    pub name: String,
    pub params: Vec<Param>,
    /// `None` means the return type is inferred from the function's
    /// `return` statements (unit if there are none).
    pub declared_return_type: Option<TypeName>,
    pub is_async: bool,
    pub body: Block,
    pub span: Span,
}

#[derive(Debug, Clone)]
pub struct Block {
    pub statements: Vec<Stmt>,
    pub span: Span,
}

/// The target of an assignment: a plain name, a struct field, or a
/// collection index.
#[derive(Debug, Clone)]
pub enum LValue {
    Ident(String),
    Field {
        base: Box<Expr>,
        field: String,
        span: Span,
    },
    Index {
        base: Box<Expr>,
        index: Box<Expr>,
        span: Span,
    },
}

#[derive(Debug, Clone)]
pub struct OrifClause {
    pub condition: Expr,
    pub body: Block,
    pub span: Span,
}

#[derive(Debug, Clone)]
pub enum Stmt {
    /// `name = expr` or `name: Type = expr` -- declares `name` the first
    /// time it is assigned in a scope, reassigns it (same type only)
    /// thereafter. Also covers `obj.field = expr` and `list[i] = expr`.
    Assign {
        target: LValue,
        annotated_type: Option<TypeName>,
        value: Expr,
        span: Span,
    },
    Expr(Expr),
    Return {
        value: Option<Expr>,
        span: Span,
    },
    Break(Span),
    Continue(Span),
    If {
        condition: Expr,
        then_branch: Block,
        orif_branches: Vec<OrifClause>,
        else_branch: Option<Block>,
        span: Span,
    },
    /// `until condition:` -- loops while `condition` is false.
    Until {
        condition: Expr,
        body: Block,
        span: Span,
    },
    /// `infinit:` -- an unconditional loop (exited via `break`).
    Infinit {
        body: Block,
        span: Span,
    },
    /// `for i = start to end:` -- inclusive counting loop.
    ForRange {
        var: String,
        start: Expr,
        end: Expr,
        body: Block,
        span: Span,
    },
    /// `for item in collection:`
    ForEach {
        var: String,
        iterable: Expr,
        body: Block,
        span: Span,
    },
    /// `try: ... failed err: ... finally: ...`
    ///
    /// v0.1 has no runtime error/exception type yet (see
    /// `docs/roadmap.md`), so `failed_block` is type-checked but never
    /// reachable; `finally_block` always runs immediately after
    /// `try_block`, which trivially satisfies "finally always executes"
    /// until real fallible operations exist.
    Try {
        try_block: Block,
        failed_var: Option<String>,
        failed_block: Option<Block>,
        finally_block: Option<Block>,
        span: Span,
    },
    /// `thread: ...` -- v0.1 runs the block inline/synchronously; real
    /// OS-thread execution is a roadmap item.
    Thread {
        body: Block,
        span: Span,
    },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BinOp {
    Add,
    Sub,
    Mul,
    Div,
    Mod,
    Eq,
    NotEq,
    Lt,
    Gt,
    LtEq,
    GtEq,
    And,
    Or,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UnOp {
    Neg,
    Not,
}

#[derive(Debug, Clone)]
pub enum Expr {
    IntLiteral(i64, Span),
    FloatLiteral(f64, Span),
    BoolLiteral(bool, Span),
    StringLiteral(String, Span),
    Identifier(String, Span),
    ListLiteral(Vec<Expr>, Span),
    TupleLiteral(Vec<Expr>, Span),
    DictLiteral(Vec<(String, Expr)>, Span),
    Index {
        base: Box<Expr>,
        index: Box<Expr>,
        span: Span,
    },
    Field {
        base: Box<Expr>,
        field: String,
        span: Span,
    },
    Unary {
        op: UnOp,
        expr: Box<Expr>,
        span: Span,
    },
    Binary {
        op: BinOp,
        lhs: Box<Expr>,
        rhs: Box<Expr>,
        span: Span,
    },
    /// A call `name(args)`. Also covers struct construction (`User()`)
    /// and `await expr` (`name` == `"await"` is never valid so `Await` is
    /// its own variant instead -- see below); disambiguated in sema.
    Call {
        name: String,
        args: Vec<Expr>,
        span: Span,
    },
    /// `await expr` -- v0.1 evaluates `expr` synchronously and returns its
    /// value unchanged; a real async runtime is a roadmap item.
    Await {
        expr: Box<Expr>,
        span: Span,
    },
}

impl Expr {
    pub fn span(&self) -> Span {
        match self {
            Expr::IntLiteral(_, s)
            | Expr::FloatLiteral(_, s)
            | Expr::BoolLiteral(_, s)
            | Expr::StringLiteral(_, s)
            | Expr::Identifier(_, s)
            | Expr::ListLiteral(_, s)
            | Expr::TupleLiteral(_, s)
            | Expr::DictLiteral(_, s)
            | Expr::Index { span: s, .. }
            | Expr::Field { span: s, .. }
            | Expr::Unary { span: s, .. }
            | Expr::Binary { span: s, .. }
            | Expr::Call { span: s, .. }
            | Expr::Await { span: s, .. } => *s,
        }
    }
}
