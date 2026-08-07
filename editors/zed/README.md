# Kite for Zed

Syntax highlighting and basic language configuration for
[Kite](https://github.com/yo-le-zz/kite) in [Zed](https://zed.dev).

Not yet published to Zed's extension registry -- see
[`../../docs/zed-extension-publishing.md`](../../docs/zed-extension-publishing.md)
for the full step-by-step (it needs to become its own GitHub repository
first, same as the grammar it depends on, `../../tree-sitter-kite/`).

## Try it locally right now

1. Open Zed.
2. `Cmd`/`Ctrl`-`Shift`-`P` -> **"zed: install dev extension"**.
3. Select this directory (`editors/zed`).
4. Open a `.ki` file.

## What's here

- `extension.toml` -- the extension manifest (points Zed at the
  `tree-sitter-kite` grammar).
- `languages/kite/config.toml` -- file association (`.ki`), comment
  syntax, bracket pairs, indent-after-`:` behavior.
- `languages/kite/highlights.scm` -- syntax highlighting queries
  (keywords, types, strings, function names, ...).
- `icons/kite.svg` -- the Kite logo.

No language server yet, so no auto-completion/inline errors/go-to
-definition -- see the main repository's `docs/roadmap.md`.
