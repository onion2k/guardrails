---
name: next
description: Say where a project's work stands and what comes next. Runs the kit's script, which reads the project's plans and what git and the remote hold, and reads its screen out as one report: refusals, plans whose state line and boxes disagree, each open plan's next step, what the tidy skill would find, and what has landed since the last tag. Fetches, writes and changes nothing. Use when the user asks what is next, where things stand, what is open, or for a status of a project or a folder of them.
---

# next

Say where the work in a project stands, as `guardrails/checks/plans.md`
gives it, and what comes next. The script reads; this skill reads what it
printed, and says it plainly.

## 1. Run the script

`sh guardrails/next <folder>`, with the project's folder as its argument,
as `guardrails/checks/plans.md` shows (in the kit's own repo,
`sh next <folder>`). For a folder of projects, once for each folder in it
that has a `.git`, with the script of whichever project has it or the
kit's own: the script reads the folder it is given, not the one it lives
in. It reads `plans/*.md` and `PLAN.md`, git and the remote, and prints
one screen a project. It fetches nothing and writes nothing, so it can
run while other sessions are at work. Its exit status is 1 where a plan
was refused.

## 2. Read it

A bullet a kind of line:

- **A refusal** (`refused`): open the plan and say what its state line
  should say, from the file and its git log, in one of the four forms.
  For a plan that predates the kit, the boxes give the form: building
  where some are ticked and some open, the part in hand the first open
  box; agreed where none is ticked; landed where all are, at the commit
  the log shows the last tick in. Parked needs a why only the user has,
  so it is offered, not chosen. Do not write it.
- **A disagreement** (`the state line says`): say which is right, the
  line or the boxes, and what the line should be moved to.
- **A landed plan whose commit the default branch does not have** (the
  screen says `which <default> does not have`): say so. Either the line
  is wrong or the work did not land.
- **An open plan:** open each open plan and read its first open box in
  full, with the check written beside it, since the screen carries the
  box's text and not its check. Say its next step in a line. A box that
  asks the user something is a question, however it is written, and the
  decision is the user's.
  - Where no branch is at work on a building plan, it stopped, either
    landed without its line moved or given up. The boxes say which is
    possible: landed needs every part ticked. Say which the log suggests,
    and that the line should say landed or parked.
  - Where no branch is at work on an agreed plan with nothing ticked, it
    is waiting to be started, on whoever starts it or on the question it
    asks first. Say that it is waiting, not stopped.
- **What tidy would find:** by tidy's words, and that the tidy skill
  settles each on the user's word, leaving what is in use alone.
  _Not merged by ancestry_ is tidy's read-only word, settled by tidy's
  fetch and judgement by tree. _In use with its worktree_ on a branch is
  tidy's rule that a branch checked out in a worktree that is in use is
  in use with it.
- **Since the last tag:** whether what landed is worth a release (the
  tick of a plan's box is not), reading the commits with `git log` where
  the screen's summaries are not enough to judge. A release is the land
  skill's, on the user's word.
- **The rest** (`git:`, `plans landed`, `not pushed`, `detached`,
  `PRs not read`): facts, said where they change what the user does and
  left where they do not.

## 3. Report

In this order:

- what the user has to decide, a line each
- the script's screen, as printed
- the reading: a line a plan, and a line a kind of thing tidy would find

Nothing was written, fetched or changed, and that is said.
