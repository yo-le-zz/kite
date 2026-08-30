# Style

## Tabs vs spaces

Kite uses significant indentation to mark blocks, the same way Python
does -- no `{`/`}` or `begin`/`end` needed:

```
make greet(name: string) -> string:
    if name == "":
        return "Hello, stranger!"
    return "Hello, " + name + "!"
```

**Both tabs and spaces work.** Use whichever your editor produces by
default -- you don't need to change any settings. A tab is treated as
advancing to the next multiple of 8 columns (the same convention almost
every editor and terminal already uses to *display* a tab), so:

- A file indented entirely with spaces: works, like the example above.
- A file indented entirely with tabs: also works.
  ```
  make greet(name: string) -> string:
  	if name == "":
  		return "Hello, stranger!"
  	return "Hello, " + name + "!"
  ```
- Two sibling lines that are indented differently but land on the same
  column once tabs are expanded (say, one tab vs. eight spaces): also
  fine, as long as it's consistent going down that block.

**What doesn't work** is switching between tabs and spaces *within the
same nesting decision* in a way that's genuinely ambiguous -- e.g. one
line in a block indented with a tab and the very next sibling line
indented with four spaces. Nothing about the file says whether that
was on purpose, so the compiler rejects it rather than guessing:

```
make main():
	if true:
        print(1)     // error[E0004]: inconsistent use of tabs and
                      // spaces in indentation
```

Fix it by making that block consistently one or the other. You don't
need to convert the *whole file* -- just that one block -- though
sticking to one style throughout a file (and matching whatever your
team/editor already defaults to) is the easier habit to keep. Most
editors have a "convert indentation" command if you want to normalize
an existing file in one go.

Why not silently guess what a tab "means" when it's mixed with spaces?
Because guessing wrong is exactly how Python's classic
`TabError`-flavored bugs happen: two lines can *look* identical in an
editor with tab-width set to 4, but mean two different nesting levels
once someone else opens the same file with tab-width set to 8. Kite
would rather tell you immediately, at compile time, than let that kind
of bug hide until someone reads the file differently than you did.
