# Landing

What of `GUARDRAILS.md`'s _Landing a change_ can be held by something
other than words: the hooks, the remote's protection, and branches left
behind. Without it a commit lands with no body, a protected branch is
protected by nothing that runs the checks, and branches merged months ago
are still there to be confused with work in hand.

## What it holds

- **The hooks run.** `.githooks/pre-commit` runs the quick check, and
  `.githooks/commit-msg` holds a message to a sentence summary, a blank
  line and a body. Git is pointed at them, by the project's install step.
- **A protected default branch is protected by the checks.** Where the
  remote protects it, its required status checks include the full check,
  run in CI ([verification.md](verification.md)), so a PR cannot merge
  red. Protection that asks for a PR and no checks asks for a ritual.
- **Nothing is left lying about.** A branch, local or remote, whose work
  is all on the default branch is cleared, and nothing unmerged,
  uncommitted or stashed is left without a word saying why. The tidy
  skill finds all of it, wherever it was made, and its find (steps 1 to 3) is this check's survey.

What it does not hold: the house voice of a message, what a PR says, or
whether the user's word was given. Those are said in the rules and the
land skill, and read by a person.

## Its smallest form

    .githooks/pre-commit      the quick check, from the kit's template
    .githooks/commit-msg      the message's shape, from the kit's template

    # the branches merged into the default branch and still here
    git fetch --prune
    git remote set-head origin --auto >/dev/null
    default="$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||')"
    git branch --merged "origin/$default" | grep -v -e '^\*' -e " $default\$"
    git branch -r --merged "origin/$default" | grep -v -e "origin/$default\$" -e 'origin/HEAD'

The script is read, not run to delete: a branch is removed once what it
held is checked against what landed, by the land skill or by hand.

On GitHub, the protection's required checks are set in the repository's
settings, under the branch's rule or ruleset, by someone with admin
rights. They cannot be read without those rights, so a project file says
what it set, and when.

## Seen failing

- A commit with no body is tried, and the `commit-msg` hook is seen to
  refuse it; so is a summary with no full stop.
- On a protected branch, a PR with the full check made red is seen not to
  be mergeable.
- A branch is merged and left, and the script is seen to list it.

Each fault is taken out again, and nothing is committed by the trial.

## Where it cannot apply

- **A project with no remote** has no protection and no PRs. Its hooks
  are held, and the rest says so under _What is not held_.
- **A remote that is not GitHub** sets protection its own way: GitLab's
  protected branches, Bitbucket's branch restrictions. The project file
  says which, and what is set.
- **A project whose CI cannot run the full check** (a gate that needs
  this machine's GPU) has the checks that can run required, and says
  which cannot, under _What is not held_.
