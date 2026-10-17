---
name: gate-moved
description: Decide what to do when a gate's figure moves from its baseline, a cost, a size, a pace or a picture. Works out whether the swing is real and whether it was meant, and only then writes a new baseline, with the figures and the reason in the commit. Use when the full check fails on a gate's tolerance, or a figure has moved and the user asks whether it matters.
---

# gate-moved

A gate that moved is a question, not a failure: is the swing real, and was
it meant? Answer both before touching the baseline. A baseline updated to
make the check pass holds the project to whatever it happened to do that
day. The project's `AGENTS.md` says where each gate's baseline and
tolerance are kept; `guardrails/checks/gates.md` says how a gate is
built.

## 1. What moved

Which gate, which figure, from what to what, and which way. Quicker is as
much a change as slower: a cost gone down is written into the baseline, so
that giving it back later is seen.

## 2. Is it real?

Noise looks like a swing on few seeds or one run. Before believing it:

- **A figure over seeds** (a pace, a balance, a count a run reaches): run
  more seeds than the check does and compare the medians. A swing that
  holds on the wider run is real.
- **A time** (a frame, a request, a load): run it again with nothing else
  running, warmed up, and take the least of many samples. Where the gate
  times against a reference in the same run, read the relative figure,
  not the milliseconds; and know that a machine with most of its cores at
  other work slows the two unevenly. On a busy machine, time the change
  and its parent commit in turn, and write nothing.
- **A size that does not wobble** (a build that is the same bytes every
  time): a byte is real. Build the change and its parent, and find what
  added it, and whether that is what the change is for.
- **A picture:** look at the three files a failure leaves: the picture it
  was held to, what was drawn, and the difference. A change in the thing
  is a shape; a machine's own drift is scattered pixels. Where a scene
  does drift, draw it many times on pages just started and count the
  pixels that move at each threshold before choosing one, and never
  forgive a share of the picture: a button is a few hundred pixels of a
  million.

If it is not real, the tolerance is wrong. Say why it is set as it is (each
gate's file says, beside it), measure the wobble again, and widen it only
with the new measurement written beside it.

## 3. Was it meant?

Find what in the change touches what the gate measures. If the change was
meant to move it, say by how much it was expected to and whether this is
that. If nothing in the change should have moved it, it is a bug: go to
the bug skill with the gate's figures as the report.

## 4. Then, and only then, the baseline

- Write it again with the command the project file names.
- Look at what was written. A picture is read in full; a figure is checked
  against what phase 2 measured.
- The commit that carries the change carries the new baseline, and its
  message says the figure before and after and why it moved.

## 5. Report

- The figure before and after, and on how many seeds or runs.
- Real or noise, and how that was decided.
- Meant or not, and what in the change moved it.
- What was written, and what the commit will say.
- Nothing is committed until asked.
