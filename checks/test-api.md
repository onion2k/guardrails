# The test API and the end-to-end test

A way for a test to set a scene, keep time and read back what happened in
the thing as built, and the end-to-end test that drives the thing through
it as a user does. Without it an end-to-end test waits on clocks, reaches
into the thing's insides, and fails at random.

## What it holds

That the thing works whole, as built and as a user meets it: each control
worked as a user works it, and what the user should see read back.

The API is a narrow door into the running thing, there for tests and for
poking at by hand:

- **set:** seed chance before anything is built, put the thing in a known
  state, load a save that is not the user's
- **time:** pause, and step a fixed number of steps, exactly
- **read:** the state, the events that happened, and the invariants
  (`invariants.md`) on asking

Its types are shared with the tests, so a test that calls something not
there does not compile. Anything that changes the thing goes through it,
and a test never reaches past it.

## Its smallest form

    // src/debug.ts: window.game, for tests and the console
    export interface GameApi {
      seed(n: number): void;
      pause(): void;
      step(frames: number): void;
      state(): GameState;
      events(): GameEvent[];
      invariants(): string[];
    }

    // smoke/play.spec.ts
    test('a ball pushed in is banked, and the bank shows it', async ({ page }) => {
      await start(page, { seed: 3, save: freshSave() });
      await page.evaluate(() => { game.pause(); game.place('ball', 0, 2); });
      await page.keyboard.down('ArrowUp');
      await page.evaluate(() => game.step(90));
      await expect(page.getByText('Bank 1')).toBeVisible();
      expect(await page.evaluate(() => game.invariants())).toEqual([]);
    });

The test presses the key: a call to the thing proves what is behind a
control, not the control. It runs headless, against the built thing, in a
fresh browser context, so the user's own data is never touched.

## Seen failing

The end-to-end step for a change is written before the change, and seen
to fail at the step it is there for. The API's own methods each have a
test that a wrong answer would fail: a `step` that stepped one too few
frames, a `state` that read a stale copy.

## Where it cannot apply

- **A package** has no page. Its public interface is the API, and the
  end-to-end test is a consumer's use of it, built from the published
  shape, not the source.
- **A site** without time to step still seeds what varies, and reads its
  state from the page as a user would, through roles and text, never
  through class names.
- **A service** is driven over its real protocol, against a store the test
  set up, with the clock handed in through a test-only door.
- **A CLI** is run as a process with arguments, input and a fresh folder,
  and its output and exit code read back.
