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

## Its smallest form

No tool is needed. In the report:

    Mutation checks
      banks only once:        took out the `banked` flag, test failed at the second expect, restored
      refuses unknown field:  let the loader accept any key, test failed, restored

A mutation testing tool (Stryker, mutmut, cargo-mutants, PIT) can stand
beside it over the whole suite, and is worth running now and then. It
finds tests that hold too little, not whether this change's tests hold
what they were written for: that is the hand check's.

## Seen failing

The check is itself the failure. What matters is that the mutation is the
bug, and not a nearby one: a test for "banks only once" is mutated by
letting it bank twice, not by breaking banking altogether, which a weaker
test would catch too.

## Where it cannot apply

It applies everywhere a test is written. Where putting the bug back is not
possible (a fault in a dependency, a race that cannot be forced), the
report says so, and says what was done instead.
