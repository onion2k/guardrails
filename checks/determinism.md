# Determinism

The same seed, run twice, giving the same run, checked by a hash at
intervals so a run that parts from itself says where. Everything that holds
the project to a figure rests on it, and nothing else notices when it
breaks: the figures just wander.

## What it holds

That all chance comes from one seeded source handed in, that no state is
left over in a module between runs, and that nothing depends on an order
that is not the same twice: the order of a map's keys, of a sort that is
not stable, of promises racing, or of the wall clock.

The fuzzer's replay, the pace and balance gates, a bug reported with the
seed it happened on: each is only as good as this.

## Its smallest form

    // src/random.ts: chance, from one place
    export function seeded(seed: number): Random {
      let s = (seed * 2654435761 + 1) >>> 0;
      return () => ((s = (s * 1664525 + 1013904223) >>> 0) / 4294967296);
    }

    // scripts/determinism.ts
    export function diverged(seed: number, steps: number, every = 60): number | null {
      const one = run(seed, steps, every);
      const two = run(seed, steps, every);
      const at = one.findIndex((hash, i) => hash !== two[i]);
      return at < 0 ? null : at * every;
    }

The hash covers everything that makes the thing what it is: every
position, every count, the save. A lint rule forbids the language's global
random in the thing's own code, so it cannot creep back.

## Seen failing

A call to the global random is put into the thing, and the check is seen
to report the step it parted at. So is a module-level counter that is not
reset between runs. A hash that leaves something out is caught by a unit
test that changes each part of the state in turn and expects the hash to
move.

## Where it cannot apply

- **A thing with no chance in it** still holds the same input to the
  same output. The check is the same run twice, hashed, with the seed
  left out.
- **A package** that takes chance from its caller is deterministic by
  construction; it is held by a test that the same source gives the same
  result.
- **A site** with nothing random has nothing to hold, and says so. Where
  it shows something chosen, a shuffle or a pick, it is seeded in tests.
- **A service** has the clock, ids and the order requests arrive in. The
  clock and the id source are handed in, and a test sets them.
- **What cannot be made the same** (a GPU's float arithmetic, threads
  racing) is named in the project file, and the gates that rest on it
  allow for it by measured tolerance.
