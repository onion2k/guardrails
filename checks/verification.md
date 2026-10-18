# Verification

That each check reaches what it says it does: the thing as built and as
changed, every test it should run, and a clean copy of the commit and not
only the working tree. Without it a check passes the old code, finds
nothing to check and passes, or holds only in the working tree of whoever
wrote it, and every green it gives is believed for more than it holds.

## What it holds

The Verifying rules of `GUARDRAILS.md`, held as checks:

- **The built thing, not a copy.** The end-to-end tests and the gates run
  against what the build makes (end-to-end tests that start the dev
  server fall short of this), built from the code as it stands, not
  against the dev server, an old build, or a dependency pinned and not
  installed. The build is part of the run, or the run refuses a build
  older than the code.
- **Doing nothing is a failure.** A run that found no tests fails. A
  check counts what it reached (tests run, seeds played, scenes pictured)
  and fails a count of nothing, or less than it should be.
- **From a fresh clone.** Before a release, and on the user's word at any
  time, the full check runs from a fresh clone of the commit, made with `git
clone --no-local`, with the lockfile's dependencies installed clean, on
  this machine or another to hand, and is red when any gate is. What passes
  only in the working tree (an untracked file, a stale build, a global
  install, a cached dependency) fails there. A check that passes only on the
  author's machine holds the author's machine.
- **What it ran is said.** A report gives the count and the commit, so a
  green is read for what it holds and no more.

## Its smallest form

    // vitest fails a run that found no test files: passWithNoTests is false,
    // and is left so.

    // playwright.config.ts: the end-to-end tests run against the build, made fresh
    webServer: { command: 'npm run build && npm run preview', url: 'http://localhost:4173' },

    # before a release: the full check from a fresh clone of the commit
    git clone --no-local . "$(mktemp -d)/clone" && cd "$_"
    npm ci
    npm run check

A gate that measures on this machine's GPU or clock, as the project
file's _Gates_ says each does, holds on this machine, and the _Gates_
says which machine that is. A red from such a gate's wobble is the
gate's, not the clone's: it is run again on a quiet machine, as
[gates.md](gates.md) says, and only a red that stays is read.

## Seen failing

A build older than the code is served to the end-to-end tests, and the
run is seen to refuse it or to fail on the change. A test file that
matches no tests is seen to fail the run. A file the tests need is left
untracked, and the fresh-clone run is seen to fail. A gate is made red,
and seen red there.

## Where it cannot apply

- **A runner that passes on nothing:** `cargo test` exits 0 with no tests
  at all, and other runners do the same. Where yours does, the count is
  checked by the script that calls it. pytest fails a run that collected
  nothing, with exit code 5.
- **The fresh clone is run when someone runs it.** It is weaker than a
  clean machine run on every push, and the project file says under _What
  is not held_ that it is. A project that wants it on every push sets
  that up for itself, outside the kit.
- **A package** verifies its published form: the packed archive,
  installed into a fresh project, not the source folder.
