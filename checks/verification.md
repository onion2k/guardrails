# Verification

That each check reaches what it says it does: the thing as built and as
changed, every test it should run, and somewhere other than one machine.
Without it a check passes the old code, finds nothing to check and passes,
or holds only on the machine of whoever wrote it, and every green it gives
is believed for more than it holds.

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
- **Somewhere other than here.** The full check runs on a clean machine on
  every push to main, from a fresh clone, with the lockfile's
  dependencies, and is red when any gate is. A check that passes only on
  the author's machine holds the author's machine.
- **What it ran is said.** A report gives the count and the commit, so a
  green is read for what it holds and no more.

## Its smallest form

    // vitest fails a run that found no test files: passWithNoTests is false,
    // and is left so.

    // playwright.config.ts: the end-to-end tests run against the build, made fresh
    webServer: { command: 'npm run build && npm run preview', url: 'http://localhost:4173' },

    # .github/workflows/check.yml
    on: { push: { branches: [main] }, pull_request: {} }
    jobs:
      check:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v7
          - uses: actions/setup-node@v7
            with: { node-version: 'lts/*' }
          - run: npm ci
          - run: npm run check

The action versions are October 2026's: checkout 7.0 and setup-node 7.1.

A gate that measures on this machine's GPU or clock, as the project
file's _Gates_ says each does, is left out of CI by name, and said to be under _What is not held_: a runner a third as fast
fails it for the runner's reasons.

## Seen failing

A build older than the code is served to the end-to-end tests, and the
run is seen to refuse it or to fail on the change. A test file that
matches no tests is seen to fail the run. A gate is made red on a branch,
and CI is seen to fail it.

## Where it cannot apply

- **A runner that passes on nothing:** `cargo test` exits 0 with no tests
  at all, and other runners do the same. Where yours does, the count is
  checked by the script that calls it. pytest fails a run that collected
  nothing, with exit code 5.
- **A project with no CI** says so under _What is not held_, and stands
  in with a clean clone on a second machine before a release.
- **A package** verifies its published form: the packed archive,
  installed into a fresh project, not the source folder.
