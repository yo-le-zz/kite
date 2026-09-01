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
/// collections-of-structs are not yet supported
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
    /// A named enum type declared with `enum Name: ...`. Represented at
    /// runtime as a plain `int` tag (variant declaration order, starting
    /// at 0) -- printing an enum value shows that numeric tag in v0.1;
    /// string variant names at runtime aren't implemented yet.
    Enum(String),
    /// A dictionary literal's type: v0.1 dictionaries have a fixed,
    /// compile-time-known set of string keys (inferred from the literal
    /// that created them) each with their own value type -- structurally
    /// identical to an anonymous struct. Indexing requires a string
    /// *literal* key, resolved at compile time. General dynamic hash maps
    /// aren't implemented yet.
    Dict(Vec<(String, TypeName)>),
    /// `ptr<T>` -- a raw pointer to a `T`, manually managed with
    /// `alloc`/`free` (see `docs/pointers.md`). `T` is restricted to
    /// `int`/`float`/`bool`/`string`/a struct name -- `ptr<ptr<T>>`
    /// (a pointer to a pointer) isn't supported yet.
    Ptr(Box<TypeName>),
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
            TypeName::Enum(name) => write!(f, "{name}"),
            TypeName::Ptr(inner) => write!(f, "ptr<{inner}>"),
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
    pub enums: Vec<EnumDef>,
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
pub struct EnumVariant {
    pub name: String,
    pub span: Span,
}

#[derive(Debug, Clone)]
pub struct EnumDef {
    pub name: String,
    pub variants: Vec<EnumVariant>,
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
    /// `return` statements (unit if there are none). Always required
    /// (never inferred) for `extern` declarations, since there's no body
    /// to infer it from.
    pub declared_return_type: Option<TypeName>,
    pub is_async: bool,
    /// True for `extern make name(...):` -- a declaration of a function
    /// implemented elsewhere (in C, or any other object file linked in
    /// at build time) with no Kite body. See `ast::Program::externs`...
    /// actually stored inline here: `body` is `None` exactly when this
    /// is true.
    pub is_extern: bool,
    /// `None` for an `extern` declaration (no Kite implementation);
    /// `Some` for every ordinary function.
    pub body: Option<Block>,
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
    /// `*p = value` -- writes through a `ptr<T>`.
    Deref {
        target: Box<Expr>,
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
    /// below), so `failed_block` is type-checked but never
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
    /// OS-thread execution isn't implemented yet.
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
    /// `*p` -- dereference a `ptr<T>`, yielding the `T` it points to.
    Deref,
    /// `&x` -- address-of a local variable, yielding a `ptr<T>`. Only
    /// valid when `expr` is a plain identifier (checked in sema, not
    /// the parser, so the error message can name the actual expression
    /// that isn't addressable).
    AddrOf,
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
    /// value unchanged; a real async runtime isn't implemented yet.
    Await {
        expr: Box<Expr>,
        span: Span,
    },
    /// `null` -- the null-pointer literal. Its type is never known from
    /// the literal alone (see `docs/pointers.md`); sema resolves it from
    /// context (an annotated/already-declared `ptr<T>` target, or the
    /// other side of a `==`/`!=` comparison).
    NullLit(Span),
    /// `alloc(T)` -- heap-allocates one zero-initialized `T` and returns
    /// a `ptr<T>` to it. `ty` is a type, not a value, hence its own AST
    /// node rather than reusing `Call` -- see `docs/pointers.md`.
    Alloc {
        ty: TypeName,
        span: Span,
    },
    /// `alloc_n(T, count)` -- heap-allocates `count` contiguous,
    /// zero-initialized `T`s and returns a `ptr<T>` to the first one.
    /// See `docs/pointers.md`.
    AllocN {
        ty: TypeName,
        count: Box<Expr>,
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
            | Expr::NullLit(s)
            | Expr::Alloc { span: s, .. }
            | Expr::AllocN { span: s, .. }
            | Expr::Await { span: s, .. } => *s,
        }
    }
}
