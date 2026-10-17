# guardrails: working on it

A kit of plain files that gives any project the dev loop it needs to change
safely, in any harness on any model. The README says what it is and how a
project takes it in; this file says how the kit itself is changed. Read
GUARDRAILS.md before changing anything: @GUARDRAILS.md

## Commands

    tests/run              every check the kit has (a few seconds)
    tests/run <word>       only the tests whose name has the word in it

The format test needs prettier, from the PATH or named by `PRETTIER`;
without it the test is skipped, and says so.

There is no build and nothing to install. The tests are bash and the tools
every machine has, so that the kit asks nothing of whoever checks it.

## Layout

- `GUARDRAILS.md` is the rules. `checks/` is one file per check it leans
  on. These two are what a project gets, in a folder of its own named
  `guardrails/`, and are never edited there: a change is made here and
  taken in by installing again.
- `templates/` is what a project gets once and then owns: its project
  file, the one-line files that point each harness at it, and the hook.
- `skills/` is the skills, to the Agent Skills specification, copied into
  each harness's folder by the installer.
- `install.sh` puts the kit into a project. `tests/` holds the kit to what
  is said here.
- `PLAN.md` is the plan the kit is being built to, ticked as it goes.

## Model features

- **A check:** `checks/fuzzer.md` for the shape of a check's file.
- **A skill:** `skills/bug/SKILL.md` for the shape of a skill.
- **A test:** `tests/test_skills.sh`, a function a rule, failing with a
  line saying what and where.

## Test API

`tests/run` sources every `tests/test_*.sh` and runs each `test_*`
function. A test fails by printing why and returning non-zero. `$KIT` is
the kit's root. A test that needs a project makes one under a fresh
`mktemp -d`, and never touches a real checkout.

## Edge cases

For anything new, check what it does:

- **each harness:** Claude Code, Codex, Gemini CLI, Cursor: does it find
  the file or the skill, and does a skill name anything only one has
- **a project with its own files:** an `AGENTS.md`, `CLAUDE.md` or
  `GEMINI.md` already there, a `.claude/skills/` with skills of the same
  name, a hook already in place
- **installing again:** with nothing changed, with a newer kit, and with a
  file in `guardrails/` edited by hand
- **a project that is not a game:** a package, a site, a service, a CLI:
  does the check say what stands in for it
- **a path with a space in it**, and a project that is not a git repo

## Gates

The tests are the kit's only gate, and a count: they hold the kit's
files to their shape, exactly, and have no baseline.

## Done, here

The definition of done's nine points, for the kit: a test in `tests/` for
each new rule a file must keep, seen failing first and mutation-checked;
every file touched read through for what it says and in the house voice;
`tests/run` green. A change to how a project installs the kit is tried on
a throwaway project made under `mktemp -d`.

## What is not held

- **Whether an agent does what the files say.** Only a trial shows that,
  in a throwaway copy of a real project, and trials in harnesses other
  than Claude Code are the user's.
- **What the harnesses do.** Each changes faster than the kit. The README
  says what was checked, against which docs, on what date.
- **The definition of done's performance, look and fuzzer points** have
  nothing here to reach: the kit has no picture, no frame and nothing
  random. A change to the kit is held to its tests, a mutation check of
  each new one, and a read of what changed in every file it touched.
- **The house voice** is held by a reader, not a test.

## Who uses it

Any project that installs it, by copy: nothing pins it. A project says
which version it has in `guardrails/VERSION`.

## Commits

Commit only when asked. A sentence summary in the house voice, and a body
saying what changed and why.
