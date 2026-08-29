# Kite for Zed

Syntax highlighting and basic language configuration for
[Kite](https://github.com/yo-le-zz/kite) in [Zed](https://zed.dev).

Not yet published to Zed's extension registry -- see
[`../../docs/zed-extension-publishing.md`](../../docs/zed-extension-publishing.md)
for the full step-by-step (it needs to become its own GitHub repository
first, same as the grammar it depends on, `../../tree-sitter-kite/`).

## Try it locally right now

**One-time prerequisite:** Zed builds the grammar by cloning the git
repository + commit named in `extension.toml`'s `[grammars.kite]`
section, not from a local path -- so `../../tree-sitter-kite/` needs to
already be pushed to a real public repository with `rev` pointing at an
actual commit before "install dev extension" (step 3 below) can
succeed. `rev` currently holds the literal placeholder
`REPLACE_WITH_TREE_SITTER_KITE_COMMIT_SHA`, which is not a real commit,
so **on a fresh checkout, "install dev extension" will fail** with a
grammar-build error until you do this once:

```bash
cd ../../tree-sitter-kite
git init && git add -A && git commit -m "Initial tree-sitter grammar for Kite"
git branch -M main
git remote add origin https://github.com/<you>/tree-sitter-kite.git
git push -u origin main
git rev-parse HEAD   # <- paste this into extension.toml's `rev` field
```

The grammar itself is already verified working (`tree-sitter generate`
+ `tree-sitter build` succeed, and every file in `../../examples/`
parses with zero `ERROR`/`MISSING` nodes) -- the placeholder `rev` is
the only remaining step, and it's a one-time publish, not a code fix.
See [`../../docs/zed-extension-publishing.md`](../../docs/zed-extension-publishing.md)
for the full walkthrough (including publishing this `editors/zed`
directory itself, which the same "no local path" rule also applies to).

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
