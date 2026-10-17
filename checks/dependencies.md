# Dependencies

What the project takes in from others: code it ships and did not write.
Without this an install gives a different tree on another machine, an
advisory against a package sits unread for a year, a licence the project
cannot ship turns up at release, and packages nothing uses are still
downloaded, audited and updated.

## What it holds

- **Installs are exact.** The lockfile is committed. CI and every gate
  install from it, and fail where it would change, rather than quietly
  writing a new one. A dependency taken from a git ref is pinned to a tag
  or a commit, never a branch.
- **Known advisories are seen.** An audit of the installed tree runs in
  CI on every push and on a schedule, because an advisory can be published
  against a tree that has not changed. It does not run in the hook: it
  needs the network, and its answer moves when nothing here has. It covers
  dev dependencies as well as what ships: a test runner runs on every
  developer's machine and in CI, with their access. It fails at the
  project's threshold, the same for both unless the project file says
  otherwise. A finding the project accepts is written
  down, with why and a date to look again, and is listed by every run
  until then.
- **Licences are allowed.** Every dependency's licence that ships, read
  from the installed tree, is on the project's allowed list. What ships is
  the production dependencies: a dev dependency's licence is reported, and
  matters only where the tool itself is handed on. The project's own
  packages, marked private, are left out. One that is not fails
  the check by name, and is asked about, never added to the list to make
  it pass.
- **Nothing is unused.** A dependency no code imports is reported, and is
  removed, or kept with a line saying why. A tool that says nothing when
  it finds nothing is trusted only once it has been seen to find
  something (_Seen failing_).
- **Updates are made, not drifted into.** Updates arrive the way the
  project file says, and each lands as a commit of its own, held to the
  same checks as any change.

The questions a project answers, at install or when its file lacks them:

1. **Audit threshold:** high and critical fail, moderate is reported, and
   an exception is written with why and looked at again within 90 days
   (recommended). Or a threshold of the project's own.
2. **Allowed licences:** MIT, BSD-2-Clause, BSD-3-Clause, ISC, Apache-2.0,
   0BSD and the Unlicense, with anything else asked about by name
   (recommended). Or a list of the project's own.
3. **How updates arrive:** a bot for security updates only, and version
   updates by hand, monthly, a commit each (recommended). Or a bot for all
   updates, grouped weekly.

## Its smallest form

    // package.json
    "audit":    "npm audit --audit-level=high",
    "licences": "license-checker-rseidelsohn --production --excludePrivatePackages --onlyAllow 'MIT;BSD-2-Clause;BSD-3-Clause;ISC;Apache-2.0;0BSD;Unlicense'",
    "unused":   "knip --dependencies"

    # .github/workflows/dependencies.yml
    on:
      push: { branches: [main] }
      schedule: [{ cron: '0 6 * * 1' }]
    jobs:
      dependencies:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v7
          - uses: actions/setup-node@v7
            with: { node-version: 'lts/*' }
          - run: npm ci
          - run: npm run audit
          - run: npm run licences
          - run: npm run unused

    # .github/dependabot.yml: security updates only. They are turned on
    # in the repository's settings, not here; this stops version updates.
    version: 2
    updates:
      - package-ecosystem: npm
        directory: /
        schedule: { interval: monthly }
        open-pull-requests-limit: 0

`npm ci` fails where the lockfile and `package.json` disagree, instead of
updating the lockfile. `npm audit --audit-level` sets the lowest severity
that fails the run, and still reports the rest. With pnpm:
`pnpm install --frozen-lockfile`, the default in CI, and
`pnpm audit --audit-level high`, which reports at that level and above.
Whether an audit that reached no registry fails depends on the tool and
its version: pnpm's current docs say a registry error leaves it exiting
0, and pnpm 8 was seen to exit 1. So the job does not trust the exit code
alone: it runs the audit with `--json` and fails where what came back is
not a report. In a workspace, the licence check runs in each package
that ships (`pnpm -r exec`), since a workspace's root often has nothing
but dev dependencies, and is found to have no packages at all. With Renovate in place of Dependabot, the preset
`security:only-security-updates` does the same.

npm 12, pnpm 12, license-checker-rseidelsohn 5 (the original
license-checker has had no release since 2019; version 5 asks for Node
24), knip 6, actions/checkout 7
and setup-node 7, all as of October 2026. A scheduled workflow runs from
the default branch, in UTC, and GitHub stops it in a public repository
after 60 days with no activity, so a quiet project checks that it still
runs.

## Seen failing

Each fault is put in on a throwaway branch, seen to fail, and taken out:

- a lockfile edited by hand, so that it disagrees with the manifest: the
  exact install fails
- a dependency pinned to a version with a published advisory at the
  threshold: the audit fails, naming it
- a dependency whose licence is not on the list: the licence check fails,
  naming it
- an import removed, leaving its dependency unused: it is reported
- the audit pointed at a registry that cannot be reached
  (`--registry http://127.0.0.1:9`): the job fails, and does not pass on
  an empty report

## Where it cannot apply

- **Python:** `uv sync --locked` (fails where `uv.lock` would change;
  `--frozen` does not check it, and is not the one wanted), pip-audit
  (exits 1 on a finding).
- **Rust:** `cargo build --locked`, cargo-audit (RustSec), and cargo-deny
  for licences, with `[licenses] allow = ["MIT", "Apache-2.0", ...]` in
  `deny.toml`.
- **Go:** `go mod verify`, and govulncheck (`govulncheck ./...`, which
  exits non-zero on a finding, except with `-json` or another format).
- **A dependency from a git ref** is in no advisory database. Its tag is
  its pin, and the package's own project file lists, under _Who uses it_,
  each project that pins it and at what, so that drift between them is
  seen there. That list is checked against the pinning projects' own
  manifests wherever they can be read, and a list that disagrees is a
  finding in the package. A lockfile that resolves it over `git+ssh`
  installs only where there is a key: CI is given one, or the dependency
  is resolved over HTTPS, and a clean CI install shows which.
- **A project with no dependencies** says so, and keeps the rule for the
  day it takes one in.
