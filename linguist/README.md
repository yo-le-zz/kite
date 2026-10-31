# Adding Kite to GitHub Linguist

This directory contains everything needed for the pull request that makes GitHub recognise
`.ki` files as **Kite** (language statistics in repositories + syntax highlighting).

| file | purpose |
|---|---|
| `entry/languages.yml.entry` | the `Kite:` entry for `lib/linguist/languages.yml` |
| `samples/Kite/*.ki` | real-world samples (the Kite compiler written in Kite, its prelude, a parser example) |
| `apply.py` | applies entry + samples (+ grammar) to your fork of Linguist |
| `validate.py` | static checks mirroring Linguist's tests (ordering, ids, colour, samples ...) |
| `PULL_REQUEST.md` | the pull-request text, already filled in following Linguist's template |
| `export-grammar-repo.sh` | creates the standalone grammar repository Linguist needs |

## Important: Linguist's usage requirements
Linguist only accepts a language once it is widely used on GitHub (see its CONTRIBUTING.md,
"Language extension and filename usage requirements"): **at least ~2000 indexed `.ki` files**, spread across
many different `user/repo` pairs. Hobby or very new languages are closed without review. So the plan is:
prepare everything now (this directory), keep the fork up to date, and open the PR once the search below
shows enough results:

    https://github.com/search?type=code&q=NOT+is%3Afork+path%3A*.ki+%22make+main%22

## Step by step
1. **Grammar repository.** Linguist vendors grammars as git submodules, so the grammar must live in its own
   public repo with an open-source licence (MIT here):
   ```
   linguist/export-grammar-repo.sh /tmp/vscode-kite     # copies editors/vscode (grammar, tests, LICENSE)
   cd /tmp/vscode-kite && git remote add origin git@github.com:yo-le-zz/vscode-kite.git && git push -u origin main
   ```
2. **Fork + clone** `github-linguist/linguist` (your fork: `yo-le-zz/linguist`).
3. **Apply** (needs Ruby + `bundle install` for the grammar step):
   ```
   python3 linguist/apply.py /path/to/linguist --grammar-repo https://github.com/yo-le-zz/vscode-kite
   ```
   It inserts the entry between `Kit` and `KoLmafia ASH` (Linguist keeps `languages.yml` in byte order),
   copies `samples/Kite`, and runs `script/add-grammar` (which adds the submodule, `grammars.yml`, the
   licence file and `vendor/README.md`).
   `language_id` is `sha256("Kite") % (2**30 - 1)` = **1007285693**, exactly what `script/update-ids` computes;
   run `script/update-ids --check` if you want Linguist to confirm.
4. **Check**: `python3 linguist/validate.py /path/to/linguist` then, in the fork, `bundle exec rake test`
   (and `bundle exec script/cross-validation --test` for the classifier).
5. **Open the PR** against `github-linguist/linguist` using `PULL_REQUEST.md` (the template must be used).

## Why these choices
* `type: programming`, `ace_mode: text` (no Ace mode for Kite), no `codemirror_mode`.
* `color: "#8B5CF6"` is taken from the feather in the Kite logo (violet end of its gradient); no other language uses it.
* `.ki` is not used by any language in Linguist (checked against `languages.yml`), so no heuristics are needed.
* `tm_scope: source.kite` is the scope name of `editors/vscode/syntaxes/kite.tmLanguage.json`. Linguist compiles
  grammars with PCRE: the grammar only uses lookaheads and a begin/end back-reference, which PCRE supports.

## What has been verified
Against a fresh clone of `github-linguist/linguist` (Ruby 3.2, the gems that could be installed offline):
* `test_pedantic` (sorting / formatting of the YAML files): 11 runs, 1009 assertions, **0 failures** with Kite added;
* `test_samples` (every sample is classified correctly, incl. `samples/Kite/*`): 1678 runs, **0 failures**;
* `test_classifier`: 6 runs, **0 failures**;
* `Language["Kite"]` resolves (`language_id` 1007285693, `.ki` -> Kite, colour `#8B5CF6`, scope `source.kite`);
* `test_language`: the only failures are environmental (the CodeMirror vendor files are absent from a shallow clone)
  and the "scope not listed in grammars.yml" check, which `script/add-grammar` resolves (simulated here by adding
  `vendor/grammars/vscode-kite` and its `grammars.yml` entry: that check then passes).
`test_grammars` (README sync + licences) can only pass once the grammar is added with `script/add-grammar`, which
needs the published grammar repository and network access to rubygems; run `bundle exec rake test` in your fork.
