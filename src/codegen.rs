//! Code generation: translates [`crate::ir`] into textual LLVM IR (`.ll`).
//!
//! Kite emits LLVM IR as text rather than binding directly to the LLVM
//! C++ API, keeping the compiler's own dependency graph small while still
//! getting everything LLVM provides for free via the system
//! `clang` toolchain invoked by [`crate::driver`].
//!
//! ## Runtime support
//!
//! Kite v0.1 has no bespoke runtime library -- it leans on a handful of
//! libc functions declared at the top of every module: `printf` (for
//! `print`), `malloc`/`realloc`/`free`/`memcpy` (for growable lists --
//! see [`emit_list_append`]), `strlen` (for `len` on strings), and `exit`
//! (for the safety abort a failed runtime bounds check triggers).

use crate::ir::*;
use std::collections::HashMap;
use std::fmt::Write as _;

pub struct CodegenOptions {
    pub target_triple: Option<String>,
}

/// Emits a complete LLVM IR module (as text) for a Kite program.
pub fn emit_module(program: &IrProgram, options: &CodegenOptions) -> String {
    let mut ctx = ModuleCtx::default();
    for s in &program.structs {
        ctx.structs.insert(s.name.clone(), s.fields.clone());
    }
    let mut out = String::new();

    if let Some(triple) = &options.target_triple {
        let _ = writeln!(out, "target triple = \"{triple}\"");
        out.push('\n');
    }

    // Named struct type declarations.
    for s in &program.structs {
        let fields: Vec<String> = s.fields.iter().map(|(_, ty)| llvm_type(ty)).collect();
        let _ = writeln!(out, "%{} = type {{ {} }}", s.name, fields.join(", "));
    }
    if !program.structs.is_empty() {
        out.push('\n');
    }

    out.push_str("declare i32 @printf(i8*, ...)\n");
    out.push_str("declare i8* @malloc(i64)\n");
    out.push_str("declare void @free(i8*)\n");
    out.push_str("declare i8* @memcpy(i8*, i8*, i64)\n");
    out.push_str("declare i64 @strlen(i8*)\n");
    out.push_str("declare i32 @strcmp(i8*, i8*)\n");
    out.push_str("declare void @exit(i32)\n\n");

    out.push_str(&global_string("@.fmt.int", "%lld\\0A\\00"));
    out.push_str(&global_string("@.fmt.float", "%f\\0A\\00"));
    out.push_str(&global_string("@.fmt.str", "%s\\0A\\00"));
    out.push_str(&global_string("@.str.true", "true\\00"));
    out.push_str(&global_string("@.str.false", "false\\00"));
    out.push_str(&global_string(
        "@.err.bounds",
        "kite: index %lld out of range for a list of length %lld (lists are 1-indexed)\\0A\\00",
    ));
    out.push('\n');

    for func in &program.functions {
        collect_string_constants(func, &mut ctx);
    }
    for (text, name) in &ctx.string_constants {
        out.push_str(&global_string(name, &escape_llvm_string(text)));
    }
    if !ctx.string_constants.is_empty() {
        out.push('\n');
    }

    for func in &program.functions {
        emit_function(func, &mut ctx, &mut out);
        out.push('\n');
    }

    out
}

#[derive(Default)]
struct ModuleCtx {
    string_constants: HashMap<String, String>,
    next_string_id: u32,
    structs: HashMap<String, Vec<(String, IrType)>>,
}

impl ModuleCtx {
    fn intern_string(&mut self, text: &str) -> String {
        if let Some(name) = self.string_constants.get(text) {
            return name.clone();
        }
        let name = format!("@.str.{}", self.next_string_id);
        self.next_string_id += 1;
        self.string_constants.insert(text.to_string(), name.clone());
        name
    }
}

fn collect_string_constants(func: &IrFunction, ctx: &mut ModuleCtx) {
    fn visit(v: &IrValue, ctx: &mut ModuleCtx) {
        if let IrValue::ConstStr(s) = v {
            ctx.intern_string(s);
        }
    }
    for instr in &func.body {
        match instr {
            IrInstr::Store { value, .. } => visit(value, ctx),
            IrInstr::InitAggregate { values, .. } | IrInstr::ListInit { values, .. } => {
                for v in values {
                    visit(v, ctx);
                }
            }
            IrInstr::ListAppend { value, .. } => visit(value, ctx),
            IrInstr::StrLen { value, .. } => visit(value, ctx),
            IrInstr::BinOp { lhs, rhs, .. } => {
                visit(lhs, ctx);
                visit(rhs, ctx);
            }
            IrInstr::Neg { value, .. } | IrInstr::Not { value, .. } => visit(value, ctx),
            IrInstr::Call { args, .. } => {
                for a in args {
                    visit(a, ctx);
                }
            }
            IrInstr::Print { value, .. } => visit(value, ctx),
            IrInstr::ListIndexGet { index, .. } => visit(index, ctx),
            IrInstr::ListIndexSet { index, value, .. } => {
                visit(index, ctx);
                visit(value, ctx);
            }
            IrInstr::FieldSet { value, .. } => visit(value, ctx),
            IrInstr::Branch { cond, .. } => visit(cond, ctx),
            IrInstr::Return(Some(v)) => visit(v, ctx),
            _ => {}
        }
    }
}

fn global_string(name: &str, escaped_body_with_null: &str) -> String {
    let len = llvm_string_byte_len(escaped_body_with_null);
    format!("{name} = private unnamed_addr constant [{len} x i8] c\"{escaped_body_with_null}\"\n")
}

fn llvm_string_byte_len(s: &str) -> usize {
    let chars: Vec<char> = s.chars().collect();
    let mut i = 0;
    let mut count = 0;
    while i < chars.len() {
        if chars[i] == '\\' && i + 2 < chars.len() {
            i += 3;
        } else {
            i += 1;
        }
        count += 1;
    }
    count
}

fn escape_llvm_string(s: &str) -> String {
    let mut out = String::new();
    for byte in s.as_bytes() {
        match *byte {
            b'"' => out.push_str("\\22"),
            b'\\' => out.push_str("\\5C"),
            0x20..=0x7E => out.push(*byte as char),
            _ => {
                let _ = write!(out, "\\{byte:02X}");
            }
        }
    }
    out.push_str("\\00");
    out
}

fn string_byte_len_with_nul(s: &str) -> usize {
    s.as_bytes().len() + 1
}

struct FnCtx<'a> {
    ctx: &'a ModuleCtx,
    locals: HashMap<String, IrType>,
}

fn emit_function(func: &IrFunction, ctx: &mut ModuleCtx, out: &mut String) {
    let is_main = func.name == "main";
    let llvm_ret_ty = if is_main {
        "i32".to_string()
    } else {
        llvm_type(&func.return_type)
    };

    let params_sig: Vec<String> = func
        .params
        .iter()
        .map(|p| format!("{} %{}", llvm_type(&p.ty), p.name))
        .collect();

    let _ = writeln!(
        out,
        "define {} @{}({}) {{",
        llvm_ret_ty,
        func.name,
        params_sig.join(", ")
    );
    out.push_str("entry:\n");

    let mut fctx = FnCtx {
        ctx,
        locals: HashMap::new(),
    };
    for instr in &func.body {
        emit_instr(instr, &mut fctx, is_main, out);
    }

    out.push_str("}\n");
}

fn llvm_type(ty: &IrType) -> String {
    match ty {
        IrType::I64 => "i64".to_string(),
        IrType::F64 => "double".to_string(),
        IrType::Bool => "i1".to_string(),
        IrType::Str => "i8*".to_string(),
        IrType::Void => "void".to_string(),
        IrType::List(elem) => format!("{{ i64, i64, {}* }}", llvm_type(elem)),
        IrType::Tuple(elems) => format!(
            "{{ {} }}",
            elems.iter().map(llvm_type).collect::<Vec<_>>().join(", ")
        ),
        IrType::StructRef(name) => format!("%{name}"),
    }
}

fn emit_instr(instr: &IrInstr, fctx: &mut FnCtx, is_main: bool, out: &mut String) {
    match instr {
        IrInstr::Alloca { name, ty } => {
            fctx.locals.insert(name.clone(), ty.clone());
            let _ = writeln!(out, "  %{name} = alloca {}", llvm_type(ty));
        }
        IrInstr::Store { name, value } => {
            let ty = fctx.locals.get(name).cloned().unwrap_or(IrType::I64);
            let lty = llvm_type(&ty);
            let (val_str, _) = emit_value(value, fctx, &ty, out);
            let _ = writeln!(out, "  store {lty} {val_str}, {lty}* %{name}");
        }
        IrInstr::Load { dest, name, ty } => {
            let lty = llvm_type(ty);
            let _ = writeln!(out, "  %t{dest} = load {lty}, {lty}* %{name}");
        }
        IrInstr::InitAggregate { name, values, .. } => {
            let ty = fctx.locals.get(name).cloned().unwrap_or(IrType::Void);
            let lty = llvm_type(&ty);
            let elem_tys = match &ty {
                IrType::Tuple(tys) => tys.clone(),
                IrType::StructRef(n) => fctx
                    .ctx
                    .structs
                    .get(n)
                    .map(|f| f.iter().map(|(_, t)| t.clone()).collect())
                    .unwrap_or_default(),
                _ => vec![],
            };
            for (i, value) in values.iter().enumerate() {
                let field_ty = elem_tys.get(i).cloned().unwrap_or(IrType::I64);
                let (val_str, _) = emit_value(value, fctx, &field_ty, out);
                let field_lty = llvm_type(&field_ty);
                let ptr = fresh_ptr_name();
                let _ = writeln!(
                    out,
                    "  {ptr} = getelementptr inbounds {lty}, {lty}* %{name}, i32 0, i32 {i}"
                );
                let _ = writeln!(out, "  store {field_lty} {val_str}, {field_lty}* {ptr}");
            }
        }
        IrInstr::ListInit {
            name,
            elem_ty,
            values,
        } => emit_list_init(name, elem_ty, values, fctx, out),
        IrInstr::ListAppend {
            base,
            value,
            elem_ty,
        } => emit_list_append(base, value, elem_ty, fctx, out),
        IrInstr::ListLen { dest, base } => {
            let elem_ty = match fctx.locals.get(base) {
                Some(IrType::List(e)) => (**e).clone(),
                _ => IrType::I64,
            };
            let ety = llvm_type(&elem_ty);
            let header_ty = format!("{{ i64, i64, {ety}* }}");
            let len_ptr = fresh_ptr_name();
            let _ = writeln!(out, "  {len_ptr} = getelementptr inbounds {header_ty}, {header_ty}* %{base}, i32 0, i32 0");
            let _ = writeln!(out, "  %t{dest} = load i64, i64* {len_ptr}");
        }
        IrInstr::StrLen { dest, value } => {
            let (v, _) = emit_value(value, fctx, &IrType::Str, out);
            let _ = writeln!(out, "  %t{dest} = call i64 @strlen(i8* {v})");
        }
        IrInstr::BinOp { dest, op, lhs, rhs } => emit_binop(*dest, *op, lhs, rhs, fctx, out),
        IrInstr::Neg { dest, value, ty } => {
            let (v, _) = emit_value(value, fctx, ty, out);
            match ty {
                IrType::F64 => {
                    let _ = writeln!(out, "  %t{dest} = fneg double {v}");
                }
                _ => {
                    let _ = writeln!(out, "  %t{dest} = sub i64 0, {v}");
                }
            }
        }
        IrInstr::Not { dest, value } => {
            let (v, _) = emit_value(value, fctx, &IrType::Bool, out);
            let _ = writeln!(out, "  %t{dest} = xor i1 {v}, true");
        }
        IrInstr::Call {
            dest,
            name,
            args,
            ret_ty,
        } => {
            let mut arg_strs = Vec::new();
            for a in args {
                let ty = value_hint_type(a, fctx);
                let (s, _) = emit_value(a, fctx, &ty, out);
                arg_strs.push(format!("{} {s}", llvm_type(&ty)));
            }
            let rty = llvm_type(ret_ty);
            match dest {
                Some(d) => {
                    let _ = writeln!(out, "  %t{d} = call {rty} @{name}({})", arg_strs.join(", "));
                }
                None => {
                    let _ = writeln!(out, "  call {rty} @{name}({})", arg_strs.join(", "));
                }
            }
        }
        IrInstr::Print { value, arg_ty } => emit_print(value, arg_ty, fctx, out),
        IrInstr::ListIndexGet {
            dest,
            base,
            index,
            elem_ty,
        } => {
            let data_ptr = emit_list_bounds_checked_ptr(base, index, elem_ty, fctx, out);
            let ety = llvm_type(elem_ty);
            let _ = writeln!(out, "  %t{dest} = load {ety}, {ety}* {data_ptr}");
        }
        IrInstr::ListIndexSet {
            base,
            index,
            value,
            elem_ty,
        } => {
            let data_ptr = emit_list_bounds_checked_ptr(base, index, elem_ty, fctx, out);
            let ety = llvm_type(elem_ty);
            let (val_str, _) = emit_value(value, fctx, elem_ty, out);
            let _ = writeln!(out, "  store {ety} {val_str}, {ety}* {data_ptr}");
        }
        IrInstr::FieldGet {
            dest,
            base,
            layout_name,
            position,
            field_ty,
        } => {
            let agg_lty = field_base_llvm_type(layout_name);
            let ptr = fresh_ptr_name();
            let _ = writeln!(out, "  {ptr} = getelementptr inbounds {agg_lty}, {agg_lty}* %{base}, i32 0, i32 {position}");
            let fty = llvm_type(field_ty);
            let _ = writeln!(out, "  %t{dest} = load {fty}, {fty}* {ptr}");
        }
        IrInstr::FieldSet {
            base,
            layout_name,
            position,
            value,
            field_ty,
        } => {
            let agg_lty = field_base_llvm_type(layout_name);
            let (val_str, _) = emit_value(value, fctx, field_ty, out);
            let ptr = fresh_ptr_name();
            let _ = writeln!(out, "  {ptr} = getelementptr inbounds {agg_lty}, {agg_lty}* %{base}, i32 0, i32 {position}");
            let fty = llvm_type(field_ty);
            let _ = writeln!(out, "  store {fty} {val_str}, {fty}* {ptr}");
        }
        IrInstr::Label(name) => {
            let _ = writeln!(out, "{}:", sanitize_label(name));
        }
        IrInstr::Jump(target) => {
            let _ = writeln!(out, "  br label %{}", sanitize_label(target));
        }
        IrInstr::Branch {
            cond,
            then_label,
            else_label,
        } => {
            let (c, _) = emit_value(cond, fctx, &IrType::Bool, out);
            let _ = writeln!(
                out,
                "  br i1 {c}, label %{}, label %{}",
                sanitize_label(then_label),
                sanitize_label(else_label)
            );
        }
        IrInstr::Return(value) => {
            if is_main {
                match value {
                    Some(v) => {
                        let (val, _) = emit_value(v, fctx, &IrType::I64, out);
                        let _ = writeln!(out, "  ret i32 {val}");
                    }
                    None => {
                        let _ = writeln!(out, "  ret i32 0");
                    }
                }
            } else {
                match value {
                    Some(v) => {
                        let ty = value_hint_type(v, fctx);
                        let (val, _) = emit_value(v, fctx, &ty, out);
                        let _ = writeln!(out, "  ret {} {val}", llvm_type(&ty));
                    }
                    None => {
                        let _ = writeln!(out, "  ret void");
                    }
                }
            }
        }
        IrInstr::Unreachable => out.push_str("  unreachable\n"),
        IrInstr::NoteLayout { .. } => {}
    }
}

fn field_base_llvm_type(layout: &FieldBaseTy) -> String {
    match layout {
        FieldBaseTy::Struct(name) => format!("%{name}"),
        FieldBaseTy::Tuple(tys) => format!(
            "{{ {} }}",
            tys.iter().map(llvm_type).collect::<Vec<_>>().join(", ")
        ),
    }
}

/// Allocates a heap buffer for a list literal's elements and initializes
/// the 3-word header (`len`, `cap`, `data`) pointed to by `name`.
fn emit_list_init(
    name: &str,
    elem_ty: &IrType,
    values: &[IrValue],
    fctx: &mut FnCtx,
    out: &mut String,
) {
    let ety = llvm_type(elem_ty);
    let n = values.len();
    let header_ty = format!("{{ i64, i64, {ety}* }}");

    let raw_ptr = fresh_ptr_name();
    let total_bytes = elem_byte_size(elem_ty) * n.max(1);
    let _ = writeln!(out, "  {raw_ptr} = call i8* @malloc(i64 {total_bytes})");
    let data_ptr = fresh_ptr_name();
    let _ = writeln!(out, "  {data_ptr} = bitcast i8* {raw_ptr} to {ety}*");

    for (i, value) in values.iter().enumerate() {
        let (val_str, _) = emit_value(value, fctx, elem_ty, out);
        let elem_ptr = fresh_ptr_name();
        let _ = writeln!(
            out,
            "  {elem_ptr} = getelementptr inbounds {ety}, {ety}* {data_ptr}, i64 {i}"
        );
        let _ = writeln!(out, "  store {ety} {val_str}, {ety}* {elem_ptr}");
    }

    let len_ptr = fresh_ptr_name();
    let _ = writeln!(
        out,
        "  {len_ptr} = getelementptr inbounds {header_ty}, {header_ty}* %{name}, i32 0, i32 0"
    );
    let _ = writeln!(out, "  store i64 {n}, i64* {len_ptr}");
    let cap_ptr = fresh_ptr_name();
    let _ = writeln!(
        out,
        "  {cap_ptr} = getelementptr inbounds {header_ty}, {header_ty}* %{name}, i32 0, i32 1"
    );
    let _ = writeln!(out, "  store i64 {n}, i64* {cap_ptr}");
    let data_field_ptr = fresh_ptr_name();
    let _ = writeln!(out, "  {data_field_ptr} = getelementptr inbounds {header_ty}, {header_ty}* %{name}, i32 0, i32 2");
    let _ = writeln!(out, "  store {ety}* {data_ptr}, {ety}** {data_field_ptr}");
}

/// `append(list, value)`: grows the heap buffer (doubling capacity, or
/// starting at capacity 1) if `len == cap`, then writes `value` at the
/// end and increments `len`.
fn emit_list_append(
    base: &str,
    value: &IrValue,
    elem_ty: &IrType,
    fctx: &mut FnCtx,
    out: &mut String,
) {
    let ety = llvm_type(elem_ty);
    let header_ty = format!("{{ i64, i64, {ety}* }}");
    let elem_size = elem_byte_size(elem_ty);

    let len_ptr = fresh_ptr_name();
    let _ = writeln!(
        out,
        "  {len_ptr} = getelementptr inbounds {header_ty}, {header_ty}* %{base}, i32 0, i32 0"
    );
    let cap_ptr = fresh_ptr_name();
    let _ = writeln!(
        out,
        "  {cap_ptr} = getelementptr inbounds {header_ty}, {header_ty}* %{base}, i32 0, i32 1"
    );
    let data_field_ptr = fresh_ptr_name();
    let _ = writeln!(out, "  {data_field_ptr} = getelementptr inbounds {header_ty}, {header_ty}* %{base}, i32 0, i32 2");

    let len_reg = fresh_reg_name();
    let _ = writeln!(out, "  {len_reg} = load i64, i64* {len_ptr}");
    let cap_reg = fresh_reg_name();
    let _ = writeln!(out, "  {cap_reg} = load i64, i64* {cap_ptr}");

    let needs_grow = fresh_reg_name();
    let _ = writeln!(out, "  {needs_grow} = icmp sge i64 {len_reg}, {cap_reg}");
    let grow_label = fresh_block_label("append.grow");
    let after_label = fresh_block_label("append.after");
    let _ = writeln!(
        out,
        "  br i1 {needs_grow}, label %{grow_label}, label %{after_label}"
    );

    let _ = writeln!(out, "{grow_label}:");
    let old_data_reg = fresh_reg_name();
    let _ = writeln!(
        out,
        "  {old_data_reg} = load {ety}*, {ety}** {data_field_ptr}"
    );
    let one_if_zero = fresh_reg_name();
    let _ = writeln!(out, "  {one_if_zero} = icmp eq i64 {cap_reg}, 0");
    let doubled = fresh_reg_name();
    let _ = writeln!(out, "  {doubled} = mul i64 {cap_reg}, 2");
    let new_cap = fresh_reg_name();
    let _ = writeln!(
        out,
        "  {new_cap} = select i1 {one_if_zero}, i64 1, i64 {doubled}"
    );
    let new_bytes = fresh_reg_name();
    let _ = writeln!(out, "  {new_bytes} = mul i64 {new_cap}, {elem_size}");
    let new_raw = fresh_ptr_name();
    let _ = writeln!(out, "  {new_raw} = call i8* @malloc(i64 {new_bytes})");
    let new_data = fresh_ptr_name();
    let _ = writeln!(out, "  {new_data} = bitcast i8* {new_raw} to {ety}*");
    let old_bytes = fresh_reg_name();
    let _ = writeln!(out, "  {old_bytes} = mul i64 {len_reg}, {elem_size}");
    let old_data_i8 = fresh_ptr_name();
    let _ = writeln!(
        out,
        "  {old_data_i8} = bitcast {ety}* {old_data_reg} to i8*"
    );
    let _ = writeln!(
        out,
        "  call i8* @memcpy(i8* {new_raw}, i8* {old_data_i8}, i64 {old_bytes})"
    );
    let _ = writeln!(out, "  call void @free(i8* {old_data_i8})");
    let _ = writeln!(out, "  store {ety}* {new_data}, {ety}** {data_field_ptr}");
    let _ = writeln!(out, "  store i64 {new_cap}, i64* {cap_ptr}");
    let _ = writeln!(out, "  br label %{after_label}");

    let _ = writeln!(out, "{after_label}:");
    let data_reg = fresh_reg_name();
    let _ = writeln!(out, "  {data_reg} = load {ety}*, {ety}** {data_field_ptr}");
    let (val_str, _) = emit_value(value, fctx, elem_ty, out);
    let write_ptr = fresh_ptr_name();
    let _ = writeln!(
        out,
        "  {write_ptr} = getelementptr inbounds {ety}, {ety}* {data_reg}, i64 {len_reg}"
    );
    let _ = writeln!(out, "  store {ety} {val_str}, {ety}* {write_ptr}");
    let new_len = fresh_reg_name();
    let _ = writeln!(out, "  {new_len} = add i64 {len_reg}, 1");
    let _ = writeln!(out, "  store i64 {new_len}, i64* {len_ptr}");
}

/// Computes and bounds-checks a 1-based list index at runtime, aborting
/// via `printf` + `exit(1)` on failure, and returns a pointer to the
/// element.
fn emit_list_bounds_checked_ptr(
    base: &str,
    index: &IrValue,
    elem_ty: &IrType,
    fctx: &mut FnCtx,
    out: &mut String,
) -> String {
    let ety = llvm_type(elem_ty);
    let header_ty = format!("{{ i64, i64, {ety}* }}");

    let (idx_val, _) = emit_value(index, fctx, &IrType::I64, out);
    let len_ptr = fresh_ptr_name();
    let _ = writeln!(
        out,
        "  {len_ptr} = getelementptr inbounds {header_ty}, {header_ty}* %{base}, i32 0, i32 0"
    );
    let len_reg = fresh_reg_name();
    let _ = writeln!(out, "  {len_reg} = load i64, i64* {len_ptr}");

    let idx0 = fresh_reg_name();
    let _ = writeln!(out, "  {idx0} = sub i64 {idx_val}, 1");
    let too_small = fresh_reg_name();
    let _ = writeln!(out, "  {too_small} = icmp slt i64 {idx0}, 0");
    let too_big = fresh_reg_name();
    let _ = writeln!(out, "  {too_big} = icmp sge i64 {idx0}, {len_reg}");
    let out_of_range = fresh_reg_name();
    let _ = writeln!(out, "  {out_of_range} = or i1 {too_small}, {too_big}");

    let ok_label = fresh_block_label("idx.ok");
    let fail_label = fresh_block_label("idx.fail");
    let _ = writeln!(
        out,
        "  br i1 {out_of_range}, label %{fail_label}, label %{ok_label}"
    );

    let _ = writeln!(out, "{fail_label}:");
    let err_len = string_byte_len_with_nul(
        "kite: index %lld out of range for a list of length %lld (lists are 1-indexed)\n",
    );
    let fmt_ptr = fresh_ptr_name();
    let _ = writeln!(out, "  {fmt_ptr} = getelementptr inbounds [{err_len} x i8], [{err_len} x i8]* @.err.bounds, i64 0, i64 0");
    let _ = writeln!(
        out,
        "  call i32 (i8*, ...) @printf(i8* {fmt_ptr}, i64 {idx_val}, i64 {len_reg})"
    );
    let _ = writeln!(out, "  call void @exit(i32 1)");
    let _ = writeln!(out, "  unreachable");

    let _ = writeln!(out, "{ok_label}:");
    let data_ptr = fresh_ptr_name();
    let data_field_ptr = fresh_ptr_name();
    let _ = writeln!(out, "  {data_field_ptr} = getelementptr inbounds {header_ty}, {header_ty}* %{base}, i32 0, i32 2");
    let _ = writeln!(out, "  {data_ptr} = load {ety}*, {ety}** {data_field_ptr}");
    let elem_ptr = fresh_ptr_name();
    let _ = writeln!(
        out,
        "  {elem_ptr} = getelementptr inbounds {ety}, {ety}* {data_ptr}, i64 {idx0}"
    );
    elem_ptr
}

fn emit_value(
    value: &IrValue,
    fctx: &mut FnCtx,
    expected_ty: &IrType,
    out: &mut String,
) -> (String, IrType) {
    match value {
        IrValue::ConstInt(v) => (v.to_string(), IrType::I64),
        IrValue::ConstFloat(v) => (format_llvm_float(*v), IrType::F64),
        IrValue::ConstBool(v) => (
            (if *v { "true" } else { "false" }).to_string(),
            IrType::Bool,
        ),
        IrValue::ConstStr(s) => {
            let name = fctx
                .ctx
                .string_constants
                .get(s)
                .cloned()
                .unwrap_or_default();
            let len = string_byte_len_with_nul(s);
            let tmp = fresh_ptr_name();
            let _ = writeln!(
                out,
                "  {tmp} = getelementptr inbounds [{len} x i8], [{len} x i8]* {name}, i64 0, i64 0"
            );
            (tmp, IrType::Str)
        }
        IrValue::Param(name) => (format!("%{name}"), expected_ty.clone()),
        IrValue::Local(name) => {
            let ty = fctx
                .locals
                .get(name)
                .cloned()
                .unwrap_or_else(|| expected_ty.clone());
            let lty = llvm_type(&ty);
            let tmp = fresh_reg_name();
            let _ = writeln!(out, "  {tmp} = load {lty}, {lty}* %{name}");
            (tmp, ty)
        }
        IrValue::Temp(t) => (format!("%t{t}"), expected_ty.clone()),
    }
}

fn value_hint_type(value: &IrValue, fctx: &FnCtx) -> IrType {
    match value {
        IrValue::ConstInt(_) => IrType::I64,
        IrValue::ConstFloat(_) => IrType::F64,
        IrValue::ConstBool(_) => IrType::Bool,
        IrValue::ConstStr(_) => IrType::Str,
        IrValue::Param(_) => IrType::I64,
        IrValue::Local(name) => fctx.locals.get(name).cloned().unwrap_or(IrType::I64),
        IrValue::Temp(_) => IrType::I64,
    }
}

fn emit_print(value: &IrValue, ty: &IrType, fctx: &mut FnCtx, out: &mut String) {
    match ty {
        IrType::I64 => {
            let (v, _) = emit_value(value, fctx, &IrType::I64, out);
            let fmt_ptr = fresh_ptr_name();
            let _ = writeln!(
                out,
                "  {fmt_ptr} = getelementptr inbounds [6 x i8], [6 x i8]* @.fmt.int, i64 0, i64 0"
            );
            let _ = writeln!(out, "  call i32 (i8*, ...) @printf(i8* {fmt_ptr}, i64 {v})");
        }
        IrType::F64 => {
            let (v, _) = emit_value(value, fctx, &IrType::F64, out);
            let fmt_ptr = fresh_ptr_name();
            let _ = writeln!(out, "  {fmt_ptr} = getelementptr inbounds [4 x i8], [4 x i8]* @.fmt.float, i64 0, i64 0");
            let _ = writeln!(
                out,
                "  call i32 (i8*, ...) @printf(i8* {fmt_ptr}, double {v})"
            );
        }
        IrType::Bool => {
            let (v, _) = emit_value(value, fctx, &IrType::Bool, out);
            let sel = fresh_ptr_name();
            let _ = writeln!(
                out,
                "  {sel} = select i1 {v}, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.true, i64 0, i64 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.false, i64 0, i64 0)"
            );
            let fmt_ptr = fresh_ptr_name();
            let _ = writeln!(
                out,
                "  {fmt_ptr} = getelementptr inbounds [4 x i8], [4 x i8]* @.fmt.str, i64 0, i64 0"
            );
            let _ = writeln!(
                out,
                "  call i32 (i8*, ...) @printf(i8* {fmt_ptr}, i8* {sel})"
            );
        }
        IrType::Str => {
            let (v, _) = emit_value(value, fctx, &IrType::Str, out);
            let fmt_ptr = fresh_ptr_name();
            let _ = writeln!(
                out,
                "  {fmt_ptr} = getelementptr inbounds [4 x i8], [4 x i8]* @.fmt.str, i64 0, i64 0"
            );
            let _ = writeln!(out, "  call i32 (i8*, ...) @printf(i8* {fmt_ptr}, i8* {v})");
        }
        _ => {}
    }
}

fn emit_binop(
    dest: Temp,
    op: IrBinOp,
    lhs: &IrValue,
    rhs: &IrValue,
    fctx: &mut FnCtx,
    out: &mut String,
) {
    use IrBinOp::*;
    if matches!(op, EqStr | NeStr) {
        let (l, _) = emit_value(lhs, fctx, &IrType::Str, out);
        let (r, _) = emit_value(rhs, fctx, &IrType::Str, out);
        let cmp = fresh_reg_name();
        let _ = writeln!(out, "  {cmp} = call i32 @strcmp(i8* {l}, i8* {r})");
        let mnemonic = if op == EqStr { "eq" } else { "ne" };
        let _ = writeln!(out, "  %t{dest} = icmp {mnemonic} i32 {cmp}, 0");
        return;
    }
    let ty = binop_operand_type(op);
    let (l, _) = emit_value(lhs, fctx, &ty, out);
    let (r, _) = emit_value(rhs, fctx, &ty, out);
    let mnemonic = binop_mnemonic(op);
    let lty = llvm_type(&ty);
    let _ = writeln!(out, "  %t{dest} = {mnemonic} {lty} {l}, {r}");
}

fn binop_operand_type(op: IrBinOp) -> IrType {
    use IrBinOp::*;
    match op {
        AddI | SubI | MulI | DivI | RemI | EqI | NeI | LtI | GtI | LeI | GeI => IrType::I64,
        AddF | SubF | MulF | DivF | EqF | NeF | LtF | GtF | LeF | GeF => IrType::F64,
        EqStr | NeStr => IrType::Str,
    }
}

fn binop_mnemonic(op: IrBinOp) -> &'static str {
    use IrBinOp::*;
    match op {
        AddI => "add",
        SubI => "sub",
        MulI => "mul",
        DivI => "sdiv",
        RemI => "srem",
        EqI => "icmp eq",
        NeI => "icmp ne",
        LtI => "icmp slt",
        GtI => "icmp sgt",
        LeI => "icmp sle",
        GeI => "icmp sge",
        AddF => "fadd",
        SubF => "fsub",
        MulF => "fmul",
        DivF => "fdiv",
        EqF => "fcmp oeq",
        NeF => "fcmp one",
        LtF => "fcmp olt",
        GtF => "fcmp ogt",
        LeF => "fcmp ole",
        GeF => "fcmp oge",
        EqStr | NeStr => unreachable!("handled separately in emit_binop"),
    }
}

fn elem_byte_size(ty: &IrType) -> usize {
    match ty {
        IrType::I64 | IrType::F64 | IrType::Str => 8,
        IrType::Bool => 1,
        _ => 8,
    }
}

fn format_llvm_float(v: f64) -> String {
    if v.fract() == 0.0 && v.is_finite() {
        format!("{v:.1}")
    } else {
        format!("{v}")
    }
}

fn sanitize_label(label: &str) -> String {
    label.replace('.', "_")
}

use std::cell::Cell;
thread_local! {
    static REG_COUNTER: Cell<u32> = Cell::new(0);
}

fn fresh_reg_name() -> String {
    REG_COUNTER.with(|c| {
        let v = c.get();
        c.set(v + 1);
        format!("%r{v}")
    })
}

fn fresh_ptr_name() -> String {
    REG_COUNTER.with(|c| {
        let v = c.get();
        c.set(v + 1);
        format!("%p{v}")
    })
}

fn fresh_block_label(hint: &str) -> String {
    REG_COUNTER.with(|c| {
        let v = c.get();
        c.set(v + 1);
        format!("{hint}.{v}")
    })
}
