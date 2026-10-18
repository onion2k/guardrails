# [Name]: working on it

[One line: what the project is, and what it is built with.] The README says
what it is; this file says how it is changed.

Read guardrails/GUARDRAILS.md before changing anything: @guardrails/GUARDRAILS.md

<!--
Written from the guardrails kit's template. Everything in square brackets
is the template's, and is replaced from what the code does, not from what
it is meant to do. A heading the project has nothing for stays, and says
so: the skills look for each one by name. A project adds headings of its
own after these, such as the rules its code keeps beyond the kit's. Keep the file to two hundred
lines or so; what was tried goes in the commit, and a figure stays in the
file a tool holds it in.
-->

## Commands

    [dev command]          [what it serves, and where]
    [quick check]          formatting, types, lint, unit tests (the pre-commit hook; ~N s)
    [full check]           all of it: the quick check, then every gate (~N s)
    [each gate]            [what it holds the project to]
    [format]               the formatter, writing: by hand, never by the hook
    [mutate]               the tests' surviving mutants, per file, held to the baseline under Gates (or: no mutation tool yet)
    [audit]                the dependencies' known advisories, at the threshold under Gates
    [updates]              by hand, monthly, a commit each, the audit first
    sh guardrails/next     where every plan in plans/ stands, and what comes next

[Which command writes each baseline again. Only for a change meant to move
it, and the commit says why.]

## Layout

- [The module that is the thing itself, without its picture: it runs
  headless and tells what happened through its events.]
- [The page or shell that presents it, and holds no logic.]
- [Where content lives. Where the persisted shape is. Where chance comes
  from.]

## Model features

What to copy the shape of, when building something new:

- **Something the user sees:** [a feature, and each file it touches: the
  logic, the picture, the invariants, the test API, the look].
- **A tool:** [a check or gate, its working parts and their tests].
- **Test helpers:** [the seeded constructor tests use, and the store that
  is not the user's].

## Test API

[Where it lives, how a test reaches it, and what it can do: seed, pause,
step, set a scene, read state, events and invariants. How the end-to-end
tests start the built thing, headless, in a fresh context.]

## Edge cases

For anything new, check what it does:

- **[a place or part of the thing]:** [what a new thing can meet there]
- **saved:** saved, loaded again, and loaded from an old shape without the
  field
- **scale:** many at once, at capacity, and what that costs
- **phone:** a narrow screen, and a slower machine
- [the project's own]

## Gates

| Figure   | Budget   | Baseline kept in | Tolerance, and why it is that wide | Held by  |
| -------- | -------- | ---------------- | ---------------------------------- | -------- |
| [figure] | [budget] | [file]           | [the measured wobble, and where]   | [script] |

- **Audit threshold:** [high and critical fail; moderate is reported; an
  exception is written with why, and looked at again within 90 days]
- **Allowed licences:** [MIT, BSD-2-Clause, BSD-3-Clause, ISC, Apache-2.0,
  0BSD, Unlicense; anything else asked about by name]
- **Surviving mutants:** [per file, in mutation-baseline.json, held
  exactly; or: no mutation tool yet, said under What is not held]
- **Accepted findings:** [where the secret scan's and code scanning's
  accepted findings are kept, each with its reason: none yet]

## Done, here

The definition of done's nine points, in this project: [unit tests in ...,
a step in the end-to-end test ..., an action in the fuzzer and a rule in
the invariants ..., a ceiling for anything kept ..., the gates' figures
before and after, a picture in ...]. The pass is [full check] green, and
[the fuzzer over its wider seed range] clean.

## What is not held

- [Each rule in GUARDRAILS.md the project has nothing for, or does not yet
  meet, with what stands in for it.]
- [A mutation tool, where the project has none yet: the hand check alone
  stands in.]
- [What only a person, or another machine, can check.]

## How a change lands

The rules are guardrails/GUARDRAILS.md's _Landing a change_. This
project's answers:

- **Merge style:** [a merge commit]
- **What an agent may do without asking:** [nothing]
- **Stale after:** [30 days]

Whether a change goes straight to the default branch or by PR is the
remote's to say, by protecting the branch or not, and is read from it
each time.

## Who uses it

[For a package: each project that pins it, and what of it each uses. For
anything else: "Nothing pins it."]
