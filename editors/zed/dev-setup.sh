#!/usr/bin/env bash
# One-time local setup for testing the Zed extension without publishing
# anything to GitHub first.
#
# Zed's `[grammars.kite]` in extension.toml needs a real git repository
# + commit to clone the grammar from -- but per Zed's own docs
# (https://zed.dev/docs/extensions/languages, "Grammar" section), that
# repository can be a `file://` URL pointing at a *local* git repo, not
# just a GitHub URL. This script makes `../../tree-sitter-kite` a local
# git repo (if it isn't one already), commits it, and points
# `extension.toml` at that local commit -- so "install dev extension"
# works without pushing anywhere. Publishing to GitHub for real (see
# ../../docs/zed-extension-publishing.md) is only needed once you want
# other people to be able to install this extension too.
#
# Usage: run this script, then in Zed: Cmd/Ctrl-Shift-P ->
# "zed: install dev extension" -> select this directory (editors/zed).

set -euo pipefail
cd "$(dirname "$0")"

GRAMMAR_DIR="../../tree-sitter-kite"
EXTENSION_TOML="extension.toml"

if [ ! -d "$GRAMMAR_DIR" ]; then
    echo "error: $GRAMMAR_DIR not found (run this from editors/zed/)" >&2
    exit 1
fi

cd "$GRAMMAR_DIR"
if [ ! -d .git ]; then
    echo "-> tree-sitter-kite isn't a git repo yet; initializing one locally"
    git init -q
    # Don't require the machine to already have a global git identity
    # configured just to make a throwaway local commit for Zed to
    # clone from -- only set one (repo-local, not --global) if none is
    # visible at all.
    if ! git config user.email > /dev/null 2>&1; then
        git config user.email "dev@localhost"
        git config user.name "kite-dev-setup"
    fi
    git add -A
    git commit -q -m "Local grammar checkout for Zed dev-extension testing"
else
    # Already a repo (maybe from a previous run of this script, or
    # because it's been published for real) -- just make sure whatever
    # is on disk right now is committed, so `rev` below points at the
    # grammar you're actually testing.
    if [ -n "$(git status --porcelain)" ]; then
        echo "-> committing local changes to tree-sitter-kite so Zed picks them up"
        if ! git config user.email > /dev/null 2>&1; then
            git config user.email "dev@localhost"
            git config user.name "kite-dev-setup"
        fi
        git add -A
        git commit -q -m "Update local grammar checkout for Zed dev-extension testing"
    fi
fi

ABS_PATH="$(pwd)"
SHA="$(git rev-parse HEAD)"
cd - > /dev/null

echo "-> pointing $EXTENSION_TOML at file://$ABS_PATH @ $SHA"
# Portable in-place sed (works on both GNU sed and BSD/macOS sed).
sed -i.bak \
    -e "s#^repository = \"https://github.com/[^\"]*/tree-sitter-kite\"#repository = \"file://$ABS_PATH\"#" \
    -e "s#^rev = \".*\"#rev = \"$SHA\"#" \
    "$EXTENSION_TOML"
rm -f "$EXTENSION_TOML.bak"

echo "-> done. In Zed: Cmd/Ctrl-Shift-P -> \"zed: install dev extension\" -> select this directory."
echo "   Re-run this script any time you change the grammar (grammar.js/scanner.c) and want Zed to pick it up."
