---
name: guardrails
description: Take a project up the guardrails kit's checks, one at a time, each seen failing before it is trusted. Reads the project, writes or completes its AGENTS.md from what the code does, says which checks it has, which it lacks and which cannot apply, agrees an order with the user, then adds each check in its smallest form with a fault put in on purpose to prove it. Use when the kit has just been installed, when a project has no AGENTS.md or one missing the kit's headings, or when the user asks what guardrails a project has.
---

# guardrails

Take a project from whatever it has to the checks in
`guardrails/checks/`, one at a time. The rules are in
`guardrails/GUARDRAILS.md`: read them first. Nothing is added to the
project until the user has agreed the order, in phase 3.

## 0. Is the kit current?

`guardrails/INSTALLED.md` says which version of the kit the project has.
Look up the newest, as the kit's `INSTALL.md` says under _Getting the
kit_. Where it is newer, say so, and offer to update first: the update is
done by following `INSTALL.md` at the newer version, under _Updating_,
with its diff shown and nothing written without the user's yes. Where the
user would rather not, carry on with the kit as it is.

## 1. Read what is there

- The project file, `AGENTS.md`, and any other instruction file beside it
  that holds more than a pointer to it.
- The code: what the thing is, where its logic is, and where it is
  presented. The build and package files, the test runner and its config,
  the tests, any hook, any CI, and each script that measures anything.
- The last month of the git history, for what has broken and what changed
  most.

## 2. The project file

`AGENTS.md` has the headings `GUARDRAILS.md` lists under _The project's
file_. Where the install wrote the template, every heading is in square
brackets still. Write each from what the code does, not from what it is
meant to do, and say in the file that it was written, on what date, and
from which commit.

- A heading the project has nothing for stays, and says so. A command
  that does not exist yet, such as a quick check, is written as "none
  yet" and goes under _What is not held_.
- What is missing is said to be missing under _What is not held_, so that
  a green check is not read as more than it holds.
- Where another instruction file beside it holds the project's
  instructions, a harness that reads that file and not `AGENTS.md` never
  sees the kit at all. Put that to the user first, before the survey, as
  the first decision: the least that fixes it is one line, `@AGENTS.md`,
  added at the top of the other file. Moving the instructions into
  `AGENTS.md`, and the other file becoming that one line, is a second
  recommendation, made apart from the first. Neither is done without the
  user's yes.
- Where that other file is long, the headings here say where in it to
  look, and copy nothing: a thing said twice is soon said two ways.
- Keep it to two hundred lines or so. What was tried goes in the commit; a
  figure stays in the file a tool holds it in.

### How a change lands

Where the project file has no answers under _How a change lands_, ask the
two questions at the end of `GUARDRAILS.md`'s _Landing a change_, as they
are written there, each with its recommendation, and write the answers
in. A grant to act without asking is written with who gave it and the
date.

## 3. Survey, then stop

Go through every file in `guardrails/checks/`, in the order of the table in
`GUARDRAILS.md`, and for each say one of:

- **held:** where, by what command, and whether it has been seen to fail
  what it is for. One never seen failing is _held, untested_.
- **partly:** what it holds and what it does not.
- **held, needs work:** it is there, and falls short of the check's file
  or the rules, such as a quick check that takes longer than half a
  minute.
- **missing.**
- **cannot apply:** why, and what stands in, from the check's own
  _Where it cannot apply_.

A rule held only by words, in the project file or elsewhere, and by no
tool, is _missing_: words are what the check is there to replace.

Where nothing records a check failing a fault put in on purpose, it was
never seen to fail, and is _untested_: a project that has every check will
mostly come out that way, and its plan is mostly proving, not adding.

A project of several kinds, such as a monorepo of a package, a CLI and a
site, is surveyed a part at a time, each by its own kind.

Before timing anything, look at how busy the machine is. Figures taken
while it is at other work are marked so in the table, and decide nothing:
a check that fails on a busy machine is run again on a quiet one before it
is called a fault.

Show the user a table of it, with the order you would add the missing ones
in and why, and what each will add to the full check in seconds: measured, for a
check that is there and could be run, and an estimate called one for the
rest.

The order is usually the table's. The quick check and its hook come first,
with the formatter and lint in it, since every later check lands through
it; then the structure rules, unit tests and the seeded source, the test
API, the invariants, the fuzzer, and the rest. Verification comes once
there is a full check to run, and somewhere other than this machine to run
it. A project with a known fault takes the check that would have caught it
early.

Write the order as a plan in a file the project file points to: one box a
check, the check that proves each beside it. Then stop, and wait for the
user to agree it or change it. Where the harness has a plan mode, the
survey and the plan are made in it, and its approval is the agreement.

## 4. Add one check at a time

For each box, in order:

1. **The smallest form** the check's file gives, in the project's own
   language and tools. Its working parts get unit tests of their own: a
   bug in a tool does not throw, it gives a wrong number.
2. **Seen failing.** Put in the fault the check's _Seen failing_ names, on
   purpose. Watch the check catch it, with the output kept for the report.
   Take the fault out and watch it pass. A check that was not seen to
   fail is not ticked.
3. **Named.** The project file gains its command under _Commands_, its
   figures' home under _Gates_, and loses its line under _What is not
   held_. The full check runs it.
4. **Green.** The quick check passes, and the full check as it now stands.
5. **Ticked** in the plan.

A gate's baseline is written on a quiet machine, twice, and only where the
two agree, with the wobble measured and written beside the tolerance. On a
busy machine the gate is added and its baseline left for a quiet one, and
the report says so.

## 5. The hook

The quick check runs before every commit.

- **The kit's hook:** where the project had none, the install left
  `.githooks/pre-commit`, which refuses every commit until its
  `QUICK_CHECK` is set. Set it to the project's quick check.
- **The project's own hook:** where it had one, it is left, and read: it
  should run the quick check and nothing slower.

Git is pointed at the hook's folder by the project's own install step
(`git config core.hooksPath .githooks`), so that a clone has the hook
without being told. A project with no install step says the command under
_Commands_, as a thing to run once. Changing git's config in the user's
checkout is put to them first.

Then put a fault in, try to commit it, and see the hook refuse it. Take
the fault out again: nothing is committed by the trial.

## 6. Report

- **Outcome:** which checks the project now has, as a table, held, partly,
  missing or cannot apply, against where it started.
- **Seen failing:** for each check added, the fault put in and the output
  that caught it.
- **The project file:** what was written, and what is under _What is not
  held_.
- **Figures:** what each new gate holds, its tolerance and the wobble it
  was set from, and what the full check now costs in seconds.
- **Not verified:** anything that could not be checked here, said plainly.
- **Uncommitted:** nothing is committed until asked.
