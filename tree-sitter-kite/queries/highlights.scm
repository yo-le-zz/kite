; Syntax highlighting for Kite 0.3 (works in tree-sitter, Zed, Neovim, Helix).

; ---- comments ---------------------------------------------------------------
(comment) @comment

; ---- keywords ---------------------------------------------------------------
[
  "make"
  "extern"
  "async"
  "type"
  "class"
  "enum"
  "use"
  "from"
  "import"
] @keyword

[
  "return"
  "if"
  "orif"
  "else"
  "until"
  "while"
  "infinit"
  "for"
  "to"
  "in"
  "try"
  "failed"
  "finally"
  "thread"
  "match"
  "case"
  "await"
] @keyword

[
  "and"
  "or"
  "not"
] @keyword

(break_statement) @keyword
(continue_statement) @keyword

; ---- literals -----------------------------------------------------------------
(integer) @number
(float) @number
(boolean) @boolean
(null_literal) @constant

(string) @string
(format_string) @string
(string_content) @string
(escape_sequence) @string.escape
(interpolation
  "}" @punctuation.special)
(interpolation
  (_) @embedded)

; ---- types --------------------------------------------------------------------
(primitive_type) @type
(type_identifier) @type
(pointer_type "ptr" @type)
(struct_definition name: (identifier) @type)
(class_definition name: (identifier) @type)
(class_definition base: (identifier) @type)
(enum_definition name: (identifier) @type)

; ---- enum variants --------------------------------------------------------------
(enum_variant name: (identifier) @variant)
(case_clause variant: (identifier) @variant)

; ---- functions ------------------------------------------------------------------
(function_definition name: (identifier) @function)
(call_expression function: (identifier) @function)
(method_call_expression method: (identifier) @function)

; Constructors: calling a capitalised name (`Counter()`, `Shape.Circle(2)`).
(call_expression
  function: (identifier) @constructor
  (#match? @constructor "^[A-Z]"))
(method_call_expression
  method: (identifier) @constructor
  (#match? @constructor "^[A-Z]"))

; Built-in functions.
(call_expression
  function: (identifier) @function
  (#any-of? @function
    "print" "len" "str" "append" "pop" "remove" "insert" "clear" "exit"
    "char_at" "substr" "read_file" "write_file" "arg" "arg_count" "free"))

(alloc_expression function: _ @function)

; ---- variables and fields ---------------------------------------------------------
(parameter name: (identifier) @variable)
(named_argument name: (identifier) @variable)
(field_access field: (identifier) @property)
(struct_field name: (identifier) @property)
(variant_field name: (identifier) @property)

((identifier) @variable.special
  (#eq? @variable.special "self"))

; Capitalised bare identifiers are types/enums (`Shape.Circle`, `Color.Red`).
((identifier) @type
  (#match? @type "^[A-Z]"))

; ---- operators and punctuation ---------------------------------------------------
[
  "+" "-" "*" "/" "%"
  "==" "!=" "<" ">" "<=" ">="
  "=" "&" "|" "^" "~" "<<" ">>"
  "->"
] @operator
(augmented_operator) @operator

[ "(" ")" "[" "]" "{" "}" ] @punctuation.bracket
[ "," ":" "." ] @punctuation.delimiter
