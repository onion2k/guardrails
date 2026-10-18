---
name: land
description: Land committed work on the project's default branch, the way the guardrails kit says a change lands. Reads from the remote whether the branch is protected, then pushes straight to it or opens a PR, runs the full check once more before a merge, merges in the project's style, tags a release when asked, and clears up. Pushes, opens PRs, merges and tags only on the user's word, or where the project file grants it. Use when the user asks to push, open a PR, merge, land or release work.
---

# land

Take committed work to the project's default branch, as
`guardrails/GUARDRAILS.md`'s _Landing a change_ says. The project's
`AGENTS.md`, under _How a change lands_, gives its merge style and what an
agent may do without asking. Read both first.

Each step that reaches the remote (a push, a PR opened, a merge, a tag)
happens only on the user's word, each time, unless the project file grants
that step by name. A grant allows only what it names: merging and tagging
are asked for every time, whatever it says.

## 1. What is there

- The branch the checkout is on, and its commits not yet on the remote.
  Say them in a line each.
- The working tree. Anything uncommitted stays out of what lands and is
  said; work that is not yours is left alone.
- The pass: the definition of done's checks run once before a change
  lands on the default branch. Where the report of the change does not
  show it run and green on these commits, run it. Where it cannot be run
  (no full check named, nothing installed), say so, and say it again in
  the question before the push: the user decides whether it lands
  unchecked.

## 2. Where it lands

Read from the remote, each time, never from memory:

- the **default branch**, which is not always `main`
- whether it is **protected**: by branch protection, or by a ruleset with
  a rule that asks for a pull request

On GitHub, `gh api repos/<owner>/<repo> --jq .default_branch`, then
`gh api repos/<owner>/<repo>/branches/<default> --jq .protected`, and
`gh api repos/<owner>/<repo>/rules/branches/<default>`, where a rule of
type `pull_request`, `update` or `merge_queue` means a PR. On another
host, its own way of saying the same. A plain git remote (a bare repo, a
path, an SSH address with no host behind it) has no protection to read,
and the user is always asked. Where it cannot be read for any reason (no
tool, no access, no remote) ask the user, and do not guess.

Protection of any kind is the signal, by the project's choice. A
protected branch means a PR even where the protection only forbids a
force push, and `protected: true` with no rules in the ruleset list is
protection: a project that wants pushes straight to the default branch
leaves it unprotected.

Not protected: the change lands by a push to the default branch.
Protected: it lands by a PR from a branch named for what it is. Commits
made on the default branch by mistake are moved to that branch before
anything is pushed.

## 3. Push, or open the PR

Only on the user's word, or the project file's grant for this step. Say
what will happen first: which commits, to which branch, on which remote.

- **A push** that the remote refuses stops here. Say what it said; where
  the refusal is the branch's protection, the change goes by PR instead,
  on the user's word.
- **A PR** says what changed and why, the definition of done point by
  point, and what was not verified, so it stands by itself for a reader
  who sees nothing else. Its title is the change's summary line.

## 4. The full check, once more

Before a merge, run the full check on the branch as it will merge: merged
with the default branch locally, in a worktree of its own, with the
checkout left as it was. Put the result in the PR: passed or failed (with
the failure's first lines), the commit it ran on, and what it counted.
A red check is a fault to be found at its cause: the bug skill, or the
gate-moved skill for a gate.

## 5. Merge

Only on the user's word, every time. In the project's merge style, a merge
commit where its file says nothing, with the full check green. A
merge the remote refuses stops here, and is said.

## 6. Release, when asked

Only on the user's word, every time:

- the next semver tag, annotated, on the commit released, with what
  changed in a line; and a line in the project's release notes
- pushed only on the user's word as well

A tag that has been pushed is never moved or deleted. One not yet pushed
may be moved, on the user's word, and the move is said.

## 7. Clear up

Once the work has landed: the branch it was made on, local and remote,
any worktree and any snapshot it was built from, each removed after
checking that what it held is in what landed. A branch that holds
anything that did not land is kept, and said. Then run the tidy skill's
find (its steps 1 to 3) and say anything else it shows.

## 8. Report

- **Outcome:** where the work is now: pushed, a PR open (its link), merged,
  or tagged, and what is still the user's to do.
- **What was read:** the default branch and whether it is protected, and
  how that was found.
- **The full check:** its result, and the commit it ran on.
- **Not done,** and why: a step waiting on the user's word, a refusal, a
  red full check.
