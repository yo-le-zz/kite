#!/usr/bin/env python3
"""Static checks that mirror what Linguist's test-suite verifies for a new language.

    python3 linguist/validate.py [path-to-linguist-fork-or-clone]

Without an argument it validates the entry/samples in this directory against a
`languages.yml` fetched from the `LINGUIST_DIR` environment variable, if set.
"""
import hashlib, os, re, sys, yaml

HERE = os.path.dirname(os.path.abspath(__file__))
root = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("LINGUIST_DIR")
errors = []

def check(cond, msg):
    if cond:
        print("  ok  ", msg)
    else:
        errors.append(msg)
        print("  FAIL", msg)

entry = yaml.safe_load(open(os.path.join(HERE, "entry", "languages.yml.entry")))["Kite"]
if root:
    data = yaml.safe_load(open(os.path.join(root, "lib", "linguist", "languages.yml"), encoding="utf-8"))
    data.setdefault("Kite", entry)
    langs = data
else:
    langs = {"Kite": entry}

print("entry")
for key in ("type", "extensions", "tm_scope", "ace_mode", "language_id"):
    check(key in entry, f"field {key}")
check(re.fullmatch(r"#[0-9A-Fa-f]{6}", entry.get("color", "")), "color is #RRGGBB")
check(entry["type"] in ("data", "programming", "markup", "prose"), "valid type")
check(all(e.startswith(".") for e in entry["extensions"]), "extensions start with a dot")
expected = int(hashlib.sha256(b"Kite").hexdigest(), 16) % (2**30 - 1)
check(entry["language_id"] == expected, f"language_id {expected} matches script/update-ids")
check(entry["tm_scope"] == "source.kite", "tm_scope source.kite")
if root:
    print("repository-wide")
    names = list(yaml.safe_load(open(os.path.join(root, "lib", "linguist", "languages.yml"), encoding="utf-8")))
    if "Kite" in names:
        k = names.index("Kite")
        before_ok = k == 0 or names[k - 1] <= "Kite"
        after_ok = k == len(names) - 1 or names[k + 1] >= "Kite"
        check(before_ok and after_ok, f"Kite is in alphabetical position (between {names[k-1]!r} and {names[k+1]!r})")
    else:
        nxt = next((n for n in names if n > "Kite"), None)
        print(f"  (not inserted yet) apply.py will insert it before {nxt!r}")
    ids = [d["language_id"] for d in langs.values() if "language_id" in d]
    check(len(ids) == len(set(ids)), "language_id unique")
    exts = {}
    for n, d in langs.items():
        for e in d.get("extensions", []):
            exts.setdefault(e, []).append(n)
    dup = {e: n for e, n in exts.items() if e == ".ki" and len(n) > 1}
    check(not dup, ".ki is unique (not shared with another language)")
    cols = [d["color"].lower() for n, d in langs.items() if "color" in d and n != "Kite"]
    check(entry["color"].lower() not in cols, "color not used by another language")
    print("  ok   samples/Kite exists in the checkout" if os.path.isdir(os.path.join(root, "samples", "Kite")) else "  (samples not copied yet: run apply.py)")

print("samples")
sdir = os.path.join(HERE, "samples", "Kite")
files = [f for f in os.listdir(sdir) if f.endswith(".ki")]
check(len(files) >= 5, f"{len(files)} sample files")
for f in files:
    t = open(os.path.join(sdir, f), encoding="utf-8").read()
    check(t.endswith("\n"), f"{f} ends with a newline")
    check("\t" not in t, f"{f} has no tabs")
    check(len(t.splitlines()) >= 10, f"{f} is long enough to be a useful sample")
print("RESULT:", "FAILED" if errors else "all checks passed")
sys.exit(1 if errors else 0)
