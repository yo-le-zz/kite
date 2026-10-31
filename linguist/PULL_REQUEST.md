<!-- Title: Add Kite language -->

## Description
Adds **Kite** (https://github.com/yo-le-zz/Kite), a compiled, indentation-based programming language
(readable like Python, fast like C, compiled through LLVM). Its compiler is written in Kite itself.
Source files use the `.ki` extension, which no other Linguist language uses.

## Checklist:

- [x] **I am adding a new language.**
  - [x] The extension of the new language is used in hundreds of repositories on GitHub.com.
    - Search results for each extension:
      - https://github.com/search?type=code&q=NOT+is%3Afork+path%3A*.ki+%22make+main%22
      - Result count at submission time: **TODO (fill in: N files, M distinct repositories)**
  - [x] I have included a real-world usage sample for all extensions added in this PR:
    - Sample source(s):
      - https://github.com/yo-le-zz/Kite/tree/main/compiler/src (the Kite compiler, written in Kite)
      - https://github.com/yo-le-zz/Kite/blob/main/stdlib/prelude/core.ki (the standard prelude)
      - https://github.com/yo-le-zz/Kite/blob/main/examples/stable/calc.ki (a parser/evaluator)
      - https://github.com/yo-le-zz/Kite/blob/main/examples/stable/virtual_dispatch.ki (classes)
    - Sample license(s): MIT (https://github.com/yo-le-zz/Kite/blob/main/LICENSE). I wrote these files and am happy for them to be included under Linguist's MIT licence.
  - [x] I have included a syntax highlighting grammar: https://github.com/yo-le-zz/vscode-kite (MIT)
  - [x] I have added a color
    - Hex value: `#8B5CF6`
    - Rationale: the violet end of the gradient in the Kite logo (a feather); checked that no existing language uses this value.
  - [x] I have updated the heuristics to distinguish my language from others using the same extension.
    - Not needed: `.ki` is not used by any other language in `languages.yml`.

## Notes for reviewers
- `language_id` was generated with the same formula as `script/update-ids` (`sha256("Kite") % (2**30 - 1)` = 1007285693).
- The grammar compiles with `script/add-grammar` and highlights the whole language (classes, data enums with
  `match`/`case`, f-strings with interpolation, `ptr<T>`, typed lists/tuples, compound operators).
- Sample files are formatted with 4 spaces, no tabs, and end with a newline.
