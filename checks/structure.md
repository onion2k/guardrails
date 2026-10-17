# Structure

What may import what, held by a tool that reads the imports. Without it
the thing comes to import its picture, a low module reaches for content,
and two modules each need the other, one convenient import at a time,
until the thing can no longer be run headless and nobody can say when it
stopped.

## What it holds

The rules of `GUARDRAILS.md`'s Structure that can be read in the imports:

- **The thing does not import its picture:** no module of the logic
  imports the page, the renderer or the sound.
- **Lower modules do not import content,** and nothing imports state from
  a module: what a module needs is handed in.
- **One place wires everything,** and is the only module that imports
  both the thing and its picture.
- **Nothing imports in a circle.**
- **Machinery is reached through its own side.** A package the project
  wraps, machinery it takes in and adapts, has one module that is the
  project's side of it, and nothing else imports it directly. A package
  used as it is, such as a renderer whose types are imported where they
  are needed, is not wrapped, and this rule is not for it.

Which modules are the thing and which its picture is the project file's
_Layout_ to say; the rules' paths are read from it, not from the example
below. An import of types alone does not stop the thing running without
its picture, since types are gone when it runs. Whether the rules count
them is the project's call, and the rule's comment says which.

Each rule is a line in the tool's config, named, with the reason beside
it, so a failure says which rule and why it is there. It runs in the
quick check where it is fast enough, and in the full check where it is
not.

## Its smallest form

    // .dependency-cruiser.cjs: found by name, with no flag needed
    module.exports = {
      forbidden: [
        { name: 'thing-without-picture', severity: 'error',
          comment: 'The thing runs headless, in a test and a script: it does not import the page.',
          from: { path: '^src/(game|arena|invariants)' }, to: { path: '^src/(main|scene)' } },
        { name: 'one-way-to-the-package', severity: 'error',
          comment: 'Only physics.ts imports the physics package; the rest import physics.ts.',
          from: { pathNot: '^src/physics\\.ts$' }, to: { path: 'artshape-physics' } },
        { name: 'no-circular', severity: 'error',
          comment: 'Two modules that need each other are one module, or a third is missing.',
          from: {}, to: { circular: true } },
      ],
    };

    "structure": "depcruise src"

The command fails with as many errors as rules broken. dependency-cruiser
18 (October 2026); eslint-plugin-boundaries does the same inside lint, for
a project that would rather have one tool.

## Seen failing

Each rule is seen to fail on a planted import: the page imported into
the thing, the package imported from a second module, two modules made to
import each other. The import is taken out again. A rule whose paths
match no file holds nothing, so each is seen to match.

## Where it cannot apply

- **Python:** import-linter, its contracts in `.importlinter` (a
  _forbidden_ contract for "the thing does not import the page", a
  _layers_ contract for what sits on what), run by `lint-imports`.
- **Rust:** crates are the boundary. The thing is a crate of its own,
  which does not depend on the crate that draws it, and cargo refuses the
  import.
- **Go:** a package under `internal/` can be imported only from the tree
  its parent roots, and the compiler holds that. Beyond it, golangci-lint's
  import rules.
- **A project of one module** has no structure to hold yet, and says so.
  It gains this check when it gains a second module.
