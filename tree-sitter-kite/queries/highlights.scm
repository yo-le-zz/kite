; Kite syntax highlighting queries.
;
; Capture names follow the conventions shared across editors built on
; tree-sitter (Zed, Neovim, Helix, ...): @keyword, @function, @type,
; @string, @number, @comment, etc. Each editor's theme maps these names
; to actual colors, so this file intentionally does not hard-code any.
;
; Patterns are ordered general -> specific: when two patterns capture
; the same node, the *later* one wins, so broad catch-alls (like the
; generic `(identifier) @variable` below) come first and specific
; overrides (function names, type names, enum variants, ...) come after.

; ---- generic identifier fallback ----------------------------------------

(identifier) @variable

; ---- literals -----------------------------------------------------------

(integer) @number
(float) @number
(boolean) @constant.builtin.boolean
(string) @string
(comment) @comment

; ---- keywords -----------------------------------------------------------

[
  "make"
  "return"
  "if"
  "orif"
  "else"
  "until"
  "infinit"
  "for"
  "to"
  "in"
  "try"
  "failed"
  "finally"
  "thread"
  "async"
  "await"
  "type"
  "enum"
  "use"
  "from"
  "import"
] @keyword

(break_statement) @keyword
(continue_statement) @keyword
["and" "or" "not"] @keyword.operator

; ---- operators & punctuation ----------------------------------------------

[
  "+"
  "-"
  "*"
  "/"
  "%"
  "=="
  "!="
  "<"
  ">"
  "<="
  ">="
  "="
  "->"
] @operator

["." ":" ","] @punctuation.delimiter
["(" ")" "[" "]" "{" "}"] @punctuation.bracket

; ---- types ----------------------------------------------------------------

(primitive_type) @type.builtin
(struct_definition name: (identifier) @type)
(enum_definition name: (identifier) @type)
(parameter type: (identifier) @type)
(struct_field type: (identifier) @type)
(function_definition return_type: (identifier) @type)

; ---- fields / properties / constants ---------------------------------------

(struct_field name: (identifier) @property)
(enum_variant (identifier) @constant)
(field_access field: (identifier) @property)
(dict_entry key: (string) @property)

; `Color.Red` -- capital-letter field access on a bare identifier reads
; as an enum variant reference far more often than a struct field.
(field_access
  object: (expression (identifier) @type)
  field: (identifier) @constant
  (#match? @type "^[A-Z]"))

; ---- functions --------------------------------------------------------------

(function_definition name: (identifier) @function)
(call_expression function: (identifier) @function.call)

; Builtins that exist without a `make` definition anywhere.
((identifier) @function.builtin
  (#match? @function.builtin "^(print|append|len)$"))

; ---- parameters / loop variables -------------------------------------------

(parameter name: (identifier) @variable.parameter)
(for_range_statement variable: (identifier) @variable.parameter)
(for_each_statement variable: (identifier) @variable.parameter)

; ---- imports ----------------------------------------------------------------

(use_import path: (dotted_path (identifier) @module))
(from_import path: (dotted_path (identifier) @module))
