/**
 * @file Kite grammar for tree-sitter
 * @license MIT
 *
 * Kite (https://github.com/yo-le-zz/kite) is an indentation-based,
 * ahead-of-time compiled language. Blocks are delimited the same way
 * Python's are, so this grammar uses an external scanner
 * (src/scanner.c) to emit NEWLINE/INDENT/DEDENT tokens -- see that file
 * for the layout algorithm, which mirrors the Rust compiler's own
 * lexer (src/lexer/mod.rs in the main kite repository).
 */

module.exports = grammar({
  name: "kite",

  externals: ($) => [$._newline, $._indent, $._dedent],

  extras: ($) => [/[ \t\r]/, $.comment],

  word: ($) => $.identifier,

  conflicts: ($) => [],

  rules: {
    source_file: ($) =>
      seq(repeat($._newline), repeat(seq($._top_level_item, repeat($._newline)))),

    _top_level_item: ($) =>
      choice($.use_import, $.from_import, $.struct_definition, $.enum_definition, $.function_definition),

    comment: (_) => token(seq("//", /[^\n]*/)),

    // ---- imports ------------------------------------------------------

    use_import: ($) => seq("use", field("path", $.dotted_path)),
    from_import: ($) =>
      seq("from", field("path", $.dotted_path), "import", commaSep1($.identifier)),
    dotted_path: ($) => sep1($.identifier, "."),

    // ---- struct / enum --------------------------------------------------

    struct_definition: ($) =>
      seq("type", field("name", $.identifier), ":", field("body", $.struct_body)),
    struct_body: ($) => seq($._newline, $._indent, repeat1(seq($.struct_field, $._newline)), $._dedent),
    struct_field: ($) => seq(field("name", $.identifier), ":", field("type", $._type)),

    enum_definition: ($) => seq("enum", field("name", $.identifier), ":", field("body", $.enum_body)),
    enum_body: ($) => seq($._newline, $._indent, repeat1(seq($.enum_variant, $._newline)), $._dedent),
    enum_variant: ($) => field("name", $.identifier),

    // ---- functions ------------------------------------------------------

    function_definition: ($) =>
      seq(
        optional(field("async", "async")),
        "make",
        field("name", $.identifier),
        field("parameters", $.parameters),
        optional(seq("->", field("return_type", $._type))),
        ":",
        field("body", $.block),
      ),

    parameters: ($) => seq("(", optional($._newline), commaSepNL($, $.parameter), optional($._newline), ")"),
    parameter: ($) => seq(field("name", $.identifier), ":", field("type", $._type)),

    _type: ($) => choice($.primitive_type, $.identifier),
    primitive_type: (_) => choice("int", "float", "bool", "string"),

    block: ($) => seq($._newline, $._indent, repeat1($._statement), $._dedent),

    // Every statement is followed by its "real" line-ending newline (for
    // simple, single-line statements) or nothing extra (for compound
    // statements, which already end in a nested block's DEDENT) -- and
    // then, either way, zero or more *additional* newlines representing
    // blank lines before the next statement. Requesting `_newline`
    // uniformly here (rather than only inside each simple statement) is
    // what lets the external scanner (src/scanner.c) swallow blank
    // lines between any two statements, including right after a nested
    // block.
    _statement: ($) =>
      choice(
        seq($._simple_statement, $._newline, repeat($._newline)),
        seq($._compound_statement, repeat($._newline)),
      ),

    _simple_statement: ($) =>
      choice(
        $.assignment,
        $.expression_statement,
        $.return_statement,
        $.break_statement,
        $.continue_statement,
      ),

    _compound_statement: ($) =>
      choice(
        $.if_statement,
        $.until_statement,
        $.infinit_statement,
        $.for_range_statement,
        $.for_each_statement,
        $.try_statement,
        $.thread_statement,
      ),

    assignment: ($) =>
      seq(
        field("target", $.expression),
        optional(seq(":", field("type", $._type))),
        "=",
        field("value", $.expression),
      ),

    expression_statement: ($) => $.expression,

    return_statement: ($) => seq("return", optional(field("value", $.expression))),
    break_statement: (_) => "break",
    continue_statement: (_) => "continue",

    if_statement: ($) =>
      seq(
        "if",
        field("condition", $.expression),
        ":",
        field("consequence", $.block),
        repeat($.orif_clause),
        optional($.else_clause),
      ),
    orif_clause: ($) => seq("orif", field("condition", $.expression), ":", field("body", $.block)),
    else_clause: ($) => seq("else", ":", field("body", $.block)),

    until_statement: ($) => seq("until", field("condition", $.expression), ":", field("body", $.block)),
    infinit_statement: ($) => seq("infinit", ":", field("body", $.block)),

    for_range_statement: ($) =>
      seq(
        "for",
        field("variable", $.identifier),
        "=",
        field("start", $.expression),
        "to",
        field("end", $.expression),
        ":",
        field("body", $.block),
      ),
    for_each_statement: ($) =>
      seq(
        "for",
        field("variable", $.identifier),
        "in",
        field("iterable", $.expression),
        ":",
        field("body", $.block),
      ),

    try_statement: ($) =>
      seq(
        "try",
        ":",
        field("body", $.block),
        optional(seq("failed", optional(field("error", $.identifier)), ":", field("failed_body", $.block))),
        optional(seq("finally", ":", field("finally_body", $.block))),
      ),

    thread_statement: ($) => seq("thread", ":", field("body", $.block)),

    // ---- expressions ------------------------------------------------------

    expression: ($) =>
      choice(
        $.binary_expression,
        $.unary_expression,
        $.await_expression,
        $.call_expression,
        $.field_access,
        $.index_access,
        $._primary,
      ),

    binary_expression: ($) =>
      choice(
        ...[
          ["or", 1],
          ["and", 2],
          ["==", 4],
          ["!=", 4],
          ["<", 5],
          [">", 5],
          ["<=", 5],
          [">=", 5],
          ["+", 6],
          ["-", 6],
          ["*", 7],
          ["/", 7],
          ["%", 7],
        ].map(([op, p]) =>
          prec.left(p, seq(field("left", $.expression), field("operator", op), field("right", $.expression))),
        ),
      ),

    unary_expression: ($) =>
      choice(
        prec(8, seq(field("operator", "-"), field("operand", $.expression))),
        prec(3, seq(field("operator", "not"), field("operand", $.expression))),
      ),

    await_expression: ($) => prec(8, seq("await", field("value", $.expression))),

    call_expression: ($) =>
      prec(9, seq(field("function", $.identifier), "(", optional($._newline), commaSepNL($, $.expression), optional($._newline), ")")),

    field_access: ($) => prec.left(9, seq(field("object", $.expression), ".", field("field", $.identifier))),
    index_access: ($) => prec.left(9, seq(field("object", $.expression), "[", field("index", $.expression), "]")),

    _primary: ($) =>
      choice(
        $.integer,
        $.float,
        $.string,
        $.boolean,
        $.identifier,
        $.list_literal,
        $.tuple_literal,
        $.dict_literal,
        $.parenthesized_expression,
      ),

    parenthesized_expression: ($) => seq("(", $.expression, ")"),

    list_literal: ($) => seq("[", optional($._newline), commaSepNL($, $.expression), optional($._newline), "]"),
    tuple_literal: ($) =>
      seq("(", optional($._newline), $.expression, ",", commaSepNL($, $.expression), optional($._newline), ")"),
    dict_literal: ($) =>
      seq(
        "{",
        optional($._newline),
        optional(
          seq(
            $.dict_entry,
            repeat(seq(",", optional($._newline), $.dict_entry)),
            optional(","),
            optional($._newline),
          ),
        ),
        "}",
      ),
    dict_entry: ($) => seq(field("key", $.string), ":", field("value", $.expression)),

    integer: (_) => /[0-9]+/,
    float: (_) => /[0-9]+\.[0-9]+/,
    boolean: (_) => choice("true", "false"),
    string: (_) => token(seq('"', repeat(choice(/[^"\\\n]/, /\\./)), '"')),

    identifier: (_) => /[A-Za-z_][A-Za-z0-9_]*/,
  },
});

function commaSep1(rule) {
  return seq(rule, repeat(seq(",", rule)));
}

// Like commaSep, but tolerates a newline after each comma -- for lists,
// call arguments, etc. formatted across multiple lines, matching the
// compiler's real lexer (which suppresses newline significance inside
// any bracket).
function commaSepNL($, rule) {
  return optional(seq(rule, repeat(seq(",", optional($._newline), rule)), optional(",")));
}

function sep1(rule, separator) {
  return seq(rule, repeat(seq(separator, rule)));
}
