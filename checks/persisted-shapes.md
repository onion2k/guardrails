# Persisted shapes

A corpus of every shape the thing has ever written, kept as files, each
still loading and still working. A save outlives the code that wrote it,
and without this the first anyone hears of a broken one is a user who has
lost theirs.

## What it holds

That every save, export, config or message the thing has ever written
still loads, keeps what it held, and plays on without breaking a rule. A
new field has a default where the shape is read; a key, an id or an
address that has been given out is kept, and names a thing by what it is,
not its place in a list.

That a new shape is in the corpus. The last test reads the fields the
thing writes now and fails when one is in no file in the corpus, so a
change to the shape cannot land without its sample.

What comes from outside is read as if anyone had written it: a value of
the wrong type, a field not known, a number out of range is refused by
name, never trusted.

## Its smallest form

    test/saves/01-first.json
    test/saves/02-with-colours.json

    // test/saves.test.ts
    const KEPT = {
      '01-first.json': { bank: 7 },
      '02-with-colours.json': { bank: 3, colour: 'red' },
    };
    for (const file of files) {
      it(`${file} loads, keeps what it held, and plays on`, () => {
        const game = load(read(file));
        for (const [key, was] of Object.entries(KEPT[file])) expect(game.save[key]).toEqual(was);
        game.step(600);
        expect(checkInvariants(game)).toEqual([]);
      });
    }
    it('has a file for every field the thing writes', () => {
      expect(fieldsWritten(newGame())).toEqual(fieldsIn(files));
    });

A file in the corpus is written by the thing as it was, never by hand,
and never edited after: it is a record of what users have.

## Seen failing

A field's default is taken out, and the oldest file is seen to fail. A
field is added to what the thing writes with no sample, and the last test
is seen to fail. A save with a field of the wrong type is seen to be
refused by name.

## Where it cannot apply

- **A package** holds its serialised formats and its public API's shape
  the same way: an old consumer's call, kept as a test, still works.
- **A site** holds what it keeps in the browser and every address it has
  given out: an old link still lands somewhere that makes sense.
- **A service** holds its stored rows through every migration, and every
  version of its API a client may still call.
- **A CLI** holds its config files and its flags: an old script that
  calls it still runs.
- **A thing that keeps nothing** says so in the project file.
