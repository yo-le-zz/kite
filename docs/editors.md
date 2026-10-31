# Editor support

| editor | where | how |
|---|---|---|
| **Zed** | `editors/zed/` | tree-sitter grammar from `tree-sitter-kite/` + queries (highlights, brackets, indents, outline, overrides). `editors/zed/dev-setup.sh` installs it as a dev extension. |
| **VS Code** | `editors/vscode/` | TextMate grammar (`source.kite`), snippets, indentation rules. `npm run package` builds `kite-lang-<version>.vsix`; `code --install-extension kite-lang-0.3.0.vsix`. |
| **Neovim / Helix** | `tree-sitter-kite/` | the same tree-sitter grammar and `queries/*.scm`. |
| **GitHub** | `linguist/` | entry + samples + grammar for a pull request to `github-linguist/linguist` (language statistics and highlighting in repositories). Only possible once Kite is widely used; see `linguist/README.md`. |

## Tests
* `tree-sitter-kite`: `npx tree-sitter test` (23 corpus tests) and every `.ki` file of the repository must parse without error (CI).
* `editors/vscode`: `npm test` runs scope assertions (`test/assertions.test.ki`) and token snapshots (`test/snap/*.ki.snap`).
* `linguist/validate.py`: static checks mirroring Linguist's own tests.

## Keeping the grammars in sync with the language
When the syntax changes: edit `tree-sitter-kite/grammar.js` (then `npm run generate`), the corpus tests, and
`editors/vscode/syntaxes/kite.tmLanguage.json`; update the snapshots with `npm run snap` after reviewing the diff.
