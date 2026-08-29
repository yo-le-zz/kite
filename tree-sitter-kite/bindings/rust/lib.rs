//! This crate provides Kite language support for the [tree-sitter]
//! parsing library.
//!
//! [tree-sitter]: https://tree-sitter.github.io/

use tree_sitter_language::LanguageFn;

extern "C" {
    fn tree_sitter_kite() -> *const ();
}

/// The tree-sitter [`LanguageFn`] for this grammar, for use with
/// `tree_sitter::Parser::set_language`.
pub const LANGUAGE: LanguageFn = unsafe { LanguageFn::from_raw(tree_sitter_kite) };

/// The syntax highlighting queries for this grammar.
pub const HIGHLIGHTS_QUERY: &str = include_str!("../../queries/highlights.scm");

/// The content of the grammar's [`node-types.json`] file.
///
/// [`node-types.json`]: https://tree-sitter.github.io/tree-sitter/using-parsers#static-node-types
pub const NODE_TYPES: &str = include_str!("../../src/node-types.json");

#[cfg(test)]
mod tests {
    #[test]
    fn can_load_grammar() {
        let mut parser = tree_sitter::Parser::new();
        parser
            .set_language(&super::LANGUAGE.into())
            .expect("error loading Kite grammar");
    }

    #[test]
    fn parses_hello_world_without_errors() {
        let mut parser = tree_sitter::Parser::new();
        parser.set_language(&super::LANGUAGE.into()).unwrap();
        let source = "make main():\n    print(\"Hello, Kite!\")\n";
        let tree = parser.parse(source, None).unwrap();
        assert!(!tree.root_node().has_error());
    }
}
