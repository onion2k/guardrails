---
name: bug
description: Fix a bug from a report, a fuzzer seed or something seen in use, reproduction first. Turns the report into a test that fails for the reported reason, adds the rule to the invariants if there is one, fixes the cause and not the check, and verifies it with the fuzzer and a mutation check. Use when the user reports something wrong, or a gate or the fuzzer has failed.
---

# bug

Take a report of something wrong to a fix with a test that would have
caught it. Follow the phases in order. Nothing is fixed before it is
reproduced. The rules are `guardrails/GUARDRAILS.md`'s, and the project's
`AGENTS.md` says where each thing lives and how each check is run.

## 1. Understand

- What was seen, where, and what should have happened instead. If the
  report is short on any of these, say what you are assuming.
- Read the code that owns the behaviour before proposing anything.
- If it came from the fuzzer, play the seed again first, as the project
  file says, and read what was done before it went wrong.
- If it came from a gate, the gate-moved skill decides whether it is a bug
  at all.

## 2. Reproduce, as a test that fails for the right reason

- A unit test, on the thing itself, headless and seeded: the smallest
  setup that shows it. Where the bug is only reachable through the page,
  a step in the end-to-end test through the test API instead.
- Run it and see it fail, and check the failure is the reported thing and
  not a mistake in the test.
- If it cannot be reproduced, stop and say so, with what was tried. A fix
  without a reproduction is a guess, and the report says it is one.

## 3. Is it a rule?

If what went wrong is a state the thing should never be in, whatever the
feature, write it into the invariants before the fix. The fuzzer then
hunts for it from now on, and the test in phase 2 may be as simple as the
rule holding.

## 4. Fix the cause

The smallest change that fixes the cause, in the module that owns it.
Never the check: a rule loosened, a tolerance widened or a test adjusted
to pass is not a fix, and the report must say if that was done and why.

Go through the project file's edge cases for what else the change can
reach, and add a test for each that applies.

## 5. Verify

- The new test passes, and the full check is green.
- The fuzzer over the seeds the project file names for the pass, clean.
- **Mutation check:** take the fix out, see the new test fail, put it
  back.
- If the bug was in something seen, a picture of it fixed, looked at.

## 6. Report

- **Cause:** what was actually wrong, in a sentence or two.
- **Fix:** what changed, and where.
- **The test** that would have caught it, and any rule added.
- **Else affected:** what the change can reach, and what was checked.
- **Not verified:** anything that could not be checked, said plainly.
- **Uncommitted:** nothing is committed until asked.
