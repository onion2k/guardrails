# The quick check

Everything cheap, run before every commit: the formatter, the types, lint
and the unit tests. Without it a commit can land that does not compile, and
the next person to pull it finds out for you.

## What it holds

That what is committed is formatted as the formatter says, type-checks,
passes lint, and passes the unit tests. It is the floor the full check
stands on, and the one check every change meets whoever makes it, because
git runs it and not a harness.

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
has it without being told. Lint uses the type-aware rules: they are the
ones that find mistakes. Style is the formatter's, and lint stays out of
it.

The full check runs the quick check first, then every gate. The project
file names both, and how long each takes.

## Seen failing

Before it is trusted, each of its four parts is made to fail once, and the
commit refused:

- a file put out of format
- a type error
- a lint error the type-aware rules catch, such as a promise not awaited
- a unit test made to fail

A hook that is not installed passes every commit in silence, so the
fourth is tried through `git commit`, not by running the script.

## Where it cannot apply

- **A language with no types** holds what stands in for them: a schema at
  the edges, or a type checker run over annotations.
- **A project with no formatter yet** gets one before anything else here.
  A formatter argued with is taste; one that decides is not.
- **A monorepo** runs the quick check of what changed, and the full check
  of everything, and says which in the project file.
