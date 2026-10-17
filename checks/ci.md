# CI

The project's workflows, held to the least they need. A workflow is code
that runs with the project's token and secrets: without this one is given
write access it never uses, runs a third party's code at whatever that
code is today, or runs a stranger's PR with the project's keys.

## What it holds

- **Permissions are said, and least.** Every workflow has a
  `permissions:` block, read-only at the top, and a job that needs to
  write is given that one permission, with a comment saying why, even
  where it is the workflow's only job: a second job added later starts
  read-only. The default `GITHUB_TOKEN` is a secret like any other, and
  what it may do is what these blocks say. A
  workflow with no block runs with the token's default, which may be
  write to everything.
- **Third-party actions are pinned to what was read.** An action not
  published by GitHub is used by its full commit hash, with its tag in a
  comment, never by a tag or a branch that can be moved under it. GitHub's
  own `actions/*` stay on their major tags; every other organisation,
  GitHub's other ones included, is pinned by hash. The update bot keeps
  the hashes current and the comments with them. An action with no tag to
  pin to, only a branch such as `stable`, is pinned to the branch's commit
  as it was read, and its comment names the branch and the date.
- **A stranger's code never runs with the project's keys.** No
  `pull_request_target` or `workflow_run` job checks out and runs a PR's
  code. Text from a PR, an issue or a branch name is passed to a step
  through an environment variable, never written into `run:`, nor into an
  input that an action runs as code (such as `actions/github-script`'s
  `script:`). An input an action only reads as a value is not code.
- **A secret goes only where it is needed:** to the step, not the job or
  the workflow, and is never echoed.

## Its smallest form

    permissions:
      contents: read

    jobs:
      release:
        permissions:
          contents: write   # the release job creates the GitHub release, and nothing else does
        steps:
          - uses: actions/checkout@v7
          - uses: tauri-apps/tauri-action@<full commit hash>   # the tag it was read at

    # .github/zizmor.yml: GitHub's own actions on their tags, the rest by hash
    rules:
      unpinned-uses:
        config:
          policies:
            actions/*: ref-pin
            "*": hash-pin

    # in CI, and once by hand on every workflow
    - run: pipx run zizmor .github/workflows

zizmor (1.31, October 2026) audits workflows for this:
`excessive-permissions`, `unpinned-uses` (which by default asks every
action for a hash, so it is told GitHub's own are allowed their tags),
`dangerous-triggers` and `template-injection`. Its config is found at
`.github/zizmor.yml`, and a more particular pattern wins over a wider one. actionlint checks that a workflow is well formed,
and does not look for any of this. Dependabot's `github-actions`
ecosystem updates a hash-pinned action and its comment together, where
the comment is on the same line.

## Seen failing

- A workflow with its `permissions:` block removed is flagged.
- An action moved from its hash back to a tag (`@v0`, `@stable`) is
  flagged.
- A step that writes a PR's title into `run:` is flagged.

Each change is made on a throwaway branch and dropped.

## Where it cannot apply

- **A project with no CI** has nothing here yet, and gains this check
  with its first workflow (`verification.md` asks for one).
- **Another host:** GitLab CI's job tokens and protected variables, and
  pinning an included template to a commit, hold the same rules; the
  project file says which it has.
