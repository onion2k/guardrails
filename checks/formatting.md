# Formatting

One formatter decides how every file it should touch looks, and nobody
argues with it. Without it every change carries a little reformatting, a
diff says less than it should, and a review spends itself on spaces.

## What it holds

That every file the formatter is for is as the formatter writes it. The
formatter's word is final: a style is not chosen file by file or person
by person, and lint stays out of it ([lint.md](lint.md)).

It is run two ways, never confused:

- **as a check,** in the quick check and so in the hook: it fails a file
  out of format, and changes nothing
- **as a write,** by hand, before a commit: it formats, and the change is
  looked at like any other

The hook never writes. A hook that formats as it commits changes what was
reviewed after it was reviewed.

Some files are not the project's to format, and are left by name in the
formatter's ignore file: what is generated, what is vendored, what a tool
writes and reads back byte for byte (a save corpus, a baseline), and
files another source owns, such as `guardrails/` and the kit's skills.
Formatted, the kit's files read as hand edits to its next update.

## Its smallest form

    // package.json
    "format":       "prettier --write .",
    "format:check": "prettier --check ."

    # .prettierignore: the same syntax as .gitignore
    dist
    package-lock.json
    test/saves/
    guardrails/
    # and each skill folder guardrails/INSTALLED.md lists as the kit's

A config file holds only what the project chose to differ from the
formatter's defaults, with the reason beside each. The fewer, the better:
every setting is a thing a new reader has to learn.

Prettier 3 (3.9 when this was written, October 2026).

## Seen failing

A file is put out of format by hand, and the quick check is seen to fail
on it, naming it. A file in the ignore list is put out of format, and is
seen to be left alone. The format check is seen to change nothing on disk
when it fails.

## Where it cannot apply

It applies to every project; only the tool changes.

- **Python:** `ruff format --check`, or black's `black --check`.
- **Rust:** `cargo fmt --check`.
- **Go:** `gofmt -l .` lists every file out of format; the check fails
  when the list is not empty.
- **Prose and config** (markdown, YAML, JSON) are formatted too, where
  the formatter knows them, so that a diff in a doc is a change in what it
  says.
