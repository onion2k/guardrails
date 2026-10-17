# The fuzzer

The thing driven at random, from a seed, doing everything a user can make
it do, with the invariants checked after every few steps. Without it the
only bugs found are the ones somebody thought to write a test for.

## What it holds

That no sequence of things a user can do breaks a rule (`invariants.md`)
or throws. It plays the real thing, headless, without its picture, many
seeds at a time.

Only what a user could do. A fuzzer that does what no user can finds bugs
no user will meet, and its failures are argued with instead of fixed. A
new thing a user can do gets an action here, in the same change.

## Its smallest form

    // scripts/fuzzer.ts
    export function fuzz(seed: number, steps: number): FuzzResult {
      // the fuzzer's own chance, apart from the thing's, so what it chooses does not shift what the thing does
      const choose = seeded(seed * 7 + 1);
      const game = newGame(seed);
      const log: string[] = [];
      for (let step = 0; step < steps; step++) {
        const action = pick(ACTIONS, choose);
        log.push(`${step}: ${action.name}`);
        action.do(game, choose);
        game.step(DT);
        const problems = checkInvariants(game);
        if (problems.length) return { seed, step, problems, log: log.slice(-25) };
      }
      return { seed, step: steps, problems: [], log: [] };
    }

    npm run fuzz                       a range of seeds, the project file says which
    npm run fuzz -- --seed 17          one seed again, printing what was done before it broke

A failure prints its seed and the last things done, so it can be played
again exactly and turned into a unit test. The fuzzer counts how often it
did each action and how often each event happened, and fails a run in
which one never did: a fuzzer stuck in a corner passes in silence.

## Seen failing

A bug is put in on purpose, one the fuzzer should find: a count not
decremented, a save field dropped on load. The fuzzer is seen to find it
on a seed, the seed is seen to replay it, and the bug is taken out. The
same seed, run twice, does the same things (`determinism.md`).

## Where it cannot apply

- **A package** fuzzes its public operations in random order with random
  arguments of the right shape: property tests, with the invariants as
  the properties.
- **A site** fuzzes its logic the same way, headless. Clicking a page at
  random is slow, and finds mostly what the logic's fuzzer would.
- **A service** sends random sequences of valid requests through its
  handlers, as different users, against one store.
- **A CLI** runs random valid argument lists over random valid input
  files.
- **Without a seed** there is no replay, and a failure is a story, not a
  test. Seeding comes first (`determinism.md`).
