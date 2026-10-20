# Mutation checks

A new test is seen to fail when the bug it is for is put back. Without
this, a test that passes proves only that it passes: it may assert
nothing, read the wrong thing, or never run.

## What it holds

That every test added by a change would have caught what it is there to
catch. It is done by hand, at the end of the change, once for each new
test:

1. Put the bug back: undo the fix, break the feature, or loosen the rule.
2. Run the new test, and see it fail, for the reason it is there.
3. Restore the change, and see it pass.

A test that survives its mutation is made sharper until it does not. Where
a test could not be seen failing before the change existed, as when a
test is written for code already there, this stands in for that.

The same goes for a check: a gate, the fuzzer or an invariant is trusted
once it has been seen to fail what it is for, with a fault put there on
purpose.

Where the project has a mutation testing tool, the suite's survivors are a
gate as well. A survivor is a mutant the tests let through, with the
status Survived or NoCoverage, and the count for each file is held
exactly, as [gates.md](gates.md) holds a figure that does not wobble. The
tool's mutants are generic, an operator flipped or a branch dropped, and
the bug a test was written for is usually not one of them, so the tool
joins the hand check and does not replace it. It finds tests that hold too
little; the hand check finds whether these tests hold what they were
written for. It runs twice:

- **in the pass,** over the files the change touched
- **over the whole suite,** in the full check where it is quick enough,
  else on a schedule the project file names, such as before a release

The tool's work is the count of mutants times the tests that reach each,
and a slow test under a file of many mutants is run once for every one of
them. A world generator of a few hundred mutants, tested by building whole
worlds at a second or two each, is a run of a day, and the tool reports it
as thousands of tests before it starts. The run is sized before it is
started, and bounded after:

- **Read the dry run before the mutants.** Stryker runs the suite once
  first and says how many tests it ran, in how long, and how many mutants
  it made. Those lines multiplied are the ceiling, and the progress
  reporter's estimate in the first minute is the figure. A run that would
  take longer than the budget is stopped, not waited on.
- **The budget is in the project file,** beside the command: the
  per-change run inside the pass, a minute or so a file, and the whole
  suite inside the full check, ten minutes or so, else on the schedule the
  project file names. A run that grew is made quick before it is given up,
  as any check is.
- **A test under mutation is quick.** `coverageAnalysis: 'perTest'`, the
  default, runs only the tests that reach a mutant, so what is multiplied
  is the tests of that file, and they are made quick first: a generator is
  tested on the smallest scene that shows the rule, a world of a few cells
  and not the game's, and a slow fixture is built once and read many times.
  A test that cannot be made quick is a fault in the test, and is fixed
  there before the tool is turned down.
- **A file that cannot be brought inside the budget** is left out of
  `mutate` by name, with its reason beside it in the config, and the
  project file says so under _What is not held_: the hand check alone
  holds it. A file left out is a gap the project knows about, and is
  looked at again when its tests are made quick.
- **A Timeout is not a kill.** Stryker counts a mutant that runs past
  `timeoutMS` as killed, so a slow test under a mutant that loops reads as
  a test that caught it. The report's Timeout count is read beside its
  survivors, and a file whose mutants time out is one whose tests are too
  slow, not one whose tests are sharp.

## Its smallest form

In the report, each line says what was changed, the line or the command,
so that a reader could put the bug back themselves:

    Mutation checks
      banks only once:        took out the `banked` flag at src/bank.ts:41, test failed at the second expect, restored
      refuses unknown field:  let the loader accept any key (src/load.ts:17, `return false` to `return true`), test failed, restored

For the tool, Stryker, with its vitest runner, taken in exact:

    npm install --save-dev --save-exact @stryker-mutator/core@10.0.0 @stryker-mutator/vitest-runner@10.0.0

    // stryker.config.mjs: the logic is mutated and not the page. break is the
    // budget, a score the whole suite may not fall under: set below the first
    // run's score, and raised as the baseline comes down.
    export default {
      testRunner: 'vitest',
      mutate: ['src/**/*.ts', '!src/main.ts', '!src/scene.ts', '!src/input.ts'],
      incremental: true,
      reporters: ['clear-text', 'progress', 'json'],
      thresholds: { high: 80, low: 60, break: 50 },
    };

    // scripts/mutation-judge.ts: the judgement, apart from the running, so
    // that its unit tests hand it counts without a Stryker run.
    /** A survivor is a mutant the tests let through. The count is held per file, exactly, both ways. */
    export type Report = { files: Record<string, { mutants: { status: string }[] }> };
    export function survivors(report: Report): Record<string, number> {
      const counts: Record<string, number> = {};
      for (const [file, { mutants }] of Object.entries(report.files)) {
        counts[file] = mutants.filter((m) => m.status === 'Survived' || m.status === 'NoCoverage').length;
      }
      return counts;
    }
    export function judge(was: Record<string, number>, now: Record<string, number>, files = [...new Set([...Object.keys(was), ...Object.keys(now)])]): string[] {
      return files.filter((f) => (was[f] ?? 0) !== (now[f] ?? 0)).map((f) => `${f}: ${was[f] ?? 0} -> ${now[f] ?? 0}`);
    }

    // scripts/mutation-check.ts, run the way the project runs its scripts:
    // reads reports/mutation/mutation.json and mutation-baseline.json, judges
    // the files named as arguments or every file, prints what moved and exits
    // non-zero if anything did. With --update it writes survivors(report) over
    // the baseline from the last run's report instead, so no run is needed.

    mutation-baseline.json     { "src/bank.ts": 2, "src/load.ts": 0 }    committed; reports/ is ignored

    npm run mutate             stryker run, then the judge over every file
    npm run mutate:update      the judge writing the baseline again from the last report, for a change meant to move it

    npx stryker run --force --mutate src/bank.ts,src/load.ts
    npm run mutate:judge -- src/bank.ts src/load.ts

The last two are the per-change run, over the files the change touched,
read from the diff against the parent commit. It reruns only the files
named and keeps the rest of the incremental report, so it is quick; a game
of nine logic files and some seven hundred mutants ran whole in under a
minute and one file in seven seconds, so its whole suite went in the full
check. `--force` retests every mutant of the named files rather than
trusting the incremental diff, which sees changed tests and mutated files
and nothing else. The judge's default takes the files of both the report
and the baseline, so a file that was deleted is noticed. The baseline is
written again only for a change meant to move it, and the commit says the
count before and after and why. A count that fell is as much a change as
one that rose. When a run fails, read the judge's lines first: Stryker's
own output lists every survivor with every test that ran, and is for
after.

## Seen failing

The hand check is itself the failure. What matters is that the mutation is
the bug, and not a nearby one: a test for "banks only once" is mutated by
letting it bank twice, not by breaking banking altogether, which a weaker
test would catch too.

The tool is trusted once the assertions of one test have been taken out on
purpose, so that it runs the code and checks nothing, and the mutants it
killed are seen as survivors in the json report and the judgement fails on
the file. A test added that asserts nothing is not the fault: the other
tests still kill what it covers. The judgement's unit tests hand it counts over, under and equal
to the baseline.

## Where it cannot apply

- **The picture** is not mutated, only the logic the structure rules keep
  apart from it, and the project file says so.
- **A language Stryker does not reach** has mutmut, cargo-mutants or PIT
  for the same figure. Where there is none, the hand check alone stands in,
  and the project file says so under _What is not held_.
- **A suite too slow for the full check,** once its tests are quick and
  the slow files are named, runs whole on a schedule the project file
  names, and the run over the files the change touched stays in the pass.
- **Putting the bug back is not possible** (a fault in a dependency, a race
  that cannot be forced): the report says so, and says what was done
  instead.
- **The kit itself** is bash and has no tool; its tests are checked by
  hand.
