# Invariants

The rules that must always be true of the thing, however it got there:
broken, they are a bug whatever the feature was. Without them a bug is
noticed only where someone thought to look for it.

## What it holds

That nothing the thing can do leaves it in a state it should never be in.
Every number is a number. Every count matches what it counts. A total
only ever grows where it should only ever grow. Nothing is in two places,
or in none.

One function reads the thing as it stands and returns each broken rule as
a line saying what and where. The fuzzer calls it after everything it
does, the test API returns it on asking, and the unit tests call it at the
end of a test as a matter of course.

## Its smallest form

    // src/invariants.ts
    export function checkInvariants(game: Game): string[] {
      const out: string[] = [];
      const { bank, banked } = game.progress.save;
      if (!Number.isInteger(bank) || bank < 0) out.push(`the bank is ${bank}`);
      if (banked < bank) out.push(`banked ${banked} in all, with ${bank} in the bank`);
      for (const body of game.bodies())
        if (![body.x, body.y].every(Number.isFinite)) out.push(`${body.kind} ${body.id} is not a number`);
      return out;
    }

It reads; it never changes anything, and it works its answer out from the
state itself, never by asking the code it checks. A rule broken a thousand
times is reported a few times and counted, so the report stays readable.

A bug found that is a state the thing should never be in becomes a rule
here before it is fixed. The fuzzer then hunts for it from that day on.

## Seen failing

Each rule is seen to fire. A unit test puts the thing in the broken state
by hand and expects the line; a rule that cannot be made to fire checks
nothing. When a rule is added, the fuzzer is run with the bug it is for
put back, and is seen to find it.

## Where it cannot apply

- **A package** states its invariants over its own data structures, and
  its tests call them after every operation.
- **A site** has few of its own; what it has are in its data, such as a
  total that sums its lines, or every link resolving.
- **A service** holds them over its store: every order has a customer,
  no balance below zero, every job in exactly one state.
- **A CLI** holds them over what it writes: an output file that parses,
  and a run that leaves nothing half done.
