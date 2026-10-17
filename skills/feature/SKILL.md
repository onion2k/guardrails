---
name: feature
description: Build a feature from a short prompt, confidently, in any project with an AGENTS.md written to the guardrails kit. Turns the prompt into a spec (acceptance criteria, edge cases, performance risk, test plan), gets it agreed, builds it test-first, and verifies it to the definition of done with evidence. Use when the user asks for a new feature or a change to how the thing works or looks.
---

# feature

Take a one-line feature request to a finished, verified feature. Follow the
phases in order. Do not start building until the user has agreed the spec.

The process is `guardrails/GUARDRAILS.md`'s; the nouns are the project's.
Before phase 1, read the project's `AGENTS.md` for its commands, layout,
model features, test API, edge cases, gates and what done means here. If
any of those is missing, say so in the spec, find it from the code, and
offer to write it into `AGENTS.md` as part of the work: the next feature
should not have to look again.

Phases 1 and 2, understanding and the spec, are where the strongest model
to hand counts most: what is built is only as good as what was agreed.
Where the harness has a plan mode, do them in it, write the spec as the
plan, and leave it only when the user has agreed it. The build can pass to
a cheaper model from phase 3 on; where the session cannot change its own
model, say so, and the user makes the switch.

Two kinds of feature come through here, and they are verified differently:
something **the user sees**, and a **tool**, which measures the project or
holds it to something. Phase 4 has a track for each.

## 1. Understand

- Read the relevant code before proposing anything: the module the project
  file names as the thing itself, and whichever modules the feature
  touches.
- Find the nearest existing feature and how it is built, tested and shown.
  Use the model features the project file names: one for things the user
  sees, one for tools.
- Note which of the project file's edge cases the feature can reach.

### Measure first, where the ask has a number in it

If the request names a figure (how long something takes, what a thing
should cost, how often something should happen) find out what that figure
is now, before writing a spec around it. A rough measurement is enough: a
short run, a sum over the content, an existing gate's output. Put it in
the spec.

A target agreed without a measurement is a target nobody knows the cost
of. Where the levers on offer cannot reach it, say so in the spec and give
the user the trade-off, rather than finding it out half way through.

## 2. Spec: show the user, and wait

Write a short spec and show it. Keep it under a screen.

- **What:** the behaviour, in the user's terms.
- **Where it stands now:** the measurements from phase 1, for anything the
  request puts a number on.
- **Acceptance criteria:** numbered, each observable and testable.
- **Edge cases:** go through the project file's list. Say what the feature
  does in each that applies, and write "not reachable" for the rest.
- **Decisions:** only choices that are the user's to make: feel, looks,
  anything with more than one reasonable answer. A recommendation for
  each, and what each would cost, from the measurements. A matter of taste
  is shown, as a mock or a before and after, not described.
- **Performance risk:** what could cost load time, download, or the cost
  of a frame or a request, against the project's budgets, and how it will
  be measured. For a tool, what it adds to the full check.
- **Test plan:**
  - unit tests, headless, on the thing itself
  - the end-to-end step through the test API
  - the fuzzer action, and any new invariant
  - the pictures to take
  - for a tool: the gate, its baseline, and how a change to it is told
    from noise
- **Parts:** a checklist, one box a part in the order they will be built,
  with the check that proves each beside it, kept in a file. A box is
  ticked in phase 3 as its part's tests go green, so where the work stands
  can be read off the file at any time.

Ask the user to agree the spec or change it, and ask only about real
decisions. Nothing is built before the agreement.

## 3. Build test-first

1. Write the acceptance criteria as failing tests.
   - Unit tests where the project file says they go, headless, with the
     seeded helpers the project's tests already use.
   - A step in the end-to-end test through the test API, paused and
     stepped.
   - Run them and see them fail for the right reason.
2. Build the feature. Logic goes in the thing itself, or a module of its
   own that is handed what it needs. The page only presents it, through
   the thing's events. Content goes where the project keeps content.
3. Extend the test API with whatever the tests need to set up or read the
   feature.
4. Add the fuzzer action: only what a user could do. Add any new
   always-true rule to the invariants. Give anything the feature keeps a
   ceiling where the project watches sizes.
5. Make the tests pass, and tick the part's box.

A tool is code like any other: its own working parts get their own unit
tests, not just the end-to-end run. A bug in the middle of a tool does not
throw; it quietly gives a wrong number.

Run only the tests being written and the quick check as you go. The full
check, the fuzzer, the gates and the look are phase 4, once: not after
each step, and not for each part. A build that runs them as it goes can
spend half its time inside them.

## 4. Verify and fix, once, at the end

When the build is complete, run all of it as one pass, and keep the
numbers and file paths for the report. What the pass finds is fixed at its
cause, and the pass is run again until it is clean.

Both kinds:

- **The full check.** If a gate moved, use the gate-moved skill before
  deciding anything. A baseline is written only for an intended change.
- **The fuzzer** over the wider seeds the project file names for the
  pass, clean. A failure prints a replay; fix the cause, never the check.
- **Mutation check.** Break the feature, or put the bug back, see the new
  tests fail, then restore it. A test that survives its mutation proves
  nothing: make it sharper until it fails.

Something the user sees, as well:

- **Performance.** The project's gates run in the pass, the change against
  its parent commit (a worktree of the parent for the before), and the
  cost measured headless in any other scene the feature touches. Over
  budget is not done: the feature gets a cheaper form the thing steps
  down to on a slower machine, or is made cheaper.
- **Look.** Headless pictures of the feature in every scene it appears
  in, at a phone's width and a desk's, and before and after where it
  changes something already there. Read every picture, and tune until it
  looks right.
- **The user's data.** Nothing of theirs is touched; a test's data goes in
  through the test setup, in a fresh context.

A tool, as well:

- **Trust the instrument before its figures.** Watch what it does, on
  several seeds, against behaviour already known to be good, and against
  a fault put there on purpose. A measuring tool that gets stuck, gives up
  early or plays badly reports a number that says more about the tool
  than the project.
- **The same seed gives the same answer**, run again and on another core
  count.
- **Its gate holds both ways**: quicker is as much a change as slower. Say
  what the tolerance is, the wobble it was set from, and why it is that
  wide.
- **What it costs the full check**, in seconds.

## 4a. When the evidence contradicts the spec

Stop and go back to phase 2. Do not tune towards a target the measurements
have just shown to be out of reach, and do not quietly pick a different
one.

Report what was agreed, what the runs show, the options with their
numbers, and a recommendation. Build and land everything that stands
regardless of the answer (the tool, the gate, the tests, the docs) and
leave the choice open. Say plainly in the report and in the commit that it
is still open.

## 5. Report

Lead with the outcome, then the definition of done point by point:

- **Result:** what was built, in one or two sentences.
- **Acceptance criteria:** each one, and the test that proves it.
- **Parts:** which boxes are ticked, and why any is not.
- **Checks:** results with numbers: tests, fuzz seeds and steps, each
  gate, costs before and after.
- **What the numbers show,** for a tool: what it says about the project
  now.
- **Bugs found and fixed** along the way, in the feature and in the tool.
- **Not verified:** anything that could not be checked, said plainly. A
  figure the tool cannot calibrate is not verified, however many runs back
  it.
- **The project file:** anything added to it so the next feature finds
  its nouns.
- **Uncommitted:** nothing is committed until asked.
