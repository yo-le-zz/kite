#include "tree_sitter/parser.h"
#include <string.h>
#include <stdlib.h>

// Mirrors the layout algorithm in the Kite compiler's own lexer
// (src/lexer/mod.rs): track an indentation stack; emit INDENT when a
// logical line's leading-space count exceeds the top of the stack, one
// or more DEDENTs when it's less, and a NEWLINE to end a logical line.
//
// The grammar (grammar.js) requests an *additional* NEWLINE after every
// statement via `repeat($._newline)`, giving the scanner a chance to
// swallow any run of blank lines one at a time (one NEWLINE token per
// blank line) before the parser ever needs to decide between another
// statement and a DEDENT -- so by the time INDENT/DEDENT is actually
// requested, we're always sitting at the first character of real
// content and can just measure its column directly.

enum TokenType {
  NEWLINE,
  INDENT,
  DEDENT,
};

typedef struct {
  uint32_t len;
  uint32_t cap;
  uint16_t *stack;
} Indents;

static void indents_push(Indents *i, uint16_t v) {
  if (i->len == i->cap) {
    i->cap = i->cap == 0 ? 8 : i->cap * 2;
    i->stack = realloc(i->stack, i->cap * sizeof(uint16_t));
  }
  i->stack[i->len++] = v;
}

void *tree_sitter_kite_external_scanner_create() {
  Indents *i = calloc(1, sizeof(Indents));
  indents_push(i, 0);
  return i;
}

void tree_sitter_kite_external_scanner_destroy(void *payload) {
  Indents *i = (Indents *)payload;
  free(i->stack);
  free(i);
}

unsigned tree_sitter_kite_external_scanner_serialize(void *payload, char *buffer) {
  Indents *i = (Indents *)payload;
  uint32_t n = i->len;
  uint32_t max_n = (TREE_SITTER_SERIALIZATION_BUFFER_SIZE - sizeof(uint32_t)) / sizeof(uint16_t);
  if (n > max_n) {
    n = max_n;
  }
  memcpy(buffer, &n, sizeof(uint32_t));
  memcpy(buffer + sizeof(uint32_t), i->stack, n * sizeof(uint16_t));
  return sizeof(uint32_t) + n * sizeof(uint16_t);
}

void tree_sitter_kite_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {
  Indents *i = (Indents *)payload;
  i->len = 0;
  if (length < sizeof(uint32_t)) {
    indents_push(i, 0);
    return;
  }
  uint32_t n;
  memcpy(&n, buffer, sizeof(uint32_t));
  for (uint32_t k = 0; k < n; k++) {
    uint16_t v;
    memcpy(&v, buffer + sizeof(uint32_t) + k * sizeof(uint16_t), sizeof(uint16_t));
    indents_push(i, v);
  }
  if (i->len == 0) {
    indents_push(i, 0);
  }
}

bool tree_sitter_kite_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols) {
  Indents *ind = (Indents *)payload;

  bool want_newline = valid_symbols[NEWLINE];
  bool want_indent = valid_symbols[INDENT];
  bool want_dedent = valid_symbols[DEDENT];
  if (!want_newline && !want_indent && !want_dedent) {
    return false;
  }

  // A NEWLINE ends the current physical line: possibly some trailing
  // horizontal whitespace, then `\n` (or `\r\n`). Comments are handled
  // by the grammar's `extras`, so any `// ...` on this line has already
  // been consumed by the time we're called.
  if (want_newline) {
    while (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
      lexer->advance(lexer, true);
    }
    if (lexer->lookahead == '\r') {
      lexer->advance(lexer, true);
    }
    if (lexer->lookahead == '\n') {
      lexer->advance(lexer, true);
      lexer->mark_end(lexer);
      lexer->result_symbol = NEWLINE;
      return true;
    }
  }

  if (!want_indent && !want_dedent) {
    return false;
  }

  // Skip the leading indentation whitespace of this line so
  // `get_column` reports where its real content starts (blank lines
  // themselves were already handled above via NEWLINE, so anything
  // left here is a genuine, non-blank line to measure).
  while (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
    lexer->advance(lexer, false);
  }

  if (lexer->lookahead == 0) {
    if (want_dedent && ind->len > 1) {
      ind->len--;
      lexer->mark_end(lexer);
      lexer->result_symbol = DEDENT;
      return true;
    }
    return false;
  }

  uint32_t col = lexer->get_column(lexer);
  uint32_t current = ind->stack[ind->len - 1];

  if (col > current && want_indent) {
    indents_push(ind, (uint16_t)col);
    lexer->mark_end(lexer);
    lexer->result_symbol = INDENT;
    return true;
  }
  if (col < current && want_dedent) {
    ind->len--;
    lexer->mark_end(lexer);
    lexer->result_symbol = DEDENT;
    return true;
  }

  return false;
}
