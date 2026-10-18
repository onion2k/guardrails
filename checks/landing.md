# Landing

What of `GUARDRAILS.md`'s _Landing a change_ can be held by something
other than words: the hooks, what a PR carries, and branches left behind.
Without it a commit lands with no body, a PR is merged with nothing to
say the full check was run on it, and branches merged months ago are
still there to be confused with work in hand.

## What it holds

- **The hooks run.** `.githooks/pre-commit` runs the quick check, and
  `.githooks/commit-msg` holds a message to a sentence summary, a blank
  line and a body. Git is pointed at them, by the project's install step.
- **A PR carries the full check's result.** The commit it ran on and what
  it counted ([verification.md](verification.md)), since nothing else
  runs it, and a PR without it is not merged.
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

## Seen failing

- A commit with no body is tried, and the `commit-msg` hook is seen to
  refuse it; so is a summary with no full stop.
- A branch is merged and left, and the script is seen to list it.

Each fault is taken out again, and nothing is committed by the trial.

## Where it cannot apply

- **A project with no remote** has no PRs. Its hooks are held, and the
  rest says so under _What is not held_.
