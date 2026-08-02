//! Intermediate representation (IR).
//!
//! Kite lowers the typed AST into a small, linear, register-based IR
//! before code generation -- the seam where future optimization passes
//! will live, and it keeps [`crate::codegen`] a thin, mechanical
//! translation from IR to LLVM IR text.
//!
//! ## Lists are dynamic
//!
//! A Kite list is a stack-allocated 3-word header (`length`, `capacity`,
//! heap `data` pointer) -- see [`AggLayout::List`] and
//! [`IrInstr::ListAppend`]. Assigning one list-typed local to another
//! copies the header, which copies the `data` pointer, giving Python-like
//! reference/aliasing behavior "for free" from a plain value copy.
//! `append`/`len` are the two builtin operations that make growability
//! observable in v0.1; more list operations are a roadmap item.
//!
//! ## Aggregates otherwise stay local
//!
//! Sema restricts every list/tuple/dict/struct in Kite v0.1 to *scalar*
//! elements/fields, and disallows passing or returning them from
//! functions. As a consequence an aggregate value only ever lives in a
//! named local `alloca`'d slot -- it never flows through a `Temp` SSA
//! register the way scalar values do.
//!
//! ## `try` / `finally`
//!
//! There is no runtime error/exception type yet (`failed` is
//! type-checked by sema but never reachable -- see `docs/roadmap.md`), so
//! the only way to leave a `try` block early is `return`, `break`, or
//! `continue`. [`FunctionLowerer::finally_stack`] tracks every
//! `finally` block whose `try` is currently "in scope"; lowering any of
//! those three statements first replays (inlines) the relevant pending
//! `finally` blocks before emitting the actual jump/return, exactly
//! mirroring what a real exception unwinder would run. This is what
//! guarantees `finally` always executes, even on an early `return`.

use crate::ast::{self, BinOp, TypeName, UnOp};
use std::collections::HashMap;
use std::fmt;

#[derive(Debug, Clone, PartialEq)]
pub enum IrType {
    I64,
    F64,
    Bool,
    Str,
    Void,
    /// A growable list: `{ i64 len, i64 cap, elem* data }` stored by value
    /// in the local's stack slot (see module docs).
    List(Box<IrType>),
    /// A fixed-arity heterogeneous tuple (also used for dictionaries,
    /// whose string keys are compile-time-only metadata -- see
    /// [`AggLayout::Tuple`]).
    Tuple(Vec<IrType>),
    /// A named struct type, declared once at module scope.
    StructRef(String),
}

impl From<&TypeName> for IrType {
    fn from(t: &TypeName) -> Self {
        match t {
            TypeName::Int => IrType::I64,
            TypeName::Float => IrType::F64,
            TypeName::Bool => IrType::Bool,
            TypeName::String => IrType::Str,
            TypeName::Void => IrType::Void,
            TypeName::List(elem) => IrType::List(Box::new(IrType::from(elem.as_ref()))),
            TypeName::Tuple(elems) => IrType::Tuple(elems.iter().map(IrType::from).collect()),
            TypeName::Dict(fields) => {
                IrType::Tuple(fields.iter().map(|(_, t)| IrType::from(t)).collect())
            }
            TypeName::Struct(name) => IrType::StructRef(name.clone()),
        }
    }
}

impl fmt::Display for IrType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            IrType::I64 => write!(f, "i64"),
            IrType::F64 => write!(f, "f64"),
            IrType::Bool => write!(f, "bool"),
            IrType::Str => write!(f, "str"),
            IrType::Void => write!(f, "void"),
            IrType::List(e) => write!(f, "[{e}]"),
            IrType::Tuple(es) => write!(
                f,
                "({})",
                es.iter()
                    .map(|e| e.to_string())
                    .collect::<Vec<_>>()
                    .join(", ")
            ),
            IrType::StructRef(n) => write!(f, "{n}"),
        }
    }
}

/// A value used as an instruction operand: either a compile-time constant
/// or a reference to a previously computed temporary/local. Only ever
/// holds *scalar* values -- see the module docs.
#[derive(Debug, Clone)]
pub enum IrValue {
    ConstInt(i64),
    ConstFloat(f64),
    ConstBool(bool),
    ConstStr(String),
    /// A named local variable (scalar, list header, tuple, or struct),
    /// backed by a stack slot -- reading a *scalar* local requires a
    /// `load` (emitted lazily at the point of use by codegen, or eagerly
    /// via [`IrInstr::Load`] where lowering needs the value pinned before
    /// further code runs -- see [`FunctionLowerer::materialize`]).
    Local(String),
    /// The raw SSA register holding an incoming function parameter, before
    /// it has been spilled into its `alloca`'d slot.
    Param(String),
    /// A numbered SSA-like temporary produced by a previous instruction.
    Temp(u32),
}

pub type Temp = u32;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum IrBinOp {
    AddI,
    SubI,
    MulI,
    DivI,
    RemI,
    AddF,
    SubF,
    MulF,
    DivF,
    EqI,
    NeI,
    LtI,
    GtI,
    LeI,
    GeI,
    EqF,
    NeF,
    LtF,
    GtF,
    LeF,
    GeF,
    EqStr,
    NeStr,
}

/// The compile-time-known shape of an aggregate local, recorded at the
/// point it is initialized so later field/index accesses know how to
/// address into it.
#[derive(Debug, Clone)]
pub enum AggLayout {
    List {
        elem_ty: IrType,
    },
    /// `keys` is `Some` for a dictionary-as-tuple (see [`IrType::Tuple`]),
    /// mapping each string key to its positional field index; `None` for
    /// a real tuple, which is indexed by 1-based literal position only.
    Tuple {
        elem_tys: Vec<IrType>,
        keys: Option<Vec<String>>,
    },
    Struct {
        name: String,
    },
}

#[derive(Debug, Clone)]
pub enum IrInstr {
    Alloca {
        name: String,
        ty: IrType,
    },
    Store {
        name: String,
        value: IrValue,
    },
    /// Eagerly loads a scalar local into a fresh temp *right now* (as
    /// opposed to `IrValue::Local`, which codegen loads lazily at the
    /// point of use). Used to snapshot a value before code that might
    /// mutate the same local runs -- see [`FunctionLowerer::materialize`].
    Load {
        dest: Temp,
        name: String,
        ty: IrType,
    },
    /// Initializes a freshly `alloca`'d aggregate local: a tuple/dict
    /// literal's fields, or a struct's zero-initialized fields. Lists use
    /// [`IrInstr::ListInit`] instead, since they need a heap allocation.
    InitAggregate {
        name: String,
        layout: AggLayout,
        values: Vec<IrValue>,
    },
    /// Allocates a heap buffer sized for `values.len()` elements of
    /// `elem_ty` and points the list header at `name` to it.
    ListInit {
        name: String,
        elem_ty: IrType,
        values: Vec<IrValue>,
    },
    /// `append(list, value)`: grows the heap buffer (doubling capacity)
    /// if needed, then stores `value` at the end and increments length.
    ListAppend {
        base: String,
        value: IrValue,
        elem_ty: IrType,
    },
    /// `len(list)`.
    ListLen {
        dest: Temp,
        base: String,
    },
    /// `len(string)`.
    StrLen {
        dest: Temp,
        value: IrValue,
    },
    BinOp {
        dest: Temp,
        op: IrBinOp,
        lhs: IrValue,
        rhs: IrValue,
    },
    Neg {
        dest: Temp,
        value: IrValue,
        ty: IrType,
    },
    Not {
        dest: Temp,
        value: IrValue,
    },
    Call {
        dest: Option<Temp>,
        name: String,
        args: Vec<IrValue>,
        ret_ty: IrType,
    },
    Print {
        value: IrValue,
        arg_ty: IrType,
    },
    /// Reads/writes a list element with a runtime-checked, 1-based index
    /// (list length is only known at runtime -- see module docs).
    ListIndexGet {
        dest: Temp,
        base: String,
        index: IrValue,
        elem_ty: IrType,
    },
    ListIndexSet {
        base: String,
        index: IrValue,
        value: IrValue,
        elem_ty: IrType,
    },
    /// Reads/writes a compile-time-constant position within a struct or
    /// tuple/dict-as-tuple local.
    FieldGet {
        dest: Temp,
        base: String,
        layout_name: FieldBaseTy,
        position: u32,
        field_ty: IrType,
    },
    FieldSet {
        base: String,
        layout_name: FieldBaseTy,
        position: u32,
        value: IrValue,
        field_ty: IrType,
    },
    Label(String),
    Jump(String),
    Branch {
        cond: IrValue,
        then_label: String,
        else_label: String,
    },
    Return(Option<IrValue>),
    Unreachable,
    /// A codegen no-op: records that `name` now has aggregate `layout`,
    /// without performing any initialization itself (used when a plain
    /// value copy -- e.g. `b = a` aliasing -- already copied the data via
    /// `Load`/`Store`, but `layout_of` still needs a marker to find).
    NoteLayout {
        name: String,
        layout: AggLayout,
    },
}

/// Distinguishes which textual LLVM aggregate type a `FieldGet`/`FieldSet`
/// addresses into, since structs use a named type and tuples/dicts use a
/// literal (structural) type.
#[derive(Debug, Clone)]
pub enum FieldBaseTy {
    Struct(String),
    Tuple(Vec<IrType>),
}

#[derive(Debug, Clone)]
pub struct IrParam {
    pub name: String,
    pub ty: IrType,
}

#[derive(Debug, Clone)]
pub struct IrFunction {
    pub name: String,
    pub params: Vec<IrParam>,
    pub return_type: IrType,
    pub body: Vec<IrInstr>,
}

#[derive(Debug, Clone)]
pub struct IrStruct {
    pub name: String,
    pub fields: Vec<(String, IrType)>,
}

#[derive(Debug, Clone)]
pub struct IrProgram {
    pub structs: Vec<IrStruct>,
    pub functions: Vec<IrFunction>,
}

/// Lowers a whole typed program into IR.
pub fn lower_program(program: &ast::Program) -> IrProgram {
    let struct_table: HashMap<String, Vec<(String, IrType)>> = program
        .structs
        .iter()
        .map(|s| {
            (
                s.name.clone(),
                s.fields
                    .iter()
                    .map(|f| (f.name.clone(), IrType::from(&f.ty)))
                    .collect(),
            )
        })
        .collect();

    let sigs: HashMap<String, IrType> = program
        .functions
        .iter()
        .map(|f| {
            (
                f.name.clone(),
                f.declared_return_type
                    .as_ref()
                    .map(IrType::from)
                    .unwrap_or(IrType::Void),
            )
        })
        .collect();
    let sigs = resolve_return_types(program, sigs);

    let structs = program
        .structs
        .iter()
        .map(|s| IrStruct {
            name: s.name.clone(),
            fields: struct_table[&s.name].clone(),
        })
        .collect();

    let functions = program
        .functions
        .iter()
        .map(|f| lower_function(f, &sigs, &struct_table))
        .collect();

    IrProgram { structs, functions }
}

/// Fills in `Void` placeholders for functions whose return type was
/// inferred by sema (no explicit annotation) by scanning each function's
/// `return` statements once, using the same "first resolvable return
/// wins" heuristic sema used (see its module docs).
fn resolve_return_types(
    program: &ast::Program,
    mut sigs: HashMap<String, IrType>,
) -> HashMap<String, IrType> {
    for func in &program.functions {
        if func.declared_return_type.is_some() {
            continue;
        }
        if let Some(ty) = find_first_return_type(&func.body, &sigs) {
            sigs.insert(func.name.clone(), ty);
        }
    }
    sigs
}

fn find_first_return_type(block: &ast::Block, sigs: &HashMap<String, IrType>) -> Option<IrType> {
    for stmt in &block.statements {
        match stmt {
            ast::Stmt::Return {
                value: Some(expr), ..
            } => {
                if let Some(ty) = quick_expr_type(expr, sigs) {
                    return Some(ty);
                }
            }
            ast::Stmt::Return { value: None, .. } => return Some(IrType::Void),
            ast::Stmt::If {
                then_branch,
                orif_branches,
                else_branch,
                ..
            } => {
                if let Some(ty) = find_first_return_type(then_branch, sigs) {
                    return Some(ty);
                }
                for clause in orif_branches {
                    if let Some(ty) = find_first_return_type(&clause.body, sigs) {
                        return Some(ty);
                    }
                }
                if let Some(else_block) = else_branch {
                    if let Some(ty) = find_first_return_type(else_block, sigs) {
                        return Some(ty);
                    }
                }
            }
            ast::Stmt::Until { body, .. }
            | ast::Stmt::Infinit { body, .. }
            | ast::Stmt::ForRange { body, .. }
            | ast::Stmt::ForEach { body, .. }
            | ast::Stmt::Thread { body, .. } => {
                if let Some(ty) = find_first_return_type(body, sigs) {
                    return Some(ty);
                }
            }
            ast::Stmt::Try {
                try_block,
                finally_block,
                ..
            } => {
                if let Some(ty) = find_first_return_type(try_block, sigs) {
                    return Some(ty);
                }
                if let Some(fin) = finally_block {
                    if let Some(ty) = find_first_return_type(fin, sigs) {
                        return Some(ty);
                    }
                }
            }
            _ => {}
        }
    }
    None
}

fn quick_expr_type(expr: &ast::Expr, sigs: &HashMap<String, IrType>) -> Option<IrType> {
    match expr {
        ast::Expr::IntLiteral(..) => Some(IrType::I64),
        ast::Expr::FloatLiteral(..) => Some(IrType::F64),
        ast::Expr::BoolLiteral(..) => Some(IrType::Bool),
        ast::Expr::StringLiteral(..) => Some(IrType::Str),
        ast::Expr::Binary {
            op: BinOp::Add | BinOp::Sub | BinOp::Mul | BinOp::Div | BinOp::Mod,
            lhs,
            ..
        } => quick_expr_type(lhs, sigs),
        ast::Expr::Binary { .. } => Some(IrType::Bool),
        ast::Expr::Unary { op: UnOp::Not, .. } => Some(IrType::Bool),
        ast::Expr::Unary { expr, .. } => quick_expr_type(expr, sigs),
        ast::Expr::Call { name, .. } if name == "len" => Some(IrType::I64),
        ast::Expr::Call { name, .. } => sigs.get(name).cloned(),
        ast::Expr::Await { expr, .. } => quick_expr_type(expr, sigs),
        _ => None,
    }
}

fn lower_function(
    func: &ast::Function,
    sigs: &HashMap<String, IrType>,
    structs: &HashMap<String, Vec<(String, IrType)>>,
) -> IrFunction {
    let mut lowerer = FunctionLowerer::new(sigs.clone(), structs.clone());
    for param in &func.params {
        let ty = IrType::from(&param.ty);
        lowerer.body.push(IrInstr::Alloca {
            name: param.name.clone(),
            ty: ty.clone(),
        });
        lowerer.body.push(IrInstr::Store {
            name: param.name.clone(),
            value: IrValue::Param(format!("{}.arg", param.name)),
        });
    }
    lowerer.lower_block(&func.body);

    let return_type = sigs.get(&func.name).cloned().unwrap_or(IrType::Void);
    if !matches!(
        lowerer.body.last(),
        Some(IrInstr::Return(_)) | Some(IrInstr::Unreachable)
    ) {
        if return_type == IrType::Void {
            lowerer.body.push(IrInstr::Return(None));
        } else {
            lowerer.body.push(IrInstr::Unreachable);
        }
    }

    IrFunction {
        name: func.name.clone(),
        params: func
            .params
            .iter()
            .map(|p| IrParam {
                name: format!("{}.arg", p.name),
                ty: IrType::from(&p.ty),
            })
            .collect(),
        return_type,
        body: lowerer.body,
    }
}

struct LoopLabels {
    continue_label: String,
    break_label: String,
    /// `finally_stack.len()` at the moment this loop was entered; a
    /// `break`/`continue` replays only the finally blocks pushed *after*
    /// this point (ones entered inside the loop body), not ones
    /// surrounding the loop itself.
    finally_depth: usize,
}

struct FunctionLowerer {
    sigs: HashMap<String, IrType>,
    structs: HashMap<String, Vec<(String, IrType)>>,
    body: Vec<IrInstr>,
    next_temp: Temp,
    next_label: u32,
    loop_stack: Vec<LoopLabels>,
    /// `finally` blocks of every `try` currently "in scope", outermost
    /// first -- see module docs.
    finally_stack: Vec<ast::Block>,
}

impl FunctionLowerer {
    fn new(sigs: HashMap<String, IrType>, structs: HashMap<String, Vec<(String, IrType)>>) -> Self {
        Self {
            sigs,
            structs,
            body: Vec::new(),
            next_temp: 0,
            next_label: 0,
            loop_stack: Vec::new(),
            finally_stack: Vec::new(),
        }
    }

    fn fresh_temp(&mut self) -> Temp {
        let t = self.next_temp;
        self.next_temp += 1;
        t
    }

    fn fresh_label(&mut self, hint: &str) -> String {
        let l = format!("{hint}.{}", self.next_label);
        self.next_label += 1;
        l
    }

    fn fresh_name(&mut self, hint: &str) -> String {
        let n = format!("__{hint}.{}", self.next_temp);
        self.next_temp += 1;
        n
    }

    fn is_terminated(&self) -> bool {
        matches!(
            self.body.last(),
            Some(IrInstr::Return(_)) | Some(IrInstr::Unreachable) | Some(IrInstr::Jump(_))
        )
    }

    /// Forces a value that might be a lazy local reference into a pinned
    /// temp *now*, so code emitted afterward (e.g. a replayed `finally`
    /// block that reassigns the same local) can't change what gets
    /// returned/used. Constants and already-computed temps are unaffected.
    fn materialize(&mut self, value: IrValue, ty: &IrType) -> IrValue {
        match value {
            IrValue::Local(name) => {
                let dest = self.fresh_temp();
                self.body.push(IrInstr::Load {
                    dest,
                    name,
                    ty: ty.clone(),
                });
                IrValue::Temp(dest)
            }
            other => other,
        }
    }

    /// Replays (inlines) every pending `finally` block from `finally_stack`
    /// index `from_depth` onward, innermost first -- run before any early
    /// exit (`return`/`break`/`continue`) that leaves their `try` blocks.
    fn replay_finally_from(&mut self, from_depth: usize) {
        if from_depth >= self.finally_stack.len() {
            return;
        }
        let blocks: Vec<ast::Block> = self.finally_stack[from_depth..].to_vec();
        for block in blocks.into_iter().rev() {
            self.lower_block(&block);
        }
    }

    fn lower_block(&mut self, block: &ast::Block) {
        for stmt in &block.statements {
            self.lower_stmt(stmt);
        }
    }

    fn lower_stmt(&mut self, stmt: &ast::Stmt) {
        match stmt {
            ast::Stmt::Assign { target, value, .. } => self.lower_assign(target, value),
            ast::Stmt::Expr(expr) => {
                self.lower_expr(expr);
            }
            ast::Stmt::Return { value, .. } => {
                let val = value.as_ref().map(|e| {
                    let (v, ty) = self.lower_expr(e);
                    self.materialize(v, &ty)
                });
                self.replay_finally_from(0);
                self.body.push(IrInstr::Return(val));
            }
            ast::Stmt::Break(_) => {
                let top = self
                    .loop_stack
                    .last()
                    .expect("sema guarantees break is inside a loop");
                let (label, depth) = (top.break_label.clone(), top.finally_depth);
                self.replay_finally_from(depth);
                self.body.push(IrInstr::Jump(label));
            }
            ast::Stmt::Continue(_) => {
                let top = self
                    .loop_stack
                    .last()
                    .expect("sema guarantees continue is inside a loop");
                let (label, depth) = (top.continue_label.clone(), top.finally_depth);
                self.replay_finally_from(depth);
                self.body.push(IrInstr::Jump(label));
            }
            ast::Stmt::If {
                condition,
                then_branch,
                orif_branches,
                else_branch,
                ..
            } => {
                self.lower_if_chain(condition, then_branch, orif_branches, else_branch.as_ref());
            }
            ast::Stmt::Until {
                condition, body, ..
            } => self.lower_until(condition, body),
            ast::Stmt::Infinit { body, .. } => self.lower_infinit(body),
            ast::Stmt::ForRange {
                var,
                start,
                end,
                body,
                ..
            } => self.lower_for_range(var, start, end, body),
            ast::Stmt::ForEach {
                var,
                iterable,
                body,
                ..
            } => self.lower_for_each(var, iterable, body),
            ast::Stmt::Try {
                try_block,
                finally_block,
                ..
            } => {
                // `failed` is type-checked by sema but never reachable in
                // v0.1 (no runtime error type exists yet -- see module
                // docs), so it is intentionally not lowered here.
                match finally_block {
                    Some(fin) => {
                        self.finally_stack.push(fin.clone());
                        self.lower_block(try_block);
                        self.finally_stack.pop();
                        // Normal (non-early-exit) completion: run finally
                        // once here. If `try_block` already terminated
                        // (via a `return`/`break`/`continue` that replayed
                        // this exact finally block already), skip it to
                        // avoid running it twice.
                        if !self.is_terminated() {
                            self.lower_block(fin);
                        }
                    }
                    None => self.lower_block(try_block),
                }
            }
            ast::Stmt::Thread { body, .. } => self.lower_block(body),
        }
    }

    fn lower_assign(&mut self, target: &ast::LValue, value: &ast::Expr) {
        match target {
            ast::LValue::Ident(name) => {
                if self.is_aggregate_valued(value) {
                    self.lower_aggregate_into(value, name);
                    return;
                }
                let (val, ty) = self.lower_expr(value);
                if !self.local_declared(name) {
                    self.body.push(IrInstr::Alloca {
                        name: name.clone(),
                        ty,
                    });
                }
                self.body.push(IrInstr::Store {
                    name: name.clone(),
                    value: val,
                });
            }
            ast::LValue::Field { base, field, .. } => {
                let base_name = self.require_named_base(base);
                let (val, field_ty) = self.lower_expr(value);
                let layout = self.layout_of(&base_name);
                let (layout_name, position) = self.resolve_field_position(&layout, field);
                self.body.push(IrInstr::FieldSet {
                    base: base_name,
                    layout_name,
                    position,
                    value: val,
                    field_ty,
                });
            }
            ast::LValue::Index { base, index, .. } => {
                let base_name = self.require_named_base(base);
                let (val, elem_ty) = self.lower_expr(value);
                match self.layout_of(&base_name) {
                    AggLayout::List {
                        elem_ty: list_elem_ty,
                    } => {
                        let (idx_val, _) = self.lower_expr(index);
                        self.body.push(IrInstr::ListIndexSet {
                            base: base_name,
                            index: idx_val,
                            value: val,
                            elem_ty: list_elem_ty,
                        });
                    }
                    layout @ AggLayout::Tuple { .. } => {
                        let key = index_key(index);
                        let (layout_name, position) = self.resolve_field_position(&layout, &key);
                        self.body.push(IrInstr::FieldSet {
                            base: base_name,
                            layout_name,
                            position,
                            value: val,
                            field_ty: elem_ty,
                        });
                    }
                    AggLayout::Struct { .. } => {
                        unreachable!("sema disallows indexing a struct with []")
                    }
                }
            }
        }
    }

    /// True if `expr` evaluates to a list/tuple/dict/struct value: a
    /// literal, a zero-arg struct constructor, or a plain reference to a
    /// local that already holds one of those (the `b = a` aliasing case).
    fn is_aggregate_valued(&self, expr: &ast::Expr) -> bool {
        match expr {
            ast::Expr::ListLiteral(..)
            | ast::Expr::TupleLiteral(..)
            | ast::Expr::DictLiteral(..) => true,
            ast::Expr::Call { name, args, .. } => {
                args.is_empty() && self.structs.contains_key(name)
            }
            ast::Expr::Identifier(name, _) => {
                self.local_declared(name)
                    && matches!(
                        self.infer_local_type(name),
                        IrType::List(_) | IrType::Tuple(_) | IrType::StructRef(_)
                    )
            }
            _ => false,
        }
    }

    /// Lowers an aggregate-valued expression (list/tuple/dict literal,
    /// zero-arg struct constructor, or a bare reference to another
    /// aggregate local for `b = a` aliasing) directly into the named
    /// local `target_name`.
    fn lower_aggregate_into(&mut self, value: &ast::Expr, target_name: &str) {
        match value {
            ast::Expr::Identifier(src_name, _) => {
                // `b = a` where `a` is itself a list/tuple/dict/struct:
                // copy the header/struct by value. For a list this copies
                // the `data` pointer too, so `a` and `b` alias the same
                // heap buffer -- Python-like reference semantics.
                let layout = self.layout_of(src_name);
                let ty = self.infer_local_type(src_name);
                self.body.push(IrInstr::Alloca {
                    name: target_name.to_string(),
                    ty: ty.clone(),
                });
                let dest = self.fresh_temp();
                self.body.push(IrInstr::Load {
                    dest,
                    name: src_name.clone(),
                    ty: ty.clone(),
                });
                self.body.push(IrInstr::Store {
                    name: target_name.to_string(),
                    value: IrValue::Temp(dest),
                });
                self.body.push(IrInstr::NoteLayout {
                    name: target_name.to_string(),
                    layout,
                });
            }
            ast::Expr::ListLiteral(items, _) => {
                let mut lowered = Vec::new();
                let mut elem_ty = IrType::I64;
                for item in items {
                    let (v, ty) = self.lower_expr(item);
                    elem_ty = ty;
                    lowered.push(v);
                }
                self.body.push(IrInstr::Alloca {
                    name: target_name.to_string(),
                    ty: IrType::List(Box::new(elem_ty.clone())),
                });
                self.body.push(IrInstr::ListInit {
                    name: target_name.to_string(),
                    elem_ty,
                    values: lowered,
                });
            }
            ast::Expr::TupleLiteral(items, _) => {
                let mut lowered = Vec::new();
                let mut tys = Vec::new();
                for item in items {
                    let (v, ty) = self.lower_expr(item);
                    tys.push(ty);
                    lowered.push(v);
                }
                self.body.push(IrInstr::Alloca {
                    name: target_name.to_string(),
                    ty: IrType::Tuple(tys.clone()),
                });
                self.body.push(IrInstr::InitAggregate {
                    name: target_name.to_string(),
                    layout: AggLayout::Tuple {
                        elem_tys: tys,
                        keys: None,
                    },
                    values: lowered,
                });
            }
            ast::Expr::DictLiteral(entries, _) => {
                let mut lowered = Vec::new();
                let mut tys = Vec::new();
                let mut keys = Vec::new();
                for (k, v) in entries {
                    let (val, ty) = self.lower_expr(v);
                    keys.push(k.clone());
                    tys.push(ty);
                    lowered.push(val);
                }
                self.body.push(IrInstr::Alloca {
                    name: target_name.to_string(),
                    ty: IrType::Tuple(tys.clone()),
                });
                self.body.push(IrInstr::InitAggregate {
                    name: target_name.to_string(),
                    layout: AggLayout::Tuple {
                        elem_tys: tys,
                        keys: Some(keys),
                    },
                    values: lowered,
                });
            }
            ast::Expr::Call { name, .. } if self.structs.contains_key(name) => {
                let fields = self.structs.get(name).cloned().unwrap_or_default();
                let zero_values: Vec<IrValue> =
                    fields.iter().map(|(_, ty)| zero_value(ty)).collect();
                self.body.push(IrInstr::Alloca {
                    name: target_name.to_string(),
                    ty: IrType::StructRef(name.clone()),
                });
                self.body.push(IrInstr::InitAggregate {
                    name: target_name.to_string(),
                    layout: AggLayout::Struct { name: name.clone() },
                    values: zero_values,
                });
            }
            other => {
                unreachable!("lower_aggregate_into called on non-aggregate expression {other:?}")
            }
        }
    }

    /// Returns the name of a local already holding an aggregate, lowering
    /// `expr` into a fresh synthetic local first if it isn't already a
    /// plain variable reference (e.g. an inline `[1, 2, 3][1]`).
    fn require_named_base(&mut self, expr: &ast::Expr) -> String {
        if let ast::Expr::Identifier(name, _) = expr {
            name.clone()
        } else {
            let name = self.fresh_name("agg");
            self.lower_aggregate_into(expr, &name);
            name
        }
    }

    fn local_declared(&self, name: &str) -> bool {
        self.body
            .iter()
            .any(|i| matches!(i, IrInstr::Alloca { name: n, .. } if n == name))
    }

    /// Recovers the aggregate layout most recently established for
    /// `name` by scanning already-emitted instructions -- mirrors how
    /// scalar local types are recovered (see `infer_local_type`), keeping
    /// IR lowering free of a separate mutable symbol table.
    fn layout_of(&self, name: &str) -> AggLayout {
        self.body
            .iter()
            .rev()
            .find_map(|instr| match instr {
                IrInstr::ListInit {
                    name: n, elem_ty, ..
                } if n == name => Some(AggLayout::List {
                    elem_ty: elem_ty.clone(),
                }),
                IrInstr::InitAggregate {
                    name: n, layout, ..
                } if n == name => Some(layout.clone()),
                IrInstr::NoteLayout { name: n, layout } if n == name => Some(layout.clone()),
                _ => None,
            })
            .unwrap_or_else(|| panic!("internal error: no aggregate layout recorded for `{name}`"))
    }

    fn resolve_field_position(&self, layout: &AggLayout, field: &str) -> (FieldBaseTy, u32) {
        match layout {
            AggLayout::Struct { name } => {
                let fields = self.structs.get(name).cloned().unwrap_or_default();
                let pos = fields.iter().position(|(f, _)| f == field).unwrap_or(0) as u32;
                (FieldBaseTy::Struct(name.clone()), pos)
            }
            AggLayout::Tuple { elem_tys, keys } => {
                let pos = match keys {
                    Some(keys) => keys.iter().position(|k| k == field).unwrap_or(0) as u32,
                    None => field.parse::<u32>().unwrap_or(1).saturating_sub(1),
                };
                (FieldBaseTy::Tuple(elem_tys.clone()), pos)
            }
            AggLayout::List { .. } => unreachable!("field access never targets a list"),
        }
    }

    /// Best-effort scalar/aggregate local type lookup: the type of a
    /// local is whatever type its most recent `Alloca` recorded.
    fn infer_local_type(&self, name: &str) -> IrType {
        self.body
            .iter()
            .rev()
            .find_map(|instr| match instr {
                IrInstr::Alloca { name: n, ty } if n == name => Some(ty.clone()),
                _ => None,
            })
            .unwrap_or(IrType::I64)
    }

    fn lower_if_chain(
        &mut self,
        condition: &ast::Expr,
        then_branch: &ast::Block,
        orif_branches: &[ast::OrifClause],
        else_branch: Option<&ast::Block>,
    ) {
        let end_label = self.fresh_label("if.end");
        self.lower_one_branch(
            condition,
            then_branch,
            orif_branches,
            else_branch,
            0,
            &end_label,
        );
        self.body.push(IrInstr::Label(end_label));
    }

    fn lower_one_branch(
        &mut self,
        condition: &ast::Expr,
        body: &ast::Block,
        remaining_orifs: &[ast::OrifClause],
        else_branch: Option<&ast::Block>,
        depth: u32,
        end_label: &str,
    ) {
        let then_label = self.fresh_label(&format!("if.then.{depth}"));
        let next_label = self.fresh_label(&format!("if.next.{depth}"));

        let (cond_val, _) = self.lower_expr(condition);
        self.body.push(IrInstr::Branch {
            cond: cond_val,
            then_label: then_label.clone(),
            else_label: next_label.clone(),
        });

        self.body.push(IrInstr::Label(then_label));
        self.lower_block(body);
        if !self.is_terminated() {
            self.body.push(IrInstr::Jump(end_label.to_string()));
        }

        self.body.push(IrInstr::Label(next_label));
        if let Some((first, rest)) = remaining_orifs.split_first() {
            self.lower_one_branch(
                &first.condition,
                &first.body,
                rest,
                else_branch,
                depth + 1,
                end_label,
            );
        } else {
            if let Some(else_block) = else_branch {
                self.lower_block(else_block);
            }
            if !self.is_terminated() {
                self.body.push(IrInstr::Jump(end_label.to_string()));
            }
        }
    }

    fn lower_until(&mut self, condition: &ast::Expr, body: &ast::Block) {
        let cond_label = self.fresh_label("until.cond");
        let body_label = self.fresh_label("until.body");
        let end_label = self.fresh_label("until.end");

        self.body.push(IrInstr::Jump(cond_label.clone()));
        self.body.push(IrInstr::Label(cond_label.clone()));
        let (cond_val, _) = self.lower_expr(condition);
        let negated = self.fresh_temp();
        self.body.push(IrInstr::Not {
            dest: negated,
            value: cond_val,
        });
        self.body.push(IrInstr::Branch {
            cond: IrValue::Temp(negated),
            then_label: body_label.clone(),
            else_label: end_label.clone(),
        });

        self.body.push(IrInstr::Label(body_label));
        self.loop_stack.push(LoopLabels {
            continue_label: cond_label.clone(),
            break_label: end_label.clone(),
            finally_depth: self.finally_stack.len(),
        });
        self.lower_block(body);
        self.loop_stack.pop();
        if !self.is_terminated() {
            self.body.push(IrInstr::Jump(cond_label));
        }

        self.body.push(IrInstr::Label(end_label));
    }

    fn lower_infinit(&mut self, body: &ast::Block) {
        let body_label = self.fresh_label("infinit.body");
        let end_label = self.fresh_label("infinit.end");

        self.body.push(IrInstr::Jump(body_label.clone()));
        self.body.push(IrInstr::Label(body_label.clone()));
        self.loop_stack.push(LoopLabels {
            continue_label: body_label.clone(),
            break_label: end_label.clone(),
            finally_depth: self.finally_stack.len(),
        });
        self.lower_block(body);
        self.loop_stack.pop();
        if !self.is_terminated() {
            self.body.push(IrInstr::Jump(body_label));
        }

        self.body.push(IrInstr::Label(end_label));
    }

    fn lower_for_range(
        &mut self,
        var: &str,
        start: &ast::Expr,
        end: &ast::Expr,
        body: &ast::Block,
    ) {
        let (start_val, _) = self.lower_expr(start);
        self.body.push(IrInstr::Alloca {
            name: var.to_string(),
            ty: IrType::I64,
        });
        self.body.push(IrInstr::Store {
            name: var.to_string(),
            value: start_val,
        });

        let (end_val, _) = self.lower_expr(end);
        let end_name = self.fresh_name("for.end");
        self.body.push(IrInstr::Alloca {
            name: end_name.clone(),
            ty: IrType::I64,
        });
        self.body.push(IrInstr::Store {
            name: end_name.clone(),
            value: end_val,
        });

        let cond_label = self.fresh_label("for.cond");
        let body_label = self.fresh_label("for.body");
        let step_label = self.fresh_label("for.step");
        let end_label = self.fresh_label("for.end");

        self.body.push(IrInstr::Jump(cond_label.clone()));
        self.body.push(IrInstr::Label(cond_label.clone()));
        let var_reg = self.fresh_temp();
        self.body.push(IrInstr::BinOp {
            dest: var_reg,
            op: IrBinOp::LeI,
            lhs: IrValue::Local(var.to_string()),
            rhs: IrValue::Local(end_name),
        });
        self.body.push(IrInstr::Branch {
            cond: IrValue::Temp(var_reg),
            then_label: body_label.clone(),
            else_label: end_label.clone(),
        });

        self.body.push(IrInstr::Label(body_label));
        self.loop_stack.push(LoopLabels {
            continue_label: step_label.clone(),
            break_label: end_label.clone(),
            finally_depth: self.finally_stack.len(),
        });
        self.lower_block(body);
        self.loop_stack.pop();
        if !self.is_terminated() {
            self.body.push(IrInstr::Jump(step_label.clone()));
        }

        self.body.push(IrInstr::Label(step_label));
        let incr = self.fresh_temp();
        self.body.push(IrInstr::BinOp {
            dest: incr,
            op: IrBinOp::AddI,
            lhs: IrValue::Local(var.to_string()),
            rhs: IrValue::ConstInt(1),
        });
        self.body.push(IrInstr::Store {
            name: var.to_string(),
            value: IrValue::Temp(incr),
        });
        self.body.push(IrInstr::Jump(cond_label));

        self.body.push(IrInstr::Label(end_label));
    }

    fn lower_for_each(&mut self, var: &str, iterable: &ast::Expr, body: &ast::Block) {
        let list_name = self.require_named_base(iterable);
        let elem_ty = match self.layout_of(&list_name) {
            AggLayout::List { elem_ty } => elem_ty,
            _ => unreachable!("sema guarantees `for ... in` iterates a list"),
        };

        let idx_name = self.fresh_name("for.idx");
        self.body.push(IrInstr::Alloca {
            name: idx_name.clone(),
            ty: IrType::I64,
        });
        self.body.push(IrInstr::Store {
            name: idx_name.clone(),
            value: IrValue::ConstInt(1),
        });

        // Snapshot the length once up front (Python-like: mutating the
        // list mid-iteration doesn't change how many iterations run).
        let len_name = self.fresh_name("for.len");
        let len_reg = self.fresh_temp();
        self.body.push(IrInstr::ListLen {
            dest: len_reg,
            base: list_name.clone(),
        });
        self.body.push(IrInstr::Alloca {
            name: len_name.clone(),
            ty: IrType::I64,
        });
        self.body.push(IrInstr::Store {
            name: len_name.clone(),
            value: IrValue::Temp(len_reg),
        });

        let cond_label = self.fresh_label("foreach.cond");
        let body_label = self.fresh_label("foreach.body");
        let step_label = self.fresh_label("foreach.step");
        let end_label = self.fresh_label("foreach.end");

        self.body.push(IrInstr::Jump(cond_label.clone()));
        self.body.push(IrInstr::Label(cond_label.clone()));
        let cmp = self.fresh_temp();
        self.body.push(IrInstr::BinOp {
            dest: cmp,
            op: IrBinOp::LeI,
            lhs: IrValue::Local(idx_name.clone()),
            rhs: IrValue::Local(len_name),
        });
        self.body.push(IrInstr::Branch {
            cond: IrValue::Temp(cmp),
            then_label: body_label.clone(),
            else_label: end_label.clone(),
        });

        self.body.push(IrInstr::Label(body_label));
        let elem_reg = self.fresh_temp();
        self.body.push(IrInstr::ListIndexGet {
            dest: elem_reg,
            base: list_name.clone(),
            index: IrValue::Local(idx_name.clone()),
            elem_ty: elem_ty.clone(),
        });
        self.body.push(IrInstr::Alloca {
            name: var.to_string(),
            ty: elem_ty,
        });
        self.body.push(IrInstr::Store {
            name: var.to_string(),
            value: IrValue::Temp(elem_reg),
        });

        self.loop_stack.push(LoopLabels {
            continue_label: step_label.clone(),
            break_label: end_label.clone(),
            finally_depth: self.finally_stack.len(),
        });
        self.lower_block(body);
        self.loop_stack.pop();
        if !self.is_terminated() {
            self.body.push(IrInstr::Jump(step_label.clone()));
        }

        self.body.push(IrInstr::Label(step_label));
        let incr = self.fresh_temp();
        self.body.push(IrInstr::BinOp {
            dest: incr,
            op: IrBinOp::AddI,
            lhs: IrValue::Local(idx_name.clone()),
            rhs: IrValue::ConstInt(1),
        });
        self.body.push(IrInstr::Store {
            name: idx_name,
            value: IrValue::Temp(incr),
        });
        self.body.push(IrInstr::Jump(cond_label));

        self.body.push(IrInstr::Label(end_label));
    }

    fn lower_expr(&mut self, expr: &ast::Expr) -> (IrValue, IrType) {
        match expr {
            ast::Expr::IntLiteral(v, _) => (IrValue::ConstInt(*v), IrType::I64),
            ast::Expr::FloatLiteral(v, _) => (IrValue::ConstFloat(*v), IrType::F64),
            ast::Expr::BoolLiteral(v, _) => (IrValue::ConstBool(*v), IrType::Bool),
            ast::Expr::StringLiteral(v, _) => (IrValue::ConstStr(v.clone()), IrType::Str),
            ast::Expr::Identifier(name, _) => {
                (IrValue::Local(name.clone()), self.infer_local_type(name))
            }
            ast::Expr::Unary { op, expr, .. } => self.lower_unary(*op, expr),
            ast::Expr::Binary { op, lhs, rhs, .. } => self.lower_binary(*op, lhs, rhs),
            ast::Expr::Call { name, args, .. } => self.lower_call(name, args),
            ast::Expr::Await { expr, .. } => self.lower_expr(expr),
            ast::Expr::Field { base, field, .. } => self.lower_field_get(base, field),
            ast::Expr::Index { base, index, .. } => self.lower_index_get(base, index),
            ast::Expr::ListLiteral(..)
            | ast::Expr::TupleLiteral(..)
            | ast::Expr::DictLiteral(..) => {
                let name = self.fresh_name("agg");
                self.lower_aggregate_into(expr, &name);
                (IrValue::Local(name.clone()), self.infer_local_type(&name))
            }
        }
    }

    fn lower_field_get(&mut self, base: &ast::Expr, field: &str) -> (IrValue, IrType) {
        let base_name = self.require_named_base(base);
        let layout = self.layout_of(&base_name);
        let (layout_name, position) = self.resolve_field_position(&layout, field);
        let field_ty = match &layout_name {
            FieldBaseTy::Struct(name) => self
                .structs
                .get(name)
                .and_then(|f| f.get(position as usize))
                .map(|(_, t)| t.clone())
                .unwrap_or(IrType::I64),
            FieldBaseTy::Tuple(tys) => tys.get(position as usize).cloned().unwrap_or(IrType::I64),
        };
        let dest = self.fresh_temp();
        self.body.push(IrInstr::FieldGet {
            dest,
            base: base_name,
            layout_name,
            position,
            field_ty: field_ty.clone(),
        });
        (IrValue::Temp(dest), field_ty)
    }

    fn lower_index_get(&mut self, base: &ast::Expr, index: &ast::Expr) -> (IrValue, IrType) {
        let base_name = self.require_named_base(base);
        match self.layout_of(&base_name) {
            AggLayout::List { elem_ty } => {
                let (idx_val, _) = self.lower_expr(index);
                let dest = self.fresh_temp();
                self.body.push(IrInstr::ListIndexGet {
                    dest,
                    base: base_name,
                    index: idx_val,
                    elem_ty: elem_ty.clone(),
                });
                (IrValue::Temp(dest), elem_ty)
            }
            layout @ AggLayout::Tuple { .. } => {
                let key = index_key(index);
                let (layout_name, position) = self.resolve_field_position(&layout, &key);
                let field_ty = match &layout_name {
                    FieldBaseTy::Tuple(tys) => {
                        tys.get(position as usize).cloned().unwrap_or(IrType::I64)
                    }
                    _ => IrType::I64,
                };
                let dest = self.fresh_temp();
                self.body.push(IrInstr::FieldGet {
                    dest,
                    base: base_name,
                    layout_name,
                    position,
                    field_ty: field_ty.clone(),
                });
                (IrValue::Temp(dest), field_ty)
            }
            AggLayout::Struct { .. } => unreachable!("sema disallows indexing a struct with []"),
        }
    }

    fn lower_unary(&mut self, op: UnOp, expr: &ast::Expr) -> (IrValue, IrType) {
        let (val, ty) = self.lower_expr(expr);
        let dest = self.fresh_temp();
        match op {
            UnOp::Neg => {
                self.body.push(IrInstr::Neg {
                    dest,
                    value: val,
                    ty: ty.clone(),
                });
                (IrValue::Temp(dest), ty)
            }
            UnOp::Not => {
                self.body.push(IrInstr::Not { dest, value: val });
                (IrValue::Temp(dest), IrType::Bool)
            }
        }
    }

    fn lower_binary(&mut self, op: BinOp, lhs: &ast::Expr, rhs: &ast::Expr) -> (IrValue, IrType) {
        if matches!(op, BinOp::And | BinOp::Or) {
            return self.lower_short_circuit(op, lhs, rhs);
        }

        let (lval, lty) = self.lower_expr(lhs);
        let (rval, _) = self.lower_expr(rhs);
        let is_float = lty == IrType::F64;
        let is_str = lty == IrType::Str;

        let (ir_op, result_ty) = match op {
            BinOp::Add => (
                if is_float {
                    IrBinOp::AddF
                } else {
                    IrBinOp::AddI
                },
                lty.clone(),
            ),
            BinOp::Sub => (
                if is_float {
                    IrBinOp::SubF
                } else {
                    IrBinOp::SubI
                },
                lty.clone(),
            ),
            BinOp::Mul => (
                if is_float {
                    IrBinOp::MulF
                } else {
                    IrBinOp::MulI
                },
                lty.clone(),
            ),
            BinOp::Div => (
                if is_float {
                    IrBinOp::DivF
                } else {
                    IrBinOp::DivI
                },
                lty.clone(),
            ),
            BinOp::Mod => (IrBinOp::RemI, lty.clone()),
            BinOp::Eq => (
                if is_str {
                    IrBinOp::EqStr
                } else if is_float {
                    IrBinOp::EqF
                } else {
                    IrBinOp::EqI
                },
                IrType::Bool,
            ),
            BinOp::NotEq => (
                if is_str {
                    IrBinOp::NeStr
                } else if is_float {
                    IrBinOp::NeF
                } else {
                    IrBinOp::NeI
                },
                IrType::Bool,
            ),
            BinOp::Lt => (
                if is_float { IrBinOp::LtF } else { IrBinOp::LtI },
                IrType::Bool,
            ),
            BinOp::Gt => (
                if is_float { IrBinOp::GtF } else { IrBinOp::GtI },
                IrType::Bool,
            ),
            BinOp::LtEq => (
                if is_float { IrBinOp::LeF } else { IrBinOp::LeI },
                IrType::Bool,
            ),
            BinOp::GtEq => (
                if is_float { IrBinOp::GeF } else { IrBinOp::GeI },
                IrType::Bool,
            ),
            BinOp::And | BinOp::Or => unreachable!("handled above"),
        };

        let dest = self.fresh_temp();
        self.body.push(IrInstr::BinOp {
            dest,
            op: ir_op,
            lhs: lval,
            rhs: rval,
        });
        (IrValue::Temp(dest), result_ty)
    }

    fn lower_short_circuit(
        &mut self,
        op: BinOp,
        lhs: &ast::Expr,
        rhs: &ast::Expr,
    ) -> (IrValue, IrType) {
        let result_name = self.fresh_name("sc");
        self.body.push(IrInstr::Alloca {
            name: result_name.clone(),
            ty: IrType::Bool,
        });

        let (lval, _) = self.lower_expr(lhs);
        let rhs_label = self.fresh_label("sc.rhs");
        let short_label = self.fresh_label("sc.short");
        let end_label = self.fresh_label("sc.end");

        self.body.push(IrInstr::Branch {
            cond: lval,
            then_label: rhs_label.clone(),
            else_label: short_label.clone(),
        });

        self.body.push(IrInstr::Label(rhs_label));
        let (rval, _) = self.lower_expr(rhs);
        self.body.push(IrInstr::Store {
            name: result_name.clone(),
            value: rval,
        });
        self.body.push(IrInstr::Jump(end_label.clone()));

        self.body.push(IrInstr::Label(short_label));
        let short_value = matches!(op, BinOp::Or);
        self.body.push(IrInstr::Store {
            name: result_name.clone(),
            value: IrValue::ConstBool(short_value),
        });
        self.body.push(IrInstr::Jump(end_label.clone()));

        self.body.push(IrInstr::Label(end_label));
        (IrValue::Local(result_name), IrType::Bool)
    }

    fn lower_call(&mut self, name: &str, args: &[ast::Expr]) -> (IrValue, IrType) {
        if name == "print" {
            let (val, ty) = self.lower_expr(&args[0]);
            self.body.push(IrInstr::Print {
                value: val,
                arg_ty: ty,
            });
            return (IrValue::ConstInt(0), IrType::Void);
        }

        if name == "append" {
            let base_name = self.require_named_base(&args[0]);
            let elem_ty = match self.layout_of(&base_name) {
                AggLayout::List { elem_ty } => elem_ty,
                _ => IrType::I64,
            };
            let (val, _) = self.lower_expr(&args[1]);
            self.body.push(IrInstr::ListAppend {
                base: base_name,
                value: val,
                elem_ty,
            });
            return (IrValue::ConstInt(0), IrType::Void);
        }

        if name == "len" {
            let (val, ty) = self.lower_expr(&args[0]);
            let dest = self.fresh_temp();
            match (&val, &ty) {
                (IrValue::Local(base), IrType::List(_)) => {
                    self.body.push(IrInstr::ListLen {
                        dest,
                        base: base.clone(),
                    });
                }
                _ => {
                    self.body.push(IrInstr::StrLen { dest, value: val });
                }
            }
            return (IrValue::Temp(dest), IrType::I64);
        }

        let mut arg_vals = Vec::new();
        for arg in args {
            arg_vals.push(self.lower_expr(arg).0);
        }
        let ret_ty = self.sigs.get(name).cloned().unwrap_or(IrType::Void);
        if ret_ty == IrType::Void {
            self.body.push(IrInstr::Call {
                dest: None,
                name: name.to_string(),
                args: arg_vals,
                ret_ty,
            });
            (IrValue::ConstInt(0), IrType::Void)
        } else {
            let dest = self.fresh_temp();
            self.body.push(IrInstr::Call {
                dest: Some(dest),
                name: name.to_string(),
                args: arg_vals,
                ret_ty: ret_ty.clone(),
            });
            (IrValue::Temp(dest), ret_ty)
        }
    }
}

/// Dict/tuple indices resolve to a field name at IR-lowering time: a
/// string-literal key for dicts, or a 1-based literal position for
/// tuples (both already validated by sema).
fn index_key(index: &ast::Expr) -> String {
    match index {
        ast::Expr::StringLiteral(s, _) => s.clone(),
        ast::Expr::IntLiteral(v, _) => v.to_string(),
        _ => unreachable!("sema requires tuple/dict indices to be literals"),
    }
}

fn zero_value(ty: &IrType) -> IrValue {
    match ty {
        IrType::I64 => IrValue::ConstInt(0),
        IrType::F64 => IrValue::ConstFloat(0.0),
        IrType::Bool => IrValue::ConstBool(false),
        IrType::Str => IrValue::ConstStr(String::new()),
        _ => IrValue::ConstInt(0),
    }
}
