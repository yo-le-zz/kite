(function_definition name: (identifier) @name) @definition.function
(struct_definition name: (identifier) @name) @definition.class
(class_definition name: (identifier) @name) @definition.class
(enum_definition name: (identifier) @name) @definition.type
(call_expression function: (identifier) @name) @reference.call
(method_call_expression method: (identifier) @name) @reference.call
