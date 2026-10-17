# Lint

The mistakes the compiler lets through, and the project's own rules a
linter can read in the code. Without it a promise is dropped on the floor,
a condition can never be false, and a rule the project wrote down is kept
only for as long as somebody remembers it.

## What it holds

Mistakes, not style. The formatter has style ([formatting.md](formatting.md)),
and a lint rule about the look of the code is turned off.

- **The type-aware rules,** which are the point: they read the types, and
  find what plain lint cannot. A promise not awaited or handled, a value
  used through an `any`, a condition that is always true or always false,
  a `switch` that misses a case.
- **The project's rules a linter can hold.** Where a rule in
  `GUARDRAILS.md` or the project file can be read in the code, a lint rule
  holds it, and the rule is no longer only words. Chance from one source
  is "no global random in the thing's code". Nothing left for debugging is
  "no `console`" outside the tools that report. A rule turned off for a
  line says why on that line.
- **A default is not an exception.** A source of chance that falls back to
  the global random when none is handed in is the rule broken, not a
  place to turn it off: the source is made required, and the one place
  that wires everything hands it in. A line the rule must allow (the page
  reporting an error to the console) is turned off on that line, with its
  reason, never for the file.
- **What is linted is this checkout.** Another session's worktree or a
  build's output under the project is ignored by name, wherever the
  project's harness keeps them, or its files fail as errors for a change
  nobody made here.

Each rule has its reason beside it in the config, for whoever wants it
gone.

## Its smallest form

    // eslint.config.js
    import js from '@eslint/js';
    import comments from '@eslint-community/eslint-plugin-eslint-comments/configs';
    import { defineConfig } from 'eslint/config';
    import tseslint from 'typescript-eslint';

    export default defineConfig(
      // dist is the build's; the second is where other sessions keep their worktrees, under this one.
      { ignores: ['dist', 'worktrees'] },
      {
        files: ['**/*.ts'],
        extends: [js.configs.recommended, tseslint.configs.recommendedTypeChecked],
        languageOptions: { parserOptions: { projectService: true } },
      },
      comments.recommended,
      {
        files: ['src/**/*.ts'],
        rules: {
          // Chance comes from one seeded source, handed in: the replays and every gate rest on it.
          'no-restricted-properties': ['error', { object: 'Math', property: 'random',
            message: 'Take chance from the seeded source handed in.' }],
          // The thing reports through its events; a console line is debugging left in.
          'no-console': 'error',
          // A rule turned off says why, on the line.
          '@eslint-community/eslint-comments/require-description': 'error',
        },
      },
    );

ESLint 10 and typescript-eslint 8 (October 2026). A project on an older
major keeps its config's shape (`tseslint.config(...)` in place of
`defineConfig`): the rules are what this check holds, not the shape, and
upgrading is a change of its own. A project that wants more takes
`strictTypeChecked` in place of `recommendedTypeChecked`, and says so.

## Seen failing

Each rule the project adds is seen to fail on a planted violation, with
the violation taken out again: a `Math.random()` in the thing's code, a
`console.log`, a promise left floating, a disable comment with no reason.
A rule that cannot be made to fire holds nothing. The ignore of another
worktree is seen to work by making one and linting.

## Where it cannot apply

It applies to every project; only the tool changes.

- **Python:** `ruff check` for lint, and mypy or pyright for the types,
  which is where Python's type-aware checking lives.
- **Rust:** `cargo clippy -- -D warnings`.
- **Go:** golangci-lint, version 2, its config beginning `version: "2"`.
- **A language with no type-aware linter** says so under _What is not
  held_, and leans harder on its unit tests.
