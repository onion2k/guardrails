# Gates

A figure held to a budget and a baseline, both ways: how long the thing
takes to load, what a frame or a request costs, how big the download is,
how fast a user gets through it. Without a gate, fast and small are
claimed, not measured, and drift a little with every change until nobody
can say which one did it.

## What it holds

Each figure two ways:

- **a budget:** what the thing may cost at all, whatever it cost before
- **a baseline:** what it cost at the last commit, held both ways, so a
  step toward the budget is noticed as much as a step over it, and quicker
  is as much a change as slower

A figure that does not wobble, such as the size of a build that is the
same bytes every time from the same lockfile, or the count of mutants the
tests let through (see [mutation.md](mutation.md)), is held exactly. One that
does is held to a tolerance wider than its wobble and narrower than what
the gate is there to catch, with the wobble measured and written beside it: how many runs,
warmed up, on what machine, highest over lowest. A figure too small to
take a share of has a slack as well, said beside it.

A gate's judgement (how a figure is compared with its baseline) is apart
from the measuring, with unit tests of its own. Run only whole, a
judgement that lets a change through looks the same as one that passes.

## Its smallest form

    // scripts/judging.ts
    /**
     * Fifteen in a hundred either way. The frame read 0.171 to 0.178 ms over forty
     * runs just booted, 4% highest over lowest, on an M4 Pro with other work running.
     */
    export const TOLERANCE = 0.15;
    export function judge(was: number, now: number): 'slower' | 'faster' | 'within' {
      const change = now / was - 1;
      return change > TOLERANCE ? 'slower' : change < -TOLERANCE ? 'faster' : 'within';
    }

    perf-baseline.json     { "bootMs": 410, "frameMs": 0.175, "bundleBytes": 182311 }

    npm run perf           the figures, held to the budget and the baseline
    npm run perf:update    the baseline written again, for a change meant to move it

Time the work, not the frames: the gap between frames is the screen's
pace. Take the least of many samples for a cost, and the median of many
seeds for a pace. A baseline is written only for a change meant to move
it, only after the swing is shown to be real, and the commit says the
figure before and after and why.

## Seen failing

The judgement's unit tests hand it figures over and under the tolerance,
both ways. Then the thing itself is made slower on purpose, by a little
more than the tolerance, and the gate is seen to fail it; a bench that
let a frame made thirty times slower through had a tolerance nobody had
tried. The baseline is written twice, on a quiet machine, and only where
the two agree.

## Where it cannot apply

- **A package** holds its hot paths against a reference sum timed in the
  same run, so the machine's speed comes out of the figure.
- **A site** holds its load, its download and its slowest interaction,
  headless, in the built site.
- **A service** holds the cost of its busiest request, and its memory at
  rest.
- **A CLI** holds its start-up and its time on a large input.
- **A figure only another machine can measure** (a phone's GPU, a slow
  network) is named in the project file as not held, with what stands in.
