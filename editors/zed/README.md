# Kite for Zed

Syntax highlighting and basic language configuration for
[Kite](https://github.com/yo-le-zz/kite) in [Zed](https://zed.dev).

Not yet published to Zed's extension registry -- see
[`../../docs/zed-extension-publishing.md`](../../docs/zed-extension-publishing.md)
for the full step-by-step (it needs to become its own GitHub repository
first, same as the grammar it depends on, `../../tree-sitter-kite/`).

## Try it locally right now

**One-time setup:** run `./dev-setup.sh` from this directory. It makes
`../../tree-sitter-kite` a local git repo (if it isn't one already) and
points `extension.toml`'s `[grammars.kite]` at it via a `file://` URL --
Zed supports loading a grammar straight from a local git repo this way
(see the "Grammar" section of
[Zed's own extension docs](https://zed.dev/docs/extensions/languages)),
so **you don't need to push anything to GitHub** just to try the
extension out yourself:

```bash
./dev-setup.sh
```

Re-run it any time you change the grammar (`grammar.js`/`scanner.c`) so
Zed picks up the new commit. Publishing for real -- so *other* people
can install this extension, not just you -- still needs a public
GitHub repo; see
[`../../docs/zed-extension-publishing.md`](../../docs/zed-extension-publishing.md)
for that (it needs to become its own GitHub repository first, same as
`editors/zed` itself).

1. Run `./dev-setup.sh` (above).
2. Open Zed.
3. `Cmd`/`Ctrl`-`Shift`-`P` -> **"zed: install dev extension"**.
4. Select this directory (`editors/zed`).
5. Open a `.ki` file.

### If it still fails to compile the grammar

Two things in this repo used to cause exactly that, both fixed now,
worth knowing about if you're troubleshooting a fork or a stale
checkout:

- **A stale `grammars/kite/` directory committed alongside this
  extension.** Zed creates and manages that directory itself the first
  time it clones the grammar -- if one already exists on disk (even
  empty) and *isn't* an actual git clone of the repository named in
  `extension.toml`, Zed refuses to touch it and fails with an error
  like `grammar directory '.../grammars/kite' already exists, but is
  not a git clone of '<repository>'` (this is a
  [known Zed behavior](https://github.com/zed-industries/zed/issues/10569),
  not a bug in this repo's grammar). This repo now `.gitignore`s
  `grammars/` here so it can't happen again -- but if you're seeing
  this error, delete any `editors/zed/grammars/` directory you have
  locally and try again.
- **The placeholder `rev`.** Before `dev-setup.sh` existed, this file
  shipped with `rev = "REPLACE_WITH_TREE_SITTER_KITE_COMMIT_SHA"` --
  not a real commit, so Zed had nothing to check out. `dev-setup.sh`
  replaces it with a real local commit automatically now.

The grammar itself is verified working independently of Zed
(`tree-sitter generate` + `tree-sitter build` succeed, and every file
in `../../examples/` parses with zero `ERROR`/`MISSING` nodes) -- so a
grammar-compile failure at this point is almost always one of the two
things above, not the grammar's own C source.

## What's here

- `extension.toml` -- the extension manifest (points Zed at the
  `tree-sitter-kite` grammar).
- `languages/kite/config.toml` -- file association (`.ki`), comment
  syntax, bracket pairs, indent-after-`:` behavior.
- `languages/kite/highlights.scm` -- syntax highlighting queries
  (keywords, types, strings, function names, ...).
- `icons/kite.png` -- the Kite logo (the actual one from `../../website/`, not an invented placeholder).

No language server yet, so no auto-completion/inline errors/go-to
-definition yet.
