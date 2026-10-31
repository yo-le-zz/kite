/**
 * @file Kite grammar for tree-sitter
 * @license MIT
 *
 * Kite (https://github.com/yo-le-zz/Kite) is an indentation-based,
 * ahead-of-time compiled language: readable like Python, fast like C.
 * Blocks are delimited like Python's, so this grammar uses an external
 * scanner (src/scanner.c) to emit NEWLINE/INDENT/DEDENT tokens, mirroring
 * the layout algorithm of the compiler's lexer.
 *
 * Covers Kite 0.3: classes and methods, data enums with `match`/`case`,
 * f-strings, default/named/variadic parameters, tuple unpacking, typed
 * lists and tuples, pointers, compound assignment, bit operators.
 */

const PREC = {
  or: 1,
  and: 2,
  not: 3,
  equality: 4,
  comparison: 5,
  bitwise: 6,
  additive: 7,
  multiplicative: 8,
  unary: 9,
  postfix: 10,
};

module.exports = grammar({
  name: "kite",

  externals: ($) => [$._newline, $._indent, $._dedent],

  extras: (_) => [/[ \t\r]/, { type: "SYMBOL", name: "comment" }],

  word: ($) => $.identifier,

  conflicts: ($) => [],

  rules: {
    source_file: ($) =>
      seq(repeat($._newline), repeat(seq($._top_level_item, repeat($._newline)))),

    _top_level_item: ($) =>
      choice(
        $.use_import,
        $.from_import,
        $.struct_definition,
        $.class_definition,
        $.enum_definition,
        $.function_definition,
      ),

    comment: (_) => token(seq("//", /[^\n]*/)),

    // ---- imports ------------------------------------------------------

    use_import: ($) => seq("use", field("path", $.dotted_path)),
    from_import: ($) =>
      seq("from", field("path", $.dotted_path), "import", commaSep1($.identifier)),
    dotted_path: ($) => sep1($.identifier, "."),

    // ---- struct / class / enum ---------------------------------------------

    struct_definition: ($) =>
      seq("type", field("name", $.identifier), ":", field("body", $.struct_body)),
    struct_body: ($) =>
      seq($._newline, $._indent, repeat($._newline), repeat1(seq($.struct_field, $._newline, repeat($._newline))), $._dedent),
    struct_field: ($) => seq(field("name", $.identifier), ":", field("type", $._type)),

    // class Dog(Animal):   fields, then methods (`make`)
    class_definition: ($) =>
      seq(
        "class",
        field("name", $.identifier),
        optional(seq("(", field("base", $.identifier), ")")),
        ":",
        field("body", $.class_body),
      ),
    class_body: ($) =>
      seq(
        $._newline,
        $._indent,
        repeat($._newline),
        repeat1(choice(seq($.struct_field, $._newline, repeat($._newline)), seq($.function_definition, repeat($._newline)))),
        $._dedent,
      ),

    // enum Shape:   Circle(r: int) / Rect(int, int) / Empty
    enum_definition: ($) =>
      seq("enum", field("name", $.identifier), ":", field("body", $.enum_body)),
    enum_body: ($) =>
      seq($._newline, $._indent, repeat($._newline), repeat1(seq($.enum_variant, $._newline, repeat($._newline))), $._dedent),
    enum_variant: ($) =>
      seq(field("name", $.identifier), optional(field("fields", $.variant_fields))),
    variant_fields: ($) => seq("(", commaSep1($.variant_field), ")"),
    variant_field: ($) =>
      choice(seq(field("name", $.identifier), ":", field("type", $._type)), field("type", $._type)),

    // ---- functions ------------------------------------------------------

    function_definition: ($) =>
      choice(
        // extern make puts(s: string) -> int
        seq(
          "extern",
          optional(field("async", "async")),
          "make",
          field("name", $.identifier),
          field("parameters", $.parameters),
          optional(seq("->", field("return_type", $._type))),
        ),
        seq(
          optional(field("async", "async")),
          "make",
          field("name", $.identifier),
          field("parameters", $.parameters),
          optional(seq("->", field("return_type", $._type))),
          ":",
          field("body", $.block),
        ),
      ),

    parameters: ($) =>
      seq("(", optional($._newline), commaSepNL($, $.parameter), optional($._newline), ")"),
    // `self`, `x: int`, `n: int = 3`, `*rest: int`
    parameter: ($) =>
      seq(
        optional(field("variadic", "*")),
        field("name", $.identifier),
        optional(seq(":", field("type", $._type))),
        optional(seq("=", field("default", $.expression))),
      ),

    _type: ($) => choice($.primitive_type, $.pointer_type, $.list_type, $.tuple_type, $.type_identifier),
    primitive_type: (_) => choice("int", "float", "bool", "string"),
    type_identifier: ($) => alias($.identifier, $.type_identifier),
    // `ptr<T>`
    pointer_type: ($) => seq("ptr", "<", field("pointee", $._type), ">"),
    // `[T]`
    list_type: ($) => seq("[", field("element", $._type), "]"),
    // `(A, B)`
    tuple_type: ($) => seq("(", $._type, repeat1(seq(",", $._type)), optional(","), ")"),

    block: ($) => seq($._newline, $._indent, repeat($._newline), repeat1($._statement), $._dedent),

    // Every statement is followed by its "real" line-ending newline (for
    // simple, single-line statements) or nothing extra (for compound
    // statements, which already end in a nested block's DEDENT) -- and
    // then zero or more additional newlines for blank lines. Requesting
    // `_newline` uniformly lets the external scanner swallow blank lines
    // between any two statements, including right after a nested block.
    _statement: ($) =>
      choice(
        seq($._simple_statement, $._newline, repeat($._newline)),
        seq($._compound_statement, repeat($._newline)),
      ),

    _simple_statement: ($) =>
      choice(
        $.assignment,
        $.unpack_statement,
        $.expression_statement,
        $.return_statement,
        $.break_statement,
        $.continue_statement,
      ),

    _compound_statement: ($) =>
      choice(
        $.if_statement,
        $.until_statement,
        $.while_statement,
        $.infinit_statement,
        $.for_range_statement,
        $.for_each_statement,
        $.try_statement,
        $.thread_statement,
        $.match_statement,
      ),

    // x = 1   x: int = 1   x += 1   obj.f <<= 2   xs[i] = v
    assignment: ($) =>
      seq(
        field("target", $.expression),
        choice(
          seq(optional(seq(":", field("type", $._type))), field("operator", "=")),
          field("operator", $.augmented_operator),
        ),
        field("value", $.expression),
      ),
    augmented_operator: (_) =>
      choice("+=", "-=", "*=", "/=", "%=", "&=", "|=", "^=", "<<=", ">>="),

    // a, b = pair()
    unpack_statement: ($) =>
      seq(
        field("target", $.identifier),
        repeat1(seq(",", field("target", $.identifier))),
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
    while_statement: ($) => seq("while", field("condition", $.expression), ":", field("body", $.block)),
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

    // match shape:
    //     case Circle(r):
    //         ...
    //     else:
    //         ...
    match_statement: ($) =>
      seq(
        "match",
        field("subject", $.expression),
        ":",
        field("body", $.match_body),
      ),
    match_body: ($) =>
      seq($._newline, $._indent, repeat($._newline), repeat1(seq(choice($.case_clause, $.else_clause), repeat($._newline))), $._dedent),
    case_clause: ($) =>
      seq(
        "case",
        field("variant", $.identifier),
        optional(seq("(", optional(commaSep1(field("binding", $.identifier))), ")")),
        ":",
        field("body", $.block),
      ),

    // ---- expressions ------------------------------------------------------

    expression: ($) =>
      choice(
        $.binary_expression,
        $.unary_expression,
        $.await_expression,
        $.call_expression,
        $.method_call_expression,
        $.alloc_expression,
        $.field_access,
        $.index_access,
        $._primary,
      ),

    binary_expression: ($) =>
      choice(
        ...[
          ["or", PREC.or],
          ["and", PREC.and],
          ["==", PREC.equality],
          ["!=", PREC.equality],
          ["<", PREC.comparison],
          [">", PREC.comparison],
          ["<=", PREC.comparison],
          [">=", PREC.comparison],
          ["&", PREC.bitwise],
          ["|", PREC.bitwise],
          ["^", PREC.bitwise],
          ["<<", PREC.bitwise],
          [">>", PREC.bitwise],
          ["+", PREC.additive],
          ["-", PREC.additive],
          ["*", PREC.multiplicative],
          ["/", PREC.multiplicative],
          ["%", PREC.multiplicative],
        ].map(([op, p]) =>
          prec.left(p, seq(field("left", $.expression), field("operator", op), field("right", $.expression))),
        ),
      ),

    unary_expression: ($) =>
      choice(
        // `-x`, `*p` (dereference), `&x` (address-of), `~x` (bitwise not)
        prec(PREC.unary, seq(field("operator", choice("-", "*", "&", "~")), field("operand", $.expression))),
        prec(PREC.not, seq(field("operator", "not"), field("operand", $.expression))),
      ),

    await_expression: ($) => prec(PREC.unary, seq("await", field("value", $.expression))),

    // f(x, n=2)
    call_expression: ($) => prec(PREC.postfix, seq(field("function", $.identifier), $.arguments)),
    // obj.method(x)
    method_call_expression: ($) =>
      prec.left(PREC.postfix, seq(field("object", $.expression), ".", field("method", $.identifier), $.arguments)),
    arguments: ($) =>
      seq("(", optional($._newline), commaSepNL($, choice($.named_argument, $.expression)), optional($._newline), ")"),
    named_argument: ($) => seq(field("name", $.identifier), "=", field("value", $.expression)),

    // alloc(T) / alloc_n(T, n) take a type, not a value.
    alloc_expression: ($) =>
      choice(
        seq(field("function", "alloc"), "(", field("type", $._type), ")"),
        seq(field("function", "alloc_n"), "(", field("type", $._type), ",", field("count", $.expression), ")"),
      ),

    field_access: ($) => prec.left(PREC.postfix, seq(field("object", $.expression), ".", field("field", $.identifier))),
    index_access: ($) => prec.left(PREC.postfix, seq(field("object", $.expression), "[", field("index", $.expression), "]")),

    _primary: ($) =>
      choice(
        $.integer,
        $.float,
        $.string,
        $.format_string,
        $.boolean,
        $.null_literal,
        $.identifier,
        $.list_literal,
        $.tuple_literal,
        $.dict_literal,
        $.parenthesized_expression,
      ),

    null_literal: (_) => "null",

    parenthesized_expression: ($) => seq("(", $.expression, ")"),

    list_literal: ($) => seq("[", optional($._newline), commaSepNL($, $.expression), optional($._newline), "]"),
    tuple_literal: ($) =>
      choice(
        seq("(", ")"),
        seq("(", optional($._newline), $.expression, ",", commaSepNL($, $.expression), optional($._newline), ")"),
      ),
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

    string: ($) =>
      seq('"', repeat(choice(alias(token.immediate(prec(1, /[^"\\\n]+/)), $.string_content), $.escape_sequence)), token.immediate('"')),

    // f"hello {name}, {n + 1} {{braces}}"
    format_string: ($) =>
      seq(
        token(prec(2, 'f"')),
        repeat(
          choice(
            alias(token.immediate(prec(1, /[^"\\{}\n]+/)), $.string_content),
            $.escape_sequence,
            alias(token.immediate("{{"), $.escape_sequence),
            alias(token.immediate("}}"), $.escape_sequence),
            $.interpolation,
          ),
        ),
        token.immediate('"'),
      ),
    interpolation: ($) => seq(token.immediate("{"), field("expression", $.expression), "}"),
    escape_sequence: (_) => token.immediate(/\\./),

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
