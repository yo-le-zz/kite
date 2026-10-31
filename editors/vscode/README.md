# Kite for Visual Studio Code

Syntax highlighting, snippets and language configuration for [Kite](https://github.com/yo-le-zz/Kite)
(`.ki` files): *readable like Python, fast like C*.

## Features
- Highlighting for the whole language: functions, classes (`class Dog(Animal)`), structs, enums with data,
  `match`/`case`, f-strings with `{interpolation}`, `ptr<T>`, `[T]`, tuple types, pointers and `alloc`.
- Snippets (`main`, `class`, `match`, `forr`, `pf`, ...).
- Indentation-aware editing: auto-indent after a line ending in `:`, folding, bracket pairs.

## Install
- From the Marketplace (once published): search for **Kite** by *yo-le-zz*.
- From a `.vsix`: `code --install-extension kite-lang-0.3.0.vsix`.

## Build and test
```
npm install
npm test            # grammar assertions + token snapshots
npm run package     # produces kite-lang-<version>.vsix
```

The TextMate grammar (`syntaxes/kite.tmLanguage.json`, scope `source.kite`) is also what
[GitHub Linguist](https://github.com/github-linguist/linguist) uses to highlight `.ki` files on GitHub.

MIT licensed.
