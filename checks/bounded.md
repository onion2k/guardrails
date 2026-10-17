# What is kept stays bounded

A long run, watching every list, map, cache and store that is added to, each
held under a ceiling and, where it should settle, held to have stopped
growing. A leak does not throw, break a rule or move a gate. It shows up an
hour in, on somebody else's machine, as a thing slowed to a crawl.

## What it holds

That nothing is kept for ever. Every size the thing can grow has a line
here, and is held two ways:

- **under a ceiling:** what it could ever reasonably be, not a guess at
  what it is now, so tuning does not move it and a leak cannot hide under
  it
- **steady, where marked:** not still climbing by the end, the last third
  of the run against the middle third, so a size that fills early and
  settles is left alone and one that creeps all the way through is not

The run is far longer than the fuzzer's or any test's, because those stop
long before a slow leak shows.

## Its smallest form

    // scripts/leaks.ts
    export const WATCH = {
      bodies:    { ceiling: BODY_CAPACITY, steady: true },
      saveBytes: { ceiling: 64 * 1024,     steady: true },
      heapMB:    { ceiling: 200,           steady: true },
    };
    export function sizes(game: Game) {
      return {
        bodies: game.world.live,
        saveBytes: JSON.stringify(game.progress.save).length,
        heapMB: process.memoryUsage().heapUsed / 2 ** 20,
      };
    }

    npm run leaks          an hour of play, the autopilot or the fuzzer driving
    npm run leaks:check    ten minutes of it, in the full check

A new list, map or cache in the thing gets a line in `WATCH` and a reading
in `sizes`, in the same change.

## Seen failing

A cache that is never emptied is put in on purpose, and the check is seen
to catch it as still climbing, under its ceiling. A size pushed over its
ceiling is seen to fail. A unit test hands the judgement a size that
wanders and settles, and expects it let through.

## Where it cannot apply

- **A package** runs its operations many times in a loop, and holds its
  own caches and the heap.
- **A site** that is read and left has little to hold. One that stays open
  (a dashboard, an editor) is run for an hour headless, with the heap and
  the count of nodes on the page watched.
- **A service** is held over many requests: memory, open handles,
  connections, rows in tables that should be swept.
- **A CLI** that runs once and exits holds its output size and its peak
  memory over a large input instead.
