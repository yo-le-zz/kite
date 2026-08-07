# tree-sitter-kite

A [tree-sitter](https://tree-sitter.github.io/tree-sitter/) grammar for
the [Kite programming language](https://github.com/yo-le-zz/kite).

Kite uses Python-style significant indentation, so this grammar ships an
external scanner (`src/scanner.c`) that emits `NEWLINE`/`INDENT`/`DEDENT`
tokens by tracking an indentation stack -- mirroring the layout algorithm
in the Kite compiler's own lexer (`src/lexer/mod.rs` in the main `kite`
repository).

Verified to parse every example in the main repo's `examples/` directory,
plus a comprehensive sample covering every language construct (structs,
enums, imports, all control flow, `try`/`failed`/`finally`,
`thread`/`async`/`await`, multi-line lists/tuples/dicts), with zero
`ERROR`/`MISSING` nodes.

## Building

```bash
npm install
npx tree-sitter generate
npx tree-sitter build
```

## Testing against a file

```bash
npx tree-sitter parse path/to/file.ki
```
Any `(ERROR ...)` or `(MISSING ...)` node in the output means the parser
couldn't make sense of that part of the file.

## Using it

- **Zed**: see `../editors/zed/` in the main `kite` repository for a
  ready-to-publish extension that references this grammar.
- **Neovim** (`nvim-treesitter`), **Helix**, or anything else that takes
  a tree-sitter grammar + `queries/highlights.scm`: point it at this
  repository the way you would any third-party grammar; consult that
  tool's own docs for exactly how it expects grammars to be registered.

## License

MIT -- see `LICENSE`.
