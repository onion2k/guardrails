# Plan: a portable guardrails kit

Written 2026-10-17 from the artshape game template (its `CLAUDE.md`,
`.claude/skills/{feature,bug,gate-moved,commit}`, `src/invariants.ts`,
`scripts/fuzzer.ts`, `src/debug.ts`) and the house rules in
`~/.claude/CLAUDE.md`. Nothing is built until the user says go.

## Aim

A repo of plain files that any project can take in. It gives an agent, in
any harness and on any model, the same dev loop the games have: the checks
a project stacks up, the definition of done, and the skills that work
through them. It is written for Claude first, but nothing in it needs
Claude in order to work.

Done looks like this: the kit installs into a project that has no
guardrails, and an agent that reads it can take the project up the checks
one at a time, each check seen failing before it is trusted, without
anything from `~/.claude`. The kit's own tests are green. Trying it in
other harnesses is the user's, after it lands.

The repo is `~/projects/guardrails`, with the public remote
`https://github.com/onion2k/guardrails.git`. Everything is written in the
house voice.

## How it stays portable

These are guesses from secondary sources and get checked in part 0:

- **Instructions go in `AGENTS.md`.** Codex, Copilot, Cursor, Gemini CLI,
  Aider and others read it natively. Claude Code reads `CLAUDE.md`, so the
  kit ships a `CLAUDE.md` whose only line is `@AGENTS.md`. That works
  whether or not Claude Code also reads `AGENTS.md` itself.
- **Skills use the Agent Skills format** (`SKILL.md` with `name` and
  `description` frontmatter, as at agentskills.io). Each harness looks for
  them in its own place (`.claude/skills`, `.agents/skills`, and others),
  so the installer puts them where each harness looks.
- **Nothing names a harness's own tools.** No `EnterPlanMode`,
  `AskUserQuestion` or `Agent`. A skill says "if the harness has a plan
  mode, write the spec there". A model is named by the work it does
  (planning versus building), never by product.
- **Enforcement lives in git and the project's own scripts.** That means a
  pre-commit hook and `check` / `check:quick`, not harness hooks, so the
  guardrail holds whoever makes the commit.

## Layout

    README.md              what it is, how to install and update it
    GUARDRAILS.md          the rules: structure, verifying, the definition of done (~200 lines)
    checks/                one file per check, each saying what it protects, its smallest
                           form, how to see it fail, and what stands in where it can't apply
      quick-check.md       format, types, lint and unit tests, plus the pre-commit hook
      unit.md
      test-api.md          a way to set up a scene, step time and read state back, and the e2e test on it
      invariants.md        the rules that must always hold
      fuzzer.md            random actions a user could take, invariants checked, seed replay
      determinism.md       same seed twice, hashed
      gates.md             budgets and baselines held both ways, measured wobble, tolerance
      persisted-shapes.md  a corpus of every saved or exported shape, so old ones still load
      bounded.md           what is kept has a ceiling, watched over a long run
      look.md              pictures held, looked at; a phone's width and a desk's
      mutation.md          put the bug back and watch the test fail
    templates/
      AGENTS.md            the project file: Commands, Layout, Test API, Model features,
                           Edge cases, Gates, What is not held, Who uses it
      CLAUDE.md            @AGENTS.md
      pre-commit           runs the quick check
    skills/
      guardrails/          checks a repo against checks/ and adds missing ones one at a time
      feature/             spec, tests first, build, the pass, report
      bug/                 reproduce as a failing test, invariant, fix the cause, verify
      gate-moved/          is the swing real, was it meant, then the baseline
      commit/              the house commit style
    install.sh             copies the kit into a target repo; see part 5
    tests/                 the kit's own checks; see part 6
    VERSION

## What part 0 changed

Checked 2026-10-17, sources in the README.

- **Claude Code** reads `AGENTS.md` only where no `CLAUDE.md` is found.
  A `CLAUDE.md` of `@AGENTS.md` is its documented way to work in every
  session. **Gemini CLI** reads `GEMINI.md` and expands `@` imports, so it
  gets a one-line `GEMINI.md` too. **Codex** and **Cursor** read
  `AGENTS.md` and expand no imports, so `AGENTS.md` tells them in words to
  read the rules.
- **Skills** go in `.agents/skills/` (Codex, Gemini CLI, Cursor) and
  `.claude/skills/` (Claude Code), as copies. Frontmatter is `name` and
  `description` only, the name the same as the folder.
- **What a project gets** is in two parts. The kit's own files
  (`GUARDRAILS.md`, `checks/`, `VERSION`) go in a `guardrails/` folder the
  installer owns and replaces. The project's files (`AGENTS.md`,
  `CLAUDE.md`, `GEMINI.md`, the hook) are written once, never over one
  already there, and are the project's from then on. `GUARDRAILS.md`
  carries the project file's headings itself, so it stands alone, and a
  test holds the template to them.

## Out of scope

- Moving the six games, the template and `~/.claude` over to the kit. That
  is a follow-up, one project at a time, once the kit has a version.
- Code libraries for fuzzing, gates and so on. The kit is instructions and
  file templates, and each project writes its checks in its own language.
- Harness-specific hooks, settings and permissions.
- Pushing to the remote. That waits until the user asks.
- Trying the kit in other harnesses. The user does that.

## Parts

- [x] **0. Check the assumptions.** Read the current docs for Claude Code,
      Codex CLI, Gemini CLI and Cursor: which
      instruction files each reads, whether `@file` imports work, and where
      each looks for skills. Write the answers into `README.md` with their
      sources and the date. *Check:* each claim has an official source. If
      a claim is wrong, the plan changes before part 1.
- [x] **1. `GUARDRAILS.md`.** Take the house rules and the definition of
      done, drop what is only about games or only about this machine, and
      replace game words with general ones ("the thing", "a user", "a saved
      shape"). *Check:* every rule in `~/.claude/CLAUDE.md` is either in it
      or listed in the README as left out on purpose, with the reason.
- [x] **2. `checks/`.** One file per check, from how the template does it,
      each with a short TypeScript example and a line on what stands in for
      a package, a site, a service and a CLI. *Check:* every gate in the
      template's `package.json` maps to a file here.
- [x] **3. `templates/`.** Write `AGENTS.md` from the `/project-file`
      headings, plus `CLAUDE.md` and the pre-commit hook. *Check:* the
      template's own `CLAUDE.md` fits these headings with nothing left over.
- [x] **4. `skills/`.** Make `/feature`, `/bug`, `/gate-moved` and
      `/commit` generic: commands, paths and seed ranges are read from the
      project's `AGENTS.md`, never written into the skill. Write the new
      `/guardrails` skill. *Check:* no skill names a command, path or
      harness tool. A test greps for these (part 6).
- [x] **5. `install.sh`.** `install.sh <repo> [--harness claude,codex,...]`.
      It never overwrites an existing `AGENTS.md` or `CLAUDE.md`: where one
      exists, it prints the lines to add instead. Skills are copied, not
      symlinked, so a clone works by itself. It writes `.guardrails-version`,
      and running it again with a newer kit shows a diff before writing.
      *Check:* the tests in part 6.
- [x] **6. The kit's own tests.** These cover four things. Every `SKILL.md`
      has valid frontmatter. No file names a harness-only tool. Every
      `checks/` file has the four sections. The installer, on a fixture
      repo, runs the same each time it runs, never overwrites, and updates
      by diff. Each test is seen failing on a fault put there on purpose.
      *Check:* `./tests/run` is green, and each test is mutation-checked.
- [x] **7. Trial in Claude Code.** Install into throwaway copies, never a
      real checkout, of one game (ooergolf) and one non-game (sysmod), and
      run `/guardrails` in each. *Check:* the report says which checks the
      agent reached, what it got wrong, and what the kit changed because of
      it. Whatever could not be tried is said plainly.

## Decided

- **Name and place:** `~/projects/guardrails`, remote
  `https://github.com/onion2k/guardrails.git` (public).
- **Voice:** the house voice throughout, `checks/` included.
- **Other harnesses:** the user tries them. Part 0 still reads their docs,
  so that the files are written to work in them.

## What the trial found

Run 2026-10-17 by an agent on the cheaper model in each copy, phases 1 to
3 of the guardrails skill, cloned from ooergolf at `dcb764c` and sysmod at
`8b2d554`. The machine's load was 27 to 35 throughout, so no figure either
agent took is relied on.

Changed because of it:

- **A project's own `CLAUDE.md` hid the kit from Claude Code** in both.
  The skill now puts the one-line `@AGENTS.md` to the user first, apart
  from moving the instructions, and `AGENTS.md` points into a long file
  rather than copying it.
- **The kit's markdown failed ooergolf's prettier check,** which would
  have stopped every commit. The kit is now formatted as prettier formats
  it by default, a test holds it so, and the installer tells a project
  with a formatter to leave the kit's files alone.
- **A project that already has its checks** came out "held" with no way
  to say a check falls short or was never seen to fail. The survey now has
  _held, needs work_ and _untested_, measured seconds for what is there,
  and a warning against timing on a busy machine.
- **A monorepo of several kinds** (sysmod is a package, a CLI and a site)
  is surveyed a part at a time. A thing with no chance in it is held to
  the same input giving the same output. A project with its own hook, or
  no install step, is covered in the skill's hook phase. A command that
  does not exist yet is written "none yet".
- **The installer said nothing of a hook it left alone;** it now does.

Not changed, and put to the user:

- **sysmod already has a `guardrails` agent** (`.claude/agents/guardrails.md`,
  a reviewer). The kit's skill and folder share its name.
- **The check files' examples are a game's** (`newGame`, a ball, a bank).
  Each has a line a kind for what stands in, and the sysmod agent managed
  with it, though it said it had to guess. Examples for other kinds would
  make each file longer.

Found in the projects, and theirs to look into, not the kit's:

- **ooergolf's quick check took 145 s** against the half minute the rules
  ask, on the busy machine. `test/field.test.ts` and
  `test/golf-hash.test.ts` failed twice on a clean clone; that may be the
  load, or a fault. `src/game.ts:311` falls back to `Math.random`.
- **sysmod has no formatter, no lint and no hook,** and its build warns of
  two chunks over 500 kB with nothing failing on it.


---

# Plan 2: drop the installer

Written 2026-10-17, on `e9f257c`. Nothing is built until the user says go.

## Aim

`install.sh` is bash, and Windows has no bash outside Git Bash or WSL. The
user chose to drop it, and let the agent put the kit in. Every harness can
read and copy files on every system, so the kit then asks nothing of the
machine but git.

The installer's guarantees are kept, as instructions an agent follows:
never write over a project's own file, show a newer kit before taking it
in, and never write over a hand edit. What changes is how each is proved:
the installer's tests held them in code, and nothing can hold an agent to
them in code. The trial does that instead.

## Design

- **`INSTALL.md` at the kit's root is the installer.** It is written for
  an agent, and a user starts it by telling their agent: "follow
  https://github.com/onion2k/guardrails/blob/main/INSTALL.md". That has
  to be a file, not a skill, because before the kit is in, the project has
  no skills to run.
- **The agent gets the kit with git:** `git clone --depth 1 --branch
  <tag>` into a temporary folder, then deletes it afterwards. Git is the
  one tool the kit already assumes, because of the hook.
- **Releases are git tags** (`v0.1.0` and up), and `guardrails/VERSION`
  says which tag a project has. That stands in for the manifest, and needs
  no checksum tool:
  - **hand edits:** the project's kit files are compared with the kit at
    the installed tag. Any difference is a hand edit, and stops the
    update, named.
  - **the update:** the kit at the installed tag is compared with the kit
    at the new tag. The agent shows that diff, and takes it in only on the
    user's yes.
- **The layout does not change:** `guardrails/`, `.agents/skills/`,
  `.claude/skills/`, and the templates written once, where none is there.
  `guardrails/MANIFEST` goes.
- **Updating is phase 0 of the `guardrails` skill,** which reads
  `guardrails/VERSION` and follows `INSTALL.md`'s update steps.
- **The kit's own tests stay bash.** Only whoever changes the kit runs
  them; a project that installs it never does.

## Out of scope

- A Windows run of anything: there is no Windows machine here. What
  stands in is that nothing a project runs needs more than git.
- Moving the two trial clones over. They are throwaway.

## Parts

- [x] **1. `INSTALL.md`.** Install and update, step by step, for an
      agent, covering everything `install.sh` did: the harness choice,
      folders the project already has, the advice it printed (the
      `@AGENTS.md` line, the missing headings, the formatter, the hook),
      and the refusals, each by name. *Check:* a test holds the file to
      naming every path the kit writes, every refusal and every harness,
      and to naming no harness-only tool. Each part of the test is seen
      failing first.
- [x] **2. Tag `v0.1.0`.** It points at the first commit that has
      `INSTALL.md` in it. *Check:* `git ls-remote --tags` shows it.
      Pushing the tag waits for the user to say so.
- [x] **3. Take the installer out.** Remove `install.sh`,
      `tests/test_install.sh` and the manifest, and rewrite the README's
      _Installing_ section, `AGENTS.md`'s layout and edge cases, and the
      skill's phase 5 to match. Add phase 0 (updating) to the skill.
      *Check:* `tests/run` is green, and nothing in the kit names
      `install.sh` or `MANIFEST`, which a test holds.
- [x] **4. Trial, three ways,** each by an agent on the cheaper model,
      each in a fresh throwaway clone, each following `INSTALL.md` from
      the local kit:
      - a fresh install into sysmod
      - an install into ooergolf, whose own files and skills must come
        through untouched
      - an update from a tag a version older, with a hand edit put into
        one installed check on purpose
      *Check:* each clone's `git status` and diff, read here, against
      what `INSTALL.md` says should happen: nothing of the project's
      written over, the edit named, the diff shown before anything is
      written.

## Decided, and changed while building

- **Tags:** plain semver, `v0.1.0` first. Pushing a tag waits for the
  user.
- **The tag comes after part 3,** so that `v0.1.0` is a kit with no
  `install.sh` in it. It is still the first commit with `INSTALL.md` in
  it.
- **`guardrails/VERSION` became `guardrails/INSTALLED.md`.** Without the
  manifest, nothing told a skill folder the kit wrote from one of the
  project's own with the same name. The file records the tag, the
  harnesses, and which skill folders are the kit's and which the
  project's. The kit keeps no `VERSION` file: the tag says it once.

## What plan 2's trial found

Run 2026-10-17 by three agents on the cheaper model, each following
`INSTALL.md` in a throwaway clone, against a throwaway kit with `v0.1.0`
and a `v0.1.1` that changed one rule and one skill. Each clone was then
checked here, byte for byte, against the kit.

- **The three promises held.** In ooergolf no tracked file changed: its
  own `CLAUDE.md`, hook and four same-named skills came through, and
  everything the kit wrote matched the kit. In sysmod the fresh install
  matched. In the update, the hand edit to `guardrails/checks/fuzzer.md`
  stopped it, named, with its diff; once the edit was taken out, the
  `v0.1.0` to `v0.1.1` diff was shown, written on the yes, and the clone
  matched `v0.1.1` exactly.
- **What the agents had to guess, now said in `INSTALL.md`:** how to pick
  the newest tag from `ls-remote` (versions, not text; pass over `^{}`);
  `--depth` with a local copy; when the temporary folder goes; checking
  the copy before it goes (one agent never did); that each skills folder
  is decided by itself; what the record's two lists hold and how an empty
  one is written; that the newer kit's `INSTALL.md` is followed for an
  update; how a recorded folder maps to the kit's `skills/`; that the
  record is never compared; that the templates' changes are shown before
  the yes; that putting back a hand edit needs the user's word; that
  _Before anything_ holds for an update; how a formatter is found, and
  that only the user edits its ignore file; reading a hook the project
  had; and one report, the pointer line first.

A fourth agent then followed the changed `INSTALL.md` into a fresh
ooergolf clone. It checked its copy, led its one report with the
`@AGENTS.md` line, read the project's own hook and named what it runs,
and its clone matched the kit byte for byte with no tracked file changed.
What it still had to guess was the order of the record's lists and which
paths to give the formatter's ignore file; the second is now said.

Part 2's tag is on `42fe0b2`, which has the untrialled `INSTALL.md`. It
is not pushed, so it can be moved to the commit with these changes
without anyone having seen it; that is the user's call.


---

# Plan 3: standards held by checks, not only said

Written 2026-10-17, on `523d208` (`v0.1.0`). Nothing is built until the
user says go.

## Aim

The kit says how code is written (Structure and Style in
`GUARDRAILS.md`) but holds only tests to a gate. A standard that nothing
enforces is advice, and it drifts: ooergolf's rules say chance comes from
one source, `src/game.ts:311` falls back to `Math.random`, and no lint
rule says so. This plan gives formatting, linting, structure and
verification a check file each, so the `guardrails` skill surveys them
and a project is taken up them like the rest, each seen failing.

Done looks like this: four new check files, in the same four sections as
the rest. `quick-check.md` and `GUARDRAILS.md` point at them and do not
repeat them. The kit's tests are green. A trial shows the `guardrails`
skill surveying the new checks on a real project and finding what they
are for. Released as `v0.2.0`, an update from `v0.1.0` that the trial
also tries.

## The new checks

Each has the four sections every check has: _What it holds_, _Its
smallest form_ (a TypeScript example, as the others have), _Seen failing_,
and _Where it cannot apply_. Each names what stands in for Python, Rust
and Go too, since these checks are where languages differ most. The tool
names in the examples are looked up when they are written, not recalled:
that each exists, is current, and does what is said.

- **`checks/formatting.md`.** One formatter decides everything, and is
  never argued with. It is run as a check in the hook, and as a write by
  hand, never by the hook. It leaves generated, vendored and kit files
  alone through its ignore file (`guardrails/` among them: the kit's own
  trial found that one). _Seen failing:_ a file put out of format fails
  the hook. _Stands in:_ ruff format or black, rustfmt, gofmt.
- **`checks/lint.md`.** Lint is for mistakes, not style; the formatter has
  style. The type-aware rules are turned on: a promise not awaited, an
  unsafe `any`, a condition that is always true. The rules the project
  states that a linter can hold are held by it: no global random in the
  thing's code, no `console` left in, nothing disabled without a comment
  saying why. A rule is added with a planted violation that it is seen to
  fail. _Stands in:_ ruff and mypy or pyright, clippy, golangci-lint.
- **`checks/structure.md`.** The structure rules held by a tool that reads
  imports: the thing does not import its picture, lower modules do not
  import content, one place wires everything, and nothing imports in a
  circle. Each rule is a line in the tool's config with the reason beside
  it, and is seen to fail on a planted import. It runs in the quick check
  where it is fast enough, otherwise in the full check. _Stands in:_
  import-linter, cargo's crate boundaries, Go's `internal/`.
- **`checks/verification.md`.** What a check must reach to be believed:
  the built thing and not the dev server, the code as changed (no stale
  build, cached bytecode or pin not installed), a count of what it
  reached, so that one that found nothing fails, and the full check run
  somewhere other than the author's machine, on every push to main. It
  gathers what `GUARDRAILS.md`'s Verifying section says into one check a
  project can be surveyed against. _Seen failing:_ a stale build served
  to the end-to-end test is caught; a test file that matches no tests
  fails the run; CI fails on a red gate. _Stands in:_ any CI; for a
  project with none, a second machine or a clean clone, said under _What
  is not held_.

## What else changes

- **`checks/quick-check.md`** says what runs before a commit and in what
  order, pointing at `formatting.md` and `lint.md` for what each holds,
  and no longer says it itself. Its _Seen failing_ keeps the hook's own
  case: a commit refused through `git commit`.
- **`GUARDRAILS.md`:** the table gains the four rows, in the order a
  project takes them on: quick check, formatting, lint, structure, unit,
  and so on, with verification last but one, before mutation. In Style,
  the formatting and lint line, and in Structure, the rules
  `structure.md` holds, each point to their check, so a rule is said in
  one place and held in another. Verifying keeps its rules and gains a
  line pointing to `verification.md` for how a project is held to them.
- **`skills/guardrails/SKILL.md`:** the survey's usual order names the
  new checks: formatting and lint with the quick check, structure after
  unit tests, verification once there is a full check to run.
- **`templates/AGENTS.md`:** under _Commands_, a line for the formatter's
  write and one for CI, where there is one.
- **`README.md`:** the releases table gains `v0.2.0`, and the layout
  listing is checked.

## Out of scope

- Writing any project's lint, formatter, structure or CI config. That is
  the `guardrails` skill's, in the project, one check at a time.
- Naming conventions and other matters of taste beyond what Style says.
  They belong in a project's own `AGENTS.md`.
- Security and dependency checks (audit, secrets, licences). They are
  worth a check each, and a plan of their own.

## Parts

- [x] **1. Tests first.** These cover four things:
      - `quick-check.md` links to `formatting.md` and `lint.md`.
      - `GUARDRAILS.md`'s Style section links to `formatting.md` and
        `lint.md`, its Structure section to `structure.md`, and its
        Verifying section to `verification.md`.
      - `quick-check.md` no longer names a formatter's or a linter's rules
        itself: no "type-aware" and no "promise". This holds "said once".
      - The table's order is the one above.

      The existing tests already hold each new file to the four sections
      and to being in the table, and to naming no harness. *Check:* each
      new test is seen failing against the kit as it stands.
- [x] **2. Look up the tools.** For each tool the examples name, its
      current docs: that it exists, its current major version, and the
      config shown. Each is noted in the file it is used in, with the date.
      *Check:* each name in the four files has a source in the commit
      message.
- [x] **3. The four check files,** and `quick-check.md` cut down.
      *Check:* `tests/run` green, the format test included.
- [x] **4. `GUARDRAILS.md`, the skill, the template, the README.** *Check:*
      `tests/run` green, every new test mutation-checked.
- [x] **5. Trial, two ways,** by agents on the cheaper model, in
      throwaway clones, against a throwaway kit tagged `v0.2.0`:
      - In ooergolf, the `guardrails` skill's phases 1 to 3. The survey
        should find lint _held, needs work_ for the `Math.random`
        fallback. It should report on structure and verification, and give
        each new check a status the agent can back with a file and line.
      - In a sysmod clone with `v0.1.0` installed, an update to `v0.2.0`.
        The diff should show the four new checks as added and
        `quick-check.md` as changed, with the project's own files
        untouched.

      *Check:* each clone read here against what the files say should
      happen; what the agents had to guess is fixed and recorded.
- [x] **6. Release.** A commit, and the tag `v0.2.0` on it, both only on
      the user's word, and pushed only on the user's word.

## Open for the user

None. The one judgement call, leaving security and dependencies to a plan
of their own, is under _Out of scope_ and can be argued with there.

## What plan 3's trial found

Run 2026-10-17 by two agents on the cheaper model, against a throwaway kit
with the real `v0.1.0` and this work tagged `v0.2.0`; each clone checked
here afterwards.

- **The update held.** A sysmod clone given `v0.1.0` was updated to
  `v0.2.0`: the diff showed the four new checks added, and the rules,
  `quick-check.md` and the guardrails skill changed, and the template's
  two new lines shown and not written. The clone matched `v0.2.0` byte for
  byte, and no tracked file changed.
- **The survey found what the checks are for.** In ooergolf, lint came out
  _partly_: no rule on `Math.random`, so `src/game.ts:311`'s fallback
  stands, and two `console.error` lines in `src/main.ts` (214, 601) that
  `no-console` would ask a reason of. Structure came out _missing_: its
  rules are words in `CLAUDE.md` only. Verification came out _partly_:
  no CI, and `playwright.config.ts` starts the dev server, `npx vite`, for
  the end-to-end tests. Formatting came out _held, untested_, with
  `guardrails/` and `.agents/` not yet in `.prettierignore`. Each was
  checked here against the project.
- **Changed because of it:** a default that reaches for the global random
  is the rule broken, not an exception, and an exception is a line with a
  reason; a project on an older ESLint keeps its config's shape; the
  worktree to ignore is wherever the harness keeps them; "one side of a
  package" is for machinery the project wraps, not a renderer used as it
  is (ooergolf imports `artshape-render` in 29 files); type-only imports
  are the project's call, said in the rule; the rules' paths come from the
  project file's _Layout_; end-to-end tests on the dev server fall short;
  the GPU-bound gates are the ones _Gates_ names; the CI example uses
  `lts/*`, not a pinned Node; a rule held only by words is _missing_; and
  in `INSTALL.md`, how a local copy's tags are listed, that a skill in two
  folders is shown once, and when the record's lists are made again.

