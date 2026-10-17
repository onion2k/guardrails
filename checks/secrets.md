# Secrets

No key, token or password in the tree, or in its history. Without this a
secret is committed once, pushed once, and from then on is in every clone
and every fork, whatever is done to the tree afterwards.

## What it holds

- **Nothing staged holds a secret.** A scanner runs in the hook, over
  what is staged, before each commit: it is quick, needs no network, and
  a secret is cheapest to stop before its commit exists.
- **Nothing in the history does.** The same scanner runs in CI over the
  whole history, on every push, and the host's own push protection is
  turned on where the host has it.
- **Secrets come from outside the tree.** The code reads them from the
  environment or a secret store. The tree carries an example file with
  every name the code reads and no values, and a check holds the names
  equal.
- **An accepted finding is named.** A test fixture or a public key the
  scanner mistakes for a secret is allowed by its fingerprint, with a line
  saying why, and nothing wider.
- **A secret found is rotated first.** Removing it from the tree does not
  take it out of the history or anyone's clone. It is revoked and
  replaced at its service, and only then cleaned out. A secret is never
  quoted in a report, a log or a commit message: it is named by its path
  and line.

## Its smallest form

    # .githooks/pre-commit, before the quick check
    gitleaks git --pre-commit --redact --staged --verbose || exit 1

    # CI, over the whole history
    - uses: actions/checkout@v7
      with: { fetch-depth: 0 }
    - run: gitleaks git --redact --verbose

    # .gitleaksignore: the fingerprint of each accepted finding,
    # commit:file:rule:line; why each is not a secret is kept in the
    # project file, under Accepted findings

    # .env.example: every name the code reads from the environment,
    # secret or not, with no values
    API_URL=
    SENTRY_DSN=

gitleaks 8 (8.30, October 2026); the hook's line is the one gitleaks'
own pre-commit hook runs. `gitleaks git --staged` scans what is staged,
and `gitleaks git` the history, and both exit 1 on a finding.
`--verbose` is what prints each finding's rule, file, line and commit;
without it a failing run says only how many it found. `--redact` keeps
the secret itself out of the output. `protect`
and `detect`, which older guides use, were deprecated in 8.19. gitleaks
is feature complete and takes security fixes only: its authors have moved
on to Betterleaks (MIT, by gitleaks' original author), which a project
takes up once its version 2 is released, reading its own docs for what
changes. On GitHub, secret scanning and push protection are free for
public repositories, and are turned on in the repository's settings,
under Advanced Security.

## Seen failing

- **A planted key** of the scanner's own shape (an AWS key id is `AKIA`
  and sixteen capitals and digits from 2 to 7) is staged, and the hook
  refuses the commit, naming the file and line. A key ending in
  `EXAMPLE`, as AWS's own documented example does, is let through by
  gitleaks on purpose, and proves nothing.
- **A planted key three commits back,** on a throwaway branch, is found
  by the history scan.
- **A name the code reads,** removed from the example file, fails the
  check that holds them equal.

Each planted key is made up for the trial, never a real one, and the
branch it was on is deleted.

## Where it cannot apply

- **Any language:** the scanner reads text, not code, so it is the same
  everywhere. trufflehog (version 3) does the same job and can check a
  found key against its service (`--results=verified`), which suits an
  audit of a history, not a hook.
- **A host without push protection** has the CI scan and the hook, and
  says so under _What is not held_.
- **A project with no secrets at all** still runs the hook: it is the
  thing that keeps it that way.
