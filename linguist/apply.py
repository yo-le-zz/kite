#!/usr/bin/env python3
"""Apply the Kite language to a checkout (fork) of github-linguist/linguist.

    python3 linguist/apply.py /path/to/your/linguist-fork [--grammar-repo URL] [--skip-grammar] [--run-tests]

What it does (each step is idempotent):
  1. inserts the `Kite` entry into lib/linguist/languages.yml at its alphabetical position
     (the same result as running `script/update-ids`: language_id = sha256(name) % (2**30 - 1));
  2. copies the real-world samples into samples/Kite/;
  3. adds the TextMate grammar with Linguist's own `script/add-grammar` (needs Ruby + network);
  4. optionally runs the Linguist test-suite (`bundle exec rake test`).
"""
import argparse, hashlib, os, re, shutil, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ENTRY_FILE = os.path.join(HERE, "entry", "languages.yml.entry")
SAMPLES = os.path.join(HERE, "samples", "Kite")
NAME = "Kite"


def language_id(name):
    return int(hashlib.sha256(name.encode()).hexdigest(), 16) % (2**30 - 1)


def run(cmd, cwd, check=True):
    print("  $", " ".join(cmd))
    return subprocess.run(cmd, cwd=cwd, check=check)


def insert_entry(fork):
    path = os.path.join(fork, "lib", "linguist", "languages.yml")
    text = open(path, encoding="utf-8").read()
    if re.search(r"^Kite:\s*$", text, re.M):
        print("  languages.yml: Kite already present, skipping")
        return
    entry = open(ENTRY_FILE, encoding="utf-8").read()
    entry = re.sub(r"language_id: \d+", f"language_id: {language_id(NAME)}", entry)
    # find the first top-level key that sorts after "Kite" (plain byte order: Linguist keeps
    # languages.yml sorted ASCIIbetically, e.g. "KRL" < "Kaitai Struct" < "Kit" < "KoLmafia ASH")
    lines = text.split("\n")
    for i, line in enumerate(lines):
        m = re.match(r"^([^\s#\-][^:]*):\s*$", line)
        if m and m.group(1) > NAME:
            lines[i:i] = entry.rstrip("\n").split("\n")
            break
    else:
        lines += entry.rstrip("\n").split("\n")
    open(path, "w", encoding="utf-8").write("\n".join(lines))
    print(f"  languages.yml: inserted Kite (language_id {language_id(NAME)})")


def check_no_conflicts(fork):
    import yaml
    data = yaml.safe_load(open(os.path.join(fork, "lib", "linguist", "languages.yml"), encoding="utf-8"))
    for name, d in data.items():
        if name != NAME and ".ki" in (d.get("extensions") or []):
            sys.exit(f"error: the extension .ki is already used by {name!r}: add heuristics or samples for both languages")
    print("  .ki is not used by any other language")


def copy_samples(fork):
    dest = os.path.join(fork, "samples", NAME)
    os.makedirs(dest, exist_ok=True)
    n = 0
    for f in sorted(os.listdir(SAMPLES)):
        shutil.copy(os.path.join(SAMPLES, f), os.path.join(dest, f))
        n += 1
    print(f"  samples/Kite: {n} files")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("fork")
    ap.add_argument("--grammar-repo", default="https://github.com/yo-le-zz/vscode-kite")
    ap.add_argument("--skip-grammar", action="store_true")
    ap.add_argument("--run-tests", action="store_true")
    a = ap.parse_args()
    fork = os.path.abspath(a.fork)
    if not os.path.exists(os.path.join(fork, "lib", "linguist", "languages.yml")):
        sys.exit("error: not a linguist checkout: " + fork)
    print("1/4 languages.yml"); insert_entry(fork); check_no_conflicts(fork)
    print("2/4 samples"); copy_samples(fork)
    print("3/4 grammar")
    have_ruby = shutil.which("ruby") and shutil.which("bundle")
    if a.skip_grammar:
        print("  skipped (--skip-grammar)")
    elif not have_ruby:
        print(f"  Ruby/bundler not found. Run in the fork:\n    bundle install && script/add-grammar {a.grammar_repo}")
    else:
        run(["bundle", "install"], fork)
        run(["script/add-grammar", a.grammar_repo], fork)
    print("4/4 tests")
    if a.run_tests and have_ruby:
        run(["bundle", "exec", "rake", "test"], fork)
    else:
        print("  run in the fork:  bundle exec rake test")
    print("done. Review with `git status`, then commit and open the pull request (see linguist/PULL_REQUEST.md).")


if __name__ == "__main__":
    main()
