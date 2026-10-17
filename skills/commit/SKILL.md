---
name: commit
description: Commit the work in the house style. The checks run first, a refactor and a feature are split into two commits, baselines and pictures go in the commit of the change that moved them, and the message is a sentence summary in the house voice with a body saying what changed and why. Use when the user asks to commit.
---

# commit

Commit only when asked, on the branch the checkout is on, and then like
this, as `guardrails/GUARDRAILS.md`'s _Landing a change_ says. Pushing,
PRs, merging and tagging are the land skill's, and happen only on the
user's word.

Where the checkout is on the project's default branch and the remote
protects it, the change goes on a branch of its own, named for what it
is, before it is committed: a commit on a protected default branch cannot
land as it is. The default branch, and whether it is protected, are read
from the remote as the land skill says, not assumed.

## 1. What is there

The working tree's status and diff. Say what is in it in a line, and
notice what should not be committed: test output, a user's data, a
baseline or picture that was written and not looked at, and another
session's or person's work. Work that is not yours is left alone: not
committed, stashed, reset or reformatted. Say it is there.

## 2. Green first

The quick check is the hook and runs anyway. If the change touches
anything a gate holds, run the full check, as the project file names it,
and say the result. A commit with a gate red is not made; the gate-moved
skill decides what to do about it. Where one has to be made red, the
message says so.

## 3. How many commits

- A refactor and a feature that land together are two commits, the
  refactor first, each green on the quick check on its own.
- A baseline or picture written again goes in the same commit as the
  change that moved it, never on its own.
- A new persisted shape and its corpus file go together.

## 4. The message

Read the last few commits and match them. A sentence summary in the house
voice, ending in a full stop, saying what the thing does now that it did
not; then a blank line, and a body saying what changed and why, in prose,
not a list of files. Where a figure moved,
the body says from what to what and why. Where something is still open,
the body says so. Any attribution lines the harness or the user asks for
go at the end.

## 5. Report

The commit hash and its summary line, what was left out of it and why,
and that nothing is pushed unless asked.
