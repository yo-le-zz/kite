# Publishing Kite editor support (Zed)

This repository ships two pieces that together give Kite real syntax
highlighting in [Zed](https://zed.dev):

1. **`tree-sitter-kite/`** -- the grammar itself (tested: parses every
   file in `examples/` and a full-language sample with zero `ERROR`
   nodes -- see `tree-sitter-kite/README.md`).
2. **`editors/zed/`** -- the Zed extension manifest, language config,
   highlight queries, and icon that reference that grammar.

Both need to become **their own public GitHub repositories** before Zed
can use them -- Zed extensions declare their grammar as a `repository` +
`rev` (a commit SHA) in `extension.toml`, and the Zed extension registry
itself is a directory of Git submodules, so "publish" concretely means
"push to GitHub, then open a PR."

## Step 1 -- publish `tree-sitter-kite`

```bash
cd tree-sitter-kite
git init
git add -A
git commit -m "Initial tree-sitter grammar for Kite"
git branch -M main
git remote add origin https://github.com/yo-le-zz/tree-sitter-kite.git
git push -u origin main
```

Create the repo on GitHub first (`github.com/new`, name it
`tree-sitter-kite`, public, no README/license -- this directory already
has both) if you haven't.

Then grab the commit SHA Zed should pin to:

```bash
git rev-parse HEAD
```

## Step 2 -- point the Zed extension at it

Edit `editors/zed/extension.toml` and replace the placeholder:

```toml
[grammars.kite]
repository = "https://github.com/yo-le-zz/tree-sitter-kite"
rev = "PASTE_THE_COMMIT_SHA_FROM_STEP_1_HERE"
```

A commit SHA, not a branch name -- Zed needs a fixed point to build
against, and re-running `git rev-parse HEAD` after every grammar change
you want Zed to pick up is expected (bump it, commit, push).

## Step 3 -- publish the extension itself

`editors/zed/` needs to be its own repository too:

```bash
cd editors/zed
git init
git add -A
git commit -m "Initial Zed extension for Kite"
git branch -M main
git remote add origin https://github.com/yo-le-zz/zed-kite.git
git push -u origin main
```

## Step 4 -- test it locally before submitting

Zed can load an extension straight from a local directory without
publishing anything first:

1. Open Zed.
2. Command palette (`Cmd`/`Ctrl`-`Shift`-`P`) -> **"zed: install dev
   extension"**.
3. Select the `editors/zed` directory.
4. Open a `.ki` file and confirm keywords, strings, numbers, and
   comments are colored (colors themselves come from whatever theme
   you're using -- `highlights.scm` only assigns capture *names*, see
   `docs/architecture.md`-style comments at the top of that file).

If Zed reports a grammar build failure, it's almost always the `rev` in
`extension.toml` not matching what's actually pushed to
`tree-sitter-kite` -- re-check step 2.

## Step 5 -- submit to the Zed extension registry

The registry is [`zed-industries/extensions`](https://github.com/zed-industries/extensions)
on GitHub -- a directory of Git submodules plus an `extensions.toml`
index. To publish for real:

1. Fork `zed-industries/extensions`.
2. Add `editors/zed`'s repository as a submodule under `extensions/kite`:
   ```bash
   git submodule add https://github.com/yo-le-zz/zed-kite extensions/kite
   ```
3. Add an entry for it in `extensions.toml` at the repository root
   (alphabetical order; copy the shape of a neighboring entry -- the
   registry's own `CONTRIBUTING.md` documents the exact fields expected,
   since that file's schema is the registry's, not Kite's, and can
   change independently of this guide).
4. Commit, push to your fork, open a pull request against
   `zed-industries/extensions`.
5. Wait for review. The Zed team runs their own build/lint checks on
   submitted extensions; address anything they flag on the PR.

Once merged, `Kite` shows up in Zed's in-app extension browser
(`Cmd`/`Ctrl`-`Shift`-`X`) for anyone to install -- no separate release
process on Kite's side beyond keeping `tree-sitter-kite`'s pinned `rev`
up to date as the grammar evolves.

## Updating later

Whenever `tree-sitter-kite/grammar.js` or `src/scanner.c` changes:

```bash
cd tree-sitter-kite
npx tree-sitter generate && npx tree-sitter build   # regenerate + sanity-build
git add -A && git commit -m "..." && git push
git rev-parse HEAD                                   # new SHA
```

Then update `editors/zed/extension.toml`'s `rev` to that new SHA, bump
`version` in both `extension.toml` and `tree-sitter-kite/package.json`/
`tree-sitter.json`, commit, push `zed-kite`, and (if it's already
published) open a follow-up PR against `zed-industries/extensions`
bumping the submodule pointer.

## Beyond Zed

The same `tree-sitter-kite` grammar and `highlights.scm` work with any
other editor built on tree-sitter (Neovim via `nvim-treesitter`, Helix,
etc.) -- see `tree-sitter-kite/README.md`'s "Using it" section. Only the
*packaging* (an `extension.toml`-shaped manifest, a registry PR process)
is Zed-specific; the grammar and highlight queries themselves are not.
