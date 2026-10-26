//! The Kite prelude: library code written in Kite itself and merged into a
//! program on demand (only what the program references is compiled in).
//!
//! * `core.ki`  -- string helpers (`split`, `join`, `find`, `trim`, ...)
//! * `map.tpl`  -- `StrMap_<T>`: a string-keyed hash map, instantiated for
//!   any value type `T` that the program mentions (`int`, `string`,
//!   `float`, `bool`, or one of its own structs).

use crate::ast::*;
use crate::lexer::lex;
use crate::parser::parse;
use std::collections::HashSet;

const CORE: &str = include_str!("../../../stdlib/prelude/core.ki");
const MAP_TPL: &str = include_str!("../../../stdlib/prelude/map.tpl");

fn parse_src(src: &str) -> Option<Program> {
    let (tokens, d) = lex(src);
    if d.had_errors() {
        return None;
    }
    let (p, d2) = parse(tokens);
    if d2.had_errors() {
        return None;
    }
    p
}

/// Every `StrMap_<T>` mentioned in `text` (a debug dump of the program).
fn map_instances(text: &str) -> Vec<String> {
    let mut found = Vec::new();
    let mut rest = text;
    while let Some(i) = rest.find("StrMap_") {
        let tail = &rest[i + 7..];
        let end = tail
            .find(|c: char| !(c.is_alphanumeric() || c == '_'))
            .unwrap_or(tail.len());
        // Strip a trailing `__method` part (class method names).
        let mut ty = &tail[..end];
        if let Some(k) = ty.find("__") {
            ty = &ty[..k];
        }
        if !ty.is_empty() {
            let name = format!("StrMap_{ty}");
            if !found.contains(&name) {
                found.push(name);
            }
        }
        rest = &tail[end..];
    }
    found
}

fn map_source(inst: &str) -> String {
    let ty = &inst["StrMap_".len()..];
    let zero = match ty {
        "int" => "0".to_string(),
        "string" => "\"\"".to_string(),
        "float" => "0.0".to_string(),
        "bool" => "false".to_string(),
        other => format!("{other}()"),
    };
    MAP_TPL
        .replace("@N@", inst)
        .replace("@V@", ty)
        .replace("@Z@", &zero)
}

/// Adds the prelude items `program` references (directly or through other
/// prelude items). User definitions with the same name always win.
pub fn inject(program: &mut Program) {
    let Some(core) = parse_src(CORE) else { return };
    let mut pool: Vec<Function> = core.functions;
    let mut pool_structs: Vec<StructDef> = Vec::new();

    let mut text = format!("{:?}", program);
    for inst in map_instances(&text) {
        if let Some(p) = parse_src(&map_source(&inst)) {
            pool.extend(p.functions);
            pool_structs.extend(p.structs);
        }
    }

    let user_fns: HashSet<String> = program.functions.iter().map(|f| f.name.clone()).collect();
    let user_structs: HashSet<String> = program.structs.iter().map(|s| s.name.clone()).collect();
    let mut taken_fn: HashSet<String> = HashSet::new();
    let mut taken_struct: HashSet<String> = HashSet::new();

    loop {
        let mut changed = false;
        for f in &pool {
            if taken_fn.contains(&f.name) || user_fns.contains(&f.name) {
                continue;
            }
            let needle = match f.name.split_once("__") {
                // class method: pulled in together with its class
                Some((c, _)) => format!("\"{c}\""),
                None => format!("\"{}\"", f.name),
            };
            if text.contains(&needle) {
                program.functions.push(f.clone());
                text.push_str(&format!("{:?}", f));
                taken_fn.insert(f.name.clone());
                changed = true;
            }
        }
        for s in &pool_structs {
            if taken_struct.contains(&s.name) || user_structs.contains(&s.name) {
                continue;
            }
            if text.contains(&format!("\"{}\"", s.name)) {
                program.structs.push(s.clone());
                text.push_str(&format!("{:?}", s));
                taken_struct.insert(s.name.clone());
                changed = true;
            }
        }
        if !changed {
            break;
        }
    }
}
