# Unit tests

The thing's working parts, each tried by itself, headless and seeded.
Without them a fault in the middle of something is found, if at all, by a
slow run end to end that cannot say where it went wrong.

## What it holds

That each part does what it is for, with nothing else in the way: no
renderer, no network, no clock and no chance but the seed the test hands
in. A test sets up the smallest thing that shows a behaviour, does one
thing to it, and reads back what happened.

The tools are code like any other. The fuzzer, the bench and a gate's
judgement each get unit tests of their own working parts: a bug in a tool
does not throw, it quietly gives a wrong number.

## Its smallest form

A helper that builds the thing from a seed, and tests that use it:

    // test/helpers.ts
    export function newGame(seed = 1) {
      return new Game(new Progress(memoryStore()), {}, { random: seeded(seed) });
    }

    // test/bank.test.ts
    it('banks a ball pushed into the hole, and only once', () => {
      const game = newGame();
      game.place('ball', HOLE.x, HOLE.y);
      game.step(1 / 60);
      expect(game.progress.save.bank).toBe(1);
      game.step(1 / 60);
      expect(game.progress.save.bank).toBe(1);
    });

A test's timeout is there to catch one that never ends, not to time the
thing. Set it generously and say why beside it: a timeout of a few seconds
fails at random on a busy or slow machine, and a check that fails
for the machine's reasons is not believed the next time.

## Seen failing

Each new test is seen to fail before the change it tests exists, and for
the reason it is there: the assertion, not an import or a typo. Where it
could not be, the mutation check stands in (`mutation.md`).

## Where it cannot apply

It applies everywhere. What changes is where the thing ends and its
picture begins:

- **A package** is all thing, and its unit tests are most of its checks.
- **A site** puts its logic where it can be called without a page: the
  sums, the rules, the shaping of data. What is left in a component is
  presentation, held by the look and the end-to-end test.
- **A service** tests its handlers with the store and the clock handed in.
- **A CLI** tests the function that does the work, not the process: the
  process is the end-to-end test's.
