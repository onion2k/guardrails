# The quick check

Everything cheap, run before every commit: the formatter, the types, lint,
the structure where it is quick, and the unit tests. Without it a commit
can land that does not compile, and the next person to pull it finds out
for you.

## What it holds

That what is committed passes each of its parts, in this order, cheapest
first so that a failure is found quickly:

1. the formatter, as a check ([formatting.md](formatting.md))
2. the types
3. lint ([lint.md](lint.md)), and the structure rules where they are
   fast enough ([structure.md](structure.md))
4. the unit tests ([unit.md](unit.md))

Each part's file says what it holds. This one holds that they run, before
every commit, whoever makes it: git runs the hook, not a harness. It is
the floor the full check stands on.

It is quick enough to be run: under half a minute on the machine it is
written on, so nobody is tempted to skip it. A test that grows slow moves
to the full check, or is made quick, before the hook is given up.

## Its smallest form

Two scripts in the project's own runner, and a hook that calls the first:

    "check:quick": "prettier --check . && tsc --noEmit && eslint . && vitest run",
    "check":       "npm run check:quick && npm run fuzz && npm run determinism && ..."

    #!/bin/sh
    # Everything quick before a commit. The gates take longer: run the full check for those.
    exec npm run --silent check:quick

The hook lives in the repo (`.githooks/pre-commit`, with `git config
core.hooksPath .githooks` run by the project's install step), so a clone
has it without being told. The hook checks; it never writes. A hook that
formats or fixes as it commits changes what was reviewed after it was
reviewed.

The full check runs the quick check first, then every gate. The project
file names both, and how long each takes.

## Seen failing

Each part's file says how that part is seen to fail. What is left to this
one is the hook: a fault each part should catch is put in, a commit is
tried through `git commit`, and the hook is seen to refuse it. A hook that
is not installed passes every commit in silence, so it is tried through
git, not by running the script. The fault is taken out again, and nothing
is committed.

## Where it cannot apply

- **A language with no types** holds what stands in for them: a schema at
  the edges, or a type checker run over annotations.
- **A monorepo** runs the quick check of what changed, and the full check
  of everything, and says which in the project file. Where the whole of
  it is quick, the whole of it runs.
