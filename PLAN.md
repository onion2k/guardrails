# Plan: a portable guardrails kit

State: landed on main at e9f257c, 2026-10-17.

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

State: landed on main at 523d208, 2026-10-17.

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

State: landed on main at be53bd2, 2026-10-17.

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


---

# Plan 4: how a change lands

State: landed on main at f822e64, 2026-10-17.

Written 2026-10-17, on `be53bd2` (`v0.2.0`). Nothing is built until the
user says go.

## Aim

The kit governs a change from spec to green, and stops at "lands on
main" without saying what landing is. This plan says it, the same in every
project: committing, pushing, branching, PRs, merging, releasing and
clearing up. A project's own choices are kept in its `AGENTS.md`, asked
for at install. It also lets the user's personal `~/.claude/CLAUDE.md`
stop repeating the kit.

## Decided by the user

- **Straight to main is the default.** A project that wants PRs says so
  by protecting `main` at its remote. A protected `main` is how the kit
  knows to land through a PR. It is read from the remote each time a
  change lands, never remembered, so the remote stays the one place it is
  said.
- **Merge commits are the default.** The install asks, and the answer
  goes in `AGENTS.md`.
- **Nothing is pushed or PR'd without asking,** each time. The install
  asks whether the user wants to overrule that for this project. Only on
  a yes does a line go in `AGENTS.md`, saying what is allowed, who allowed
  it, and when.

## Design

- **`GUARDRAILS.md`'s Commits section becomes _Landing a change_.** It
  says, in this order:
  - what a commit holds and how its message reads
  - where a change is made: on `main`, or on a branch of its own when
    `main` is protected, named for what it is
  - what is green before a push (the quick check, through the hook) and
    before landing on main (the pass)
  - how a PR describes itself: what changed, why, the definition of done
    point by point, and what was not verified
  - how it merges: the project's style, CI green
  - releases: a semver tag, annotated, recorded in the project's release
    notes. A pushed tag is never moved or deleted; one not yet pushed may
    be, on the user's word, which is what this kit did with `v0.1.0`.
  - clearing up: once work has landed, the branch, worktree and snapshot
    it was built from are removed, each checked against what landed first
  - who may act: pushing, opening a PR, merging and tagging each happen
    only on the user's word, each time, unless the project file grants
    one. A grant names what it allows, and never more.
- **Reading the remote.** On GitHub, `gh api repos/<o>/<r>/branches/main`
  gives `protected`, readable by anyone who can read the repo (checked
  2026-10-17: true for prettier/prettier, false for this kit). Rulesets
  may protect a branch without setting that field, so
  `gh api repos/<o>/<r>/rules/branches/main` is read as well, and any rule
  of type `pull_request` means PRs too. With no `gh`, another host, or no
  remote, the agent asks the user and does not guess.
- **The project file** gains the heading _How a change lands_, with
  `[merge style]` and `[what an agent may do without asking: nothing]`.
  The heading joins the list in `GUARDRAILS.md`, and the existing test
  holds the template to it. Branch strategy is deliberately not in it,
  since the remote says that.
- **`INSTALL.md`** asks the two questions after the harnesses: merge style
  (merge commit recommended; squash; rebase), and whether to overrule
  "never without asking" for pushing and opening PRs. Merging a PR and
  tagging stay ask-each-time unless the user names them. Where the
  install writes `AGENTS.md` from the template, it fills the answers in.
  Where the project has its own, it gives the lines to add. An update to
  a kit with this heading shows it in the template diff. The `guardrails`
  skill's phase 2 asks the same questions where the heading is missing or
  unanswered. The questions are written once, in `GUARDRAILS.md`, and
  both point to them.
- **Skills.** `commit` gains the branch rule (never commit to a protected
  `main`). A new `land` skill, asked for by name:
  - reads the remote
  - pushes, or opens a PR, only as the project file allows or the user
    says
  - says what CI shows, by reading it once each time it is asked, never
    by polling
  - merges in the project's style on the user's word
  - clears up
  - tags a release when asked

  It names no harness tool and no host beyond the `gh` command, which is
  said as one way among others for GitHub.
- **A check, `checks/landing.md`.** What can be held, not just said:
  - the hook installed and running the quick check
  - for a protected `main`, required status checks that include the full
    check, set at the remote
  - a commit message's shape (a summary line under a length, a blank
    line, a body), held by a `commit-msg` hook in the templates beside
    `pre-commit`
  - merged branches cleared, by a script that lists any left behind

  The house voice of a message is not a check; it is said, and reviewed.

## Out of scope

- Setting branch protection on any remote. That is the user's, at the
  remote.
- CI for this kit's own repo.
- Signing commits and tags.
- Trimming `~/.claude/CLAUDE.md`. That is part 7 below, built only on its
  own yes, and the kit never touches a user-level file itself.

## Parts

- [x] **0. Read protection for real.** On a repo of the user's: protect a
      scratch branch with a ruleset, and see what each endpoint shows to
      the owner. Read a public repo known to use rulesets, as a stranger.
      *Check:* the README says which field answers "must this land by PR",
      and how sure that is, with the date. Making the scratch ruleset
      waits for the user to say so.
- [x] **1. Tests first.** These cover four things:
      - _Landing a change_ names each of its parts, in the order above.
      - The project file headings include _How a change lands_, held
        against the template by the existing test.
      - `INSTALL.md` asks both questions, and points at `GUARDRAILS.md`
        for them.
      - The `land` skill passes the skills tests, and names no push or
        merge without the words "only on the user's word" or the project
        file's grant.

      *Check:* each is seen failing first.
- [x] **2. `GUARDRAILS.md`, the template, `INSTALL.md`.** *Check:* tests
      green.
- [x] **3. The `commit` and `land` skills, and the `guardrails` skill's
      phase 2.** *Check:* tests green.
- [x] **4. `checks/landing.md`, and `templates/commit-msg`.** The hook
      refuses a message without a summary line and a body, and its tests
      are run like the `pre-commit` hook's. *Check:* tests green, every
      new test mutation-checked.
- [x] **5. Trial,** by agents on the cheaper model, in throwaway clones:
      - an install into a fresh sysmod clone that answers the two new
        questions. `AGENTS.md` should come out with the merge style and
        "nothing without asking".
      - the `land` skill on a throwaway repo whose remote is a bare repo
        on this machine (straight to `main`): it commits, then stops and
        asks before pushing.
      - the protection read, against prettier/prettier, read only, and it
        should choose a PR.

      What cannot be tried here (opening and merging a real PR) is said
      under _not verified_, unless the user gives a scratch GitHub repo
      to try it on.
- [x] **6. Release `v0.3.0`.** The commit and the tag, both only on the
      user's word, and pushed only on the user's word.
- [x] **7. Trim `~/.claude/CLAUDE.md`,** only on its own yes. It is
      offered as a diff: the sections the kit now carries are replaced by
      a line saying the kit's `GUARDRAILS.md` holds in every project that
      has it, and what is left is this machine's own.

## Decided, and found while building

- **No scratch GitHub repo:** the ruleset-alone case in part 0 and a real
  PR in part 5 are marked not verified.
- **The grant covers pushing and opening PRs only.** Merging a PR and
  tagging are asked each time.
- **Part 0 found** that the default branch is not always `main`
  (`trunk`, `canary`, `master` among the eight read). The kit reads it,
  and everything in this plan that says `main` means the default branch.
  A ruleset is read as a stranger, and `pull_request`, `update` or
  `merge_queue` among its rules means a PR. The README has the table.

## What plan 4's trial found

Run 2026-10-17 by two agents, against a throwaway kit tagged `v0.3.0`.

- **Install and land, on a sysmod clone whose `origin` was a throwaway
  bare repo,** never the real checkout or GitHub, which were checked
  afterwards to be untouched. `AGENTS.md` came out with "a merge commit"
  and "nothing". The commit message passed the `commit-msg` hook. The land
  skill could not read protection from a bare repo, asked the user rather
  than guess, and asked again before the push, naming the commit, branch
  and remote. Only then did it push. Auto mode flagged the push as a
  publication; it was the trial's, to the throwaway remote, on the trial
  user's yes.
- **The protection read, on prettier/prettier, read only.** It found
  `main`, `protected: true`, and no ruleset rules, and chose a PR. It
  asked whether protection that only forbids a force push still means a
  PR. The user's rule is that protection of any kind is the signal, and
  the rules and the land skill now say so, with the empty-ruleset case.
- **Changed because of it:** a template's bracketed defaults are replaced
  by the answers in plain words; a plain git remote always means asking;
  and where the pass cannot be run before a land, the push's question
  says so, and the user decides whether it lands unchecked.

Not verified, with no scratch GitHub repo to hand: whether a ruleset
alone sets `protected`, and a real PR opened, checked and merged by the
land skill.

Part 7 was done on the user's yes, 2026-10-17: `~/.claude/CLAUDE.md` went
from 241 lines to 41, the old kept beside it as
`~/.claude/CLAUDE.md.before-guardrails`.


---

# Plan 5: dependencies

State: landed on main at 315595c, 2026-10-17.

Written 2026-10-17, on `f822e64` (`v0.3.0`). Nothing is built until the
user says go.

## Aim

What a project takes in from others is code it ships and did not write,
and the kit holds none of it. Today, across the user's projects:
lockfiles are committed; the user's own packages are pinned by git tag
(`github:onion2k/artshape-render#v0.45.0` in ooergolf, `#v0.23.0` in
pushminer); and nothing audits, checks licences, or says when a
dependency may be added. This plan gives dependencies a check of their
own and a rule in `GUARDRAILS.md`, so each project is surveyed and taken
up it like the rest.

Security beyond dependencies (secrets in the tree, headers, input
handling) is a plan of its own, after this one.

## The rule

A new bullet in `GUARDRAILS.md`'s Structure, beside "Machinery two
projects need becomes a package", pointing at `checks/dependencies.md`:

- **A dependency is taken in on purpose.** Before it is added, someone
  says what it is for, what it costs (download, start-up, install), who
  keeps it up and how lately, its licence, and why it is not a few lines
  written here. It goes in a commit of its own, saying so. A pin is moved
  in a commit that moves the pin and nothing else, as the rules already
  say for packages.

## The check: `checks/dependencies.md`

It has the four sections every check has.

- **What it holds:**
  - **Installs are exact.** The lockfile is committed. CI and the gates
    install from it and fail if it would change (`npm ci`,
    `pnpm install --frozen-lockfile`, `uv sync --locked`,
    `cargo build --locked`, `go mod verify`). A dependency pinned to a
    git ref is pinned to a tag or a commit, never a branch.
  - **Known vulnerabilities are seen.** An audit of the installed tree
    runs in CI and on a schedule, not in the hook: it needs the network,
    and its answer changes when nothing here has. It fails at the
    project's threshold. A finding the project accepts is written down
    with why, and a date to look again, and is listed by the check until
    then.
  - **Licences are allowed.** Every dependency's licence is on the
    project's allowed list, read from the installed tree. One not on it
    fails, by name.
  - **Nothing is unused.** A dependency no code imports is reported, and
    removed or said why it stays.
  - **Updates are made, not drifted into.** How the project keeps current
    is in its project file: by hand on a cadence, or by a bot whose PRs
    are held to the same checks. Each update lands as its own commit.
- **Its smallest form:** TypeScript first, as the others are:
  - `npm ci` in CI
  - `npm audit --audit-level=<threshold>` in a scheduled CI job
  - a licence check over `node_modules`
  - knip for what is unused

  Each tool is named only after it is looked up (part 1).
- **Seen failing:** a lockfile edited by hand fails the exact install. A
  dependency with a known advisory, pinned on a throwaway branch, fails
  the audit. A dependency with a licence off the list fails the licence
  check. An import removed leaves its dependency reported as unused.
- **Where it cannot apply:**
  - **Python:** uv or pip-tools for locking, pip-audit.
  - **Rust:** `--locked`, cargo-audit, cargo-deny for licences.
  - **Go:** `go mod verify`, govulncheck.
  - **A git-ref dependency** has no advisory database. Its tag is its
    pin, and the projects that pin it are listed in the package's own
    _Who uses it_, so drift between them is seen there.
  - **A project with no dependencies** says so.

## What else changes

- **`GUARDRAILS.md`:** the rule above. A row in the table, after
  structure and before unit, since an exact install is what every later
  check stands on.
- **The project file's _Commands_ in the template:** lines for the audit
  and how updates are made, and the allowed licences under _Gates_, where
  the thresholds live.
- **The `guardrails` skill's survey order:** dependencies after
  structure. A project whose packages pin each other by git tag (the
  user's own) is surveyed for how far apart its consumers are.
- **The `feature` skill:** a new dependency is a decision in the spec,
  with the rule's questions answered there, not found in the diff.

## Out of scope

- Running an audit across the user's projects or fixing what it finds.
  The survey reports it, and each project fixes its own, one check at a
  time.
- Bringing the user's games level on `artshape-render`. That is each
  game's update, on its own commit, when the user asks.
- Generating an SBOM, and signing or provenance of packages: the security
  plan's.

## Parts

- [x] **1. Look up the tools,** from their current docs, each noted with
      its source and date, as in plan 3: npm audit's levels, the
      `pnpm audit` and `uv` and `cargo --locked` flags, a maintained
      licence checker for npm, knip, pip-audit, cargo-audit and cargo-deny,
      govulncheck, and Dependabot's and Renovate's config for "security
      updates only". *Check:* a source for each name in the commit
      message.
- [x] **2. Tests first.** These cover three things:
      - The Structure rule points at `checks/dependencies.md`.
      - The table has `dependencies` after `structure`.
      - The `feature` skill names a new dependency as a decision in the
        spec.

      The existing tests already hold the check file's sections and the
      template's headings. *Check:* each is seen failing first.
- [x] **3. The check file, the rule, the template, the skills.** *Check:*
      tests green, every new test mutation-checked.
- [x] **4. Trial,** by agents on the cheaper model, in throwaway clones:
      - the `guardrails` skill's survey in ooergolf, which should report
        its two git-tag pins, their tags, and how far behind the
        renderer's newest they are. It should also run the audit once,
        read only, and report it.
      - the same in sysmod, with pnpm.
      - an update from `v0.3.0` to the new tag in a third clone.

      *Check:* each clone read here; what the agents guessed is fixed and
      recorded.
- [x] **5. Release `v0.4.0`.** The commit and the tag, and the pushes,
      each only on the user's word.

## Decided

All four recommendations, by the user, 2026-10-17.

## Open for the user (as written; answered above)

- **Audit threshold.** The recommendation is that _high_ and _critical_
  fail, _moderate_ is reported, and a written exception lasts at most 90
  days before it is looked at again.
- **Allowed licences.** The recommendation is MIT, BSD-2 and BSD-3,
  ISC, Apache-2.0, 0BSD and the Unlicense allowed. Anything else,
  copyleft included, is asked about by name.
- **How updates arrive.** The recommendation is a bot for security
  updates only (Dependabot alerts with security PRs), and version updates
  by hand, monthly, a commit each. The alternative is a bot for all
  updates, grouped weekly.
- **The install answer.** Should `INSTALL.md` ask the three questions
  above, as it now asks the merge style? The recommendation is yes, the
  answers written into _Gates_ and _Commands_.

## What plan 5's trial found

Run 2026-10-17 by three agents in throwaway clones, against a throwaway
kit with the real `v0.1.0` to `v0.3.0` and this work tagged `v0.4.0`;
each clone checked here afterwards.

- **The update held.** A sysmod clone on `v0.3.0` was updated to
  `v0.4.0`. The three new questions were asked, the diff showed
  `checks/dependencies.md` added, and the answers were given as lines to
  add to the project's own `AGENTS.md`. The clone matched `v0.4.0` byte
  for byte.
- **The survey found real findings, each confirmed here.**
  - sysmod: `pnpm audit --audit-level high` reports 12 advisories, 2 high
    and 4 critical, all through its dev dependencies vitest and vite.
    There is no audit, no CI and no update policy.
  - ooergolf: `npm audit` reports 2 critical and 1 high, all dev. Its
    lockfile resolves `artshape-physics` and `artshape-render` over
    `git+ssh` (lines 1609, 1614). Both are at their newest tags.
  - artshape-physics: its _Who uses it_ table is out of date. It says
    pushminer pins `v0.1.0`, and pushminer pins `v0.8.0`.

  These are each project's own to fix, and are put to the user.
- **The check was wrong in two places, now fixed.** Its licence command
  failed on any project's own private root (`--excludePrivatePackages`),
  and at a pnpm workspace's root, which has only dev dependencies (run per
  package). Its claim that pnpm's audit exits 0 on a registry error held
  for current pnpm's docs, but not for pnpm 8, which exits 1; the job now
  reads `--json` and does not trust the exit code alone.
- **Ruled while fixing:** the licence check is for what ships, and dev
  licences are reported; the audit covers dev dependencies too, at the
  same threshold unless the project says otherwise; a silent "nothing
  unused" is trusted only once seen to find something; a git-ref pin's
  _Who uses it_ is checked against the pinning projects' manifests; a
  local kit copy ahead of the published one is the one updated from; a
  bracketed default is no answer; and on an update the dependency
  answers come from the newer kit and are given as lines to add.


---

# Plan 6: security

State: landed on main at 7c88cbf, 2026-10-17.

Written 2026-10-17, on `315595c` (`v0.4.0`). Nothing is built until the
user says go.

## Aim

Plan 5 held what a project takes in. This plan holds the rest of what
keeps a project safe: secrets kept out of the tree, the code read for the
mistakes that become holes, CI that cannot be turned against the project,
and a site's headers. Each part is a check a project is surveyed against
and taken up one at a time, seen failing on a fault put there on purpose.

Today, across the user's 47 repos (read 2026-10-17):

- no secret scanner on this machine, and no tracked `.env` (two projects
  track a `.env.example`)
- 11 GitHub workflows. Two (artshape, artshape-render) have no
  `permissions:` block, so they run with the token's default access.
  Every action is pinned by a tag, not a commit, and two are third-party
  actions on refs that move: `tauri-apps/tauri-action@v0` and
  `dtolnay/rust-toolchain@stable`, in emu's release workflow.

## The rules

`GUARDRAILS.md`'s Structure already says what comes from outside is
checked. It gains two bullets, each pointing at the check that holds it:

- **A secret never enters the tree.** Keys, tokens and passwords come
  from the environment or a secret store. The tree carries an example
  with the names and no values. One that is committed is rotated, not
  just removed: the history keeps it.
- **The least that works.** A token, a workflow, a deploy key or a
  process is given only what its job needs, and a third-party action,
  script or image is pinned to what was read.

The agent's side goes in _Verifying_, beside "never touch what is the
user's": a secret is never printed, written to a file, sent or put in a
commit or a report, and one seen in the tree is named by its path and
line, not quoted.

## The checks

Each has the four sections every check has. TypeScript and GitHub come
first, with what stands in for other languages and hosts.

- **`checks/secrets.md`.**
  - A secret scanner runs in the hook, over what is staged: it is fast
    and needs no network, and a secret is cheapest to catch before its
    commit.
  - It runs again in CI over the whole history, and the host's own push
    protection is turned on where the host has it.
  - The example env file is checked to name every variable the code
    reads, with no values.
  - A finding the project accepts (a test fixture, a public key) is
    allowed by fingerprint, with a reason.
  - _Seen failing:_ a fake key in the scanner's own test format is staged
    and refused; one buried three commits back is found by the history
    scan.
- **`checks/code-scanning.md`.**
  - Static analysis for security, distinct from lint: it reads data from
    a source (a request, a file, a message) to a sink (a query, a shell,
    the page's HTML) and flags what goes through unchecked.
  - It runs in CI and on a schedule. A finding is fixed, or dismissed
    with a reason that the next scan keeps.
  - _Seen failing:_ a planted string concatenated into a shell command,
    or user input written into `innerHTML`.
- **`checks/ci.md`.** A workflow is code with the project's keys:
  - every workflow says its `permissions:`, read-only by default, with
    write access granted per job and per reason
  - third-party actions are pinned to a full commit hash, with the tag in
    a comment, and kept current by the update bot plan 5 set up
  - no `pull_request_target` job checks out and runs a fork's code
  - secrets are passed only to the steps that need them, and never
    echoed
  - _Seen failing:_ a workflow with no `permissions:`, and one using an
    action by a moving ref, are each flagged by a workflow linter.
- **`checks/headers.md`,** for anything served over HTTP:
  - a Content Security Policy with no `unsafe-inline` for scripts
  - HSTS, `X-Content-Type-Options: nosniff`, a frame policy, and a
    referrer policy
  - each read from the built thing as served, not the config that is
    meant to set them
  - _Seen failing:_ the policy loosened by a line, and the check seeing
    it in the response.
  - _Where it cannot apply:_ a package, a CLI, and a static host that
    cannot set headers, which says so under _What is not held_ and sets
    what it can with a meta tag.

The table puts secrets with the quick check, since its hook is part of
it; code scanning after lint; CI with verification; and headers after the
look. The order is held by the existing test.

## What else changes

- **The quick check** lists the secret scan among what runs before a
  commit, and points at `secrets.md`.
- **The template's _Gates_** gains where accepted findings are kept, for
  secrets and code scanning, with their reasons.
- **The `guardrails` skill** surveys the new checks, reports a finding by
  path and line and never the secret itself, and puts "rotate it" to the
  user first where a live secret is found.
- **`INSTALL.md`** asks nothing new: none of this is a matter of taste.

## Out of scope

- Fixing what the survey finds in any project. Each project fixes its
  own, one check at a time, on the user's word.
- Turning on the host's settings (push protection, code scanning's
  default setup). The check says which to turn on; the user does it.
- Penetration testing, threat models, and authentication and session
  design. These are a project's own, too particular for a kit.
- Signing commits and tags, SBOMs and provenance. They are worth a plan
  once a project publishes to a registry, which none of the user's do
  today.

## Parts

- [x] **1. Look up the tools,** from current docs, with sources and dates:
      gitleaks (its hook over staged files, its history scan, an allow
      list by fingerprint) against trufflehog; GitHub secret scanning and
      push protection; CodeQL's default setup for public repos against
      semgrep; actionlint and zizmor for workflows; pinning actions by
      hash, and Dependabot keeping the pins current; Mozilla's
      Observatory or a local header check for sites. *Check:* a source
      for each name, in the commit message.
- [x] **2. Tests first.** These cover four things:
      - The two new Structure bullets point at their checks.
      - _Verifying_ has the secret-handling line.
      - The table's order, by the existing test.
      - The quick check names the secret scan.

      *Check:* each is seen failing first.
- [x] **3. The four check files, the rules, the quick check, the
      template, the skill.** *Check:* tests green, every new test
      mutation-checked.
- [x] **4. Trial,** by agents on the cheaper model, in throwaway clones:
      - emu's workflows read against `ci.md`, which should flag the two
        moving refs and say what each should be pinned to. Read only.
      - artshape-render's `check.yml` read against `ci.md`, which should
        flag the missing `permissions:`.
      - a planted fake key in a clone of ooergolf, staged and refused by
        the scanner's hook, and a history scan of the clone that reports
        what it finds by path and line only.
      - an update of a sysmod clone from `v0.4.0` to the new tag.

      *Check:* each clone read here, and no secret quoted in any report.
- [x] **5. Release `v0.5.0`.** The commit, the tag and the pushes, each
      only on the user's word.

## Decided

All three recommendations, by the user, 2026-10-17. While building,
gitleaks turned out to be in maintenance: feature complete, security
fixes only, its authors moved to Betterleaks, whose version 2 is in
release candidates. The answer stands, since a hook wants what does not
move, and `secrets.md` names Betterleaks as the successor.

## Open for the user (as written; answered above)

- **The secret scanner.** The recommendation is gitleaks: one binary,
  fast enough for the hook, and an allow list by fingerprint. trufflehog
  verifies keys against their services, which is more than a hook needs.
- **Code scanning.** The recommendation is CodeQL's default setup on
  GitHub, which is free for public repos and turned on in settings with
  no workflow to keep. semgrep, in a workflow, is for a private repo or
  another host.
- **Pinning by hash.** The recommendation is to pin third-party actions by
  hash, and let GitHub's own `actions/*` stay on major tags, since a
  hash on every line is noise and GitHub's own are the least likely to be
  turned. The alternative is every action by hash.

## What plan 6's trial found

Run 2026-10-17 by two agents in throwaway clones, against a throwaway kit
tagged `v0.5.0`. Each finding was confirmed here.

- **ci.md found what it is for.**
  - emu's `release.yml` gives `contents: write` to the whole workflow
    (lines 8 and 9), and uses two third-party actions on moving refs:
    `dtolnay/rust-toolchain@stable` (line 36) and
    `tauri-apps/tauri-action@v0` (line 44). Pinned to what they are today:
    `dtolnay/rust-toolchain@b725eda525362e7cf34af9a7243cac1e3f01a7ec`
    (the `stable` branch, read 2026-10-17; it has no tag) and
    `tauri-apps/tauri-action@84b9d35b5fc46c1e45415bdb6144030364f7ebc5`
    (`action-v0.6.2`, which `v0` points at). Its newest release is
    `action-v1.0.0`, a major step.
  - artshape-render's `check.yml` has no `permissions:` block.

  These are those projects' own to fix.
- **The update held.** A sysmod clone on `v0.4.0` was updated to
  `v0.5.0`: the four checks added, the rest changed as shown, the
  template's new line given as one to add, and the clone matched `v0.5.0`
  byte for byte. sysmod reads one variable from the environment (`PORT`)
  and holds no secret.
- **Changed because of it.**
  - In `ci.md`:
    - a write permission goes on the job even in a one-job workflow
    - the default `GITHUB_TOKEN` counts as a secret
    - "GitHub's own" means `actions/*`, and every other organisation is
      pinned by hash
    - an action with only a branch is pinned to its commit, with the
      branch and date in the comment
    - an input an action runs as code is held like `run:`
    - zizmor's policy config is given, `.github/zizmor.yml` with
      `actions/*: ref-pin` and `*: hash-pin`, both patterns checked
      against its docs
  - `.env.example` holds every name read from the environment, secret or
    not.
- **Verified afterwards,** on the user's yes to installing gitleaks
  8.30.1 with Homebrew, in a throwaway repo given the kit's `pre-commit`
  template with `secrets.md`'s line:
  - a clean commit passed
  - a made-up key of AWS's shape was refused, named by rule, file and
    line, with the key redacted
  - AWS's documented `EXAMPLE` key was let through, as `secrets.md` warns
  - a key committed past the hook, buried under three commits and then
    deleted from the tree, was found by the history scan, by rule, file
    and commit
  - the kit's own history scans clean

  The one thing learned: without `--verbose` a failing scan names
  nothing, which `secrets.md` now says.
- **Not verified:** zizmor run on the workflows, which were read by eye
  against `ci.md` instead.


---

# Plan 7: nothing left behind

State: landed on main at 8635746, 2026-10-17.

Written 2026-10-17, on `7c88cbf` (`v0.5.0`). Nothing is built until the
user says go.

## Aim

Work is done in local sessions, in worktrees, in cloud sessions that push
branches of their own, and by hand. Each leaves something when it stops:
changes not committed, commits not pushed, branches not merged or merged
and not deleted, worktrees, stashes, PRs no one closed. The kit says that
once work has landed what it was built from is cleared, and nothing makes
sure. This plan adds a skill that finds what is left in a project,
wherever it was made, says what each thing is, and settles each one on
the user's word, plus a rule that a session ends with nothing of its own
left lying about.

Read only, on 2026-10-17, across `~/projects`:

- **26 projects have something left.**
  - Uncommitted changes in 21: ooergolf 101 files, humanity 60, wps 21,
    ooerfish 17.
  - Worktrees besides the checkout in 7: artshape-game-template has 3.
  - Local branches not merged in 5, and commits not pushed in 2 (shump,
    testgen).
- **On GitHub,** ooergolf has three `ccr-…` branches from cloud
  sessions, each 0 commits ahead of `main`: landed, never deleted.
- **63 open PRs** across the account, most of them Dependabot bumps from
  2022 and 2023 in repos not on this machine (ooer7, copper, psygallery,
  and others).

Some of the uncommitted work may be a session still at work, so nothing
here is called abandoned by looking at it.

## The rule

`GUARDRAILS.md`'s _Landing a change_ part _Clearing up_ gains:

- **A session leaves nothing of its own behind.** When its work stops,
  what it made is landed, parked on a branch with a line saying what it
  is and why it stopped, or removed on the user's word. That covers its
  commits, branches, worktree, stashes and PRs. What it found of anyone
  else's is reported, not touched.

## The skill: `tidy`

Asked for by name, for one project, or with a folder, for every git
project in it. It names no harness, and finds work by what it leaves in
git and at the remote, not by asking a harness about its sessions, so a
cloud session's work is found as the branch or PR it pushed.

1. **Fetch,** with `--prune`, and read the remote's default branch, as
   the land skill does.
2. **Find,** read only, and in each place:
   - **the checkout:** uncommitted changes, files not tracked or ignored,
     stashes, commits on the default branch not pushed, a detached HEAD
   - **local branches:** merged, not merged, and how far ahead and behind
   - **worktrees:** each one's branch, whether it is clean, whether it is
     merged, and whether git has marked it prunable or locked
   - **the remote:** branches merged and not deleted, branches with
     commits not on the default branch (a cloud session's, a PR's), and
     open PRs with their age, author and whether CI is green
3. **Say what each is,** in a table, as one of:
   - **merged:** everything in it is on the default branch. This is
     judged by ancestry, and, for a branch that was squashed or rebased in,
     by the PR that merged it or by `git cherry` finding each commit's
     patch upstream. A name is never enough.
   - **unmerged:** it has commits that are nowhere else.
   - **uncommitted:** changes in a working tree.
   - **stale:** an open PR or branch untouched for longer than the
     project's threshold.
   - **in use:** a worktree that is locked, or a tree changed within the
     last hour. It may be a session still at work, and is left alone and
     said.
4. **Stop, and put it to the user,** grouped, with a recommendation for
   each:
   - merged, local or remote: delete
   - unmerged: land it (the land skill), park it, or drop it
   - uncommitted: park it, or leave it
   - stale PRs: close, with a comment saying why, or keep
   - in use: leave
5. **Act on each yes, and nothing else.**
   - To delete, check again that the thing is merged.
   - To park, commit on a new branch named `parked/<date>-<what>`, with a
     message saying what it is and why it stopped, and push it only on
     the user's word.
   - Never delete, drop or discard unmerged or uncommitted work without
     the user's word for that item: a word for a group covers only
     what is merged.
6. **Report** what was found, what was done, and what is left, and why.

Across a folder of projects, steps 1 to 3 run for each and the report is
one table. Acting is done one project at a time.

## What else changes

- **`checks/landing.md`'s** _Nothing merged is left lying about_ grows to
  _Nothing is left lying about_. It points to the tidy skill, and its
  smallest form is the skill's read-only find.
- **The land skill's** _Clear up_ ends by running tidy's find on what it
  landed.
- **The commit skill** notices, before committing, a stash or a parked
  branch that looks like the same work.
- **The project file's _How a change lands_** gains the stale threshold,
  30 days by default, asked at install with the other two.

## Out of scope

- Acting on what the survey above found, in any project. That is tidy's
  first real use, on the user's word, a project at a time.
- Seeing a session itself: whether it is running, in which harness, on
  which machine. That is the harness's, not in git, and the skill says so
  when it judges a tree _in use_ from its age.
- PRs in repos with no checkout here. They are listed, with their URL,
  and closing them is the user's, since the repo is not here to check
  them against.

## Parts

- [x] **1. Tests first.** These cover four things:
      - The rule is under _Clearing up_, and the skill is in the skills
        list and passes the skills tests.
      - The tidy skill says each of the five kinds, says "never by name",
        and says "only on the user's word" in its acting step.
      - `landing.md` points at tidy.
      - The template and `INSTALL.md` ask the stale threshold.

      *Check:* each is seen failing first.
- [x] **2. A fixture for the skill's judgement.** A script under `tests/`
      builds a throwaway repo, with a bare remote, holding one of every
      kind: a merged branch, a squash-merged branch, an unmerged branch,
      a stash, uncommitted changes, a clean merged worktree, a locked
      worktree, a remote branch merged and one not. Tests hold that each
      is what it is. The skill is words, so the fixture is what the trial
      runs it against, and it is what holds the trial to the right
      answer. *Check:* the fixture's own tests, each seen failing on a
      fixture built wrong on purpose.
- [x] **3. The rule, the skill, `landing.md`, the land and commit
      skills, the template, `INSTALL.md`.** *Check:* tests green, every
      new test mutation-checked.
- [x] **4. Trial,** by agents on the cheaper model:
      - tidy run on the fixture: every item called what it is, the
        squash-merged branch called merged, the locked worktree called
        in use, and nothing done before the user's word
      - then told yes to deleting what is merged, and no to the rest:
        only the merged things are gone, which the fixture's tests then
        check
      - tidy's find, read only, across `~/projects`, giving the table, so
        the user sees what the skill would put to them, and nothing acted
        on

      *Check:* the fixture after each run, and each project's
      `git status` unchanged after the read-only run.
- [x] **5. Release `v0.6.0`.** The commit, the tag and the pushes, each
      only on the user's word.

## Decided, and changed while building

All four recommendations, by the user, 2026-10-17. While building, `git
cherry` turned out not to see a branch of two commits squashed into one:
it called both missing. The skill judges such a branch by whether merging
it would change nothing (`git merge-tree --write-tree` against the default
branch's tree, git 2.38 on), which the fixture holds.

## Open for the user (as written; answered above)

- **The name.** The recommendation is `tidy`. `sweep` and `leftovers`
  are the others considered.
- **Parking.** The recommendation is that uncommitted work may be parked
  on a `parked/` branch, on the user's word, so that nothing has to be
  thrown away to be tidied. The alternative is that tidy only reports
  uncommitted work and never commits it.
- **The stale threshold:** 30 days by default.
- **The old bot PRs** in repos not on this machine. The recommendation is
  that tidy lists them and leaves them, since closing them is better done
  in the repo, or with the repo archived.

## What plan 7's trial found

Run 2026-10-17 by two agents.

- **On the fixture,** round 1 named all nine things rightly. That
  includes `squashed`, merged by its tree when ancestry said no,
  `origin/landed`, merged, `origin/cloud` and `unmerged`, unmerged, and
  `wt-locked`, in use. It stopped as the skill says. Round 2, deleting
  what is merged on the trial user's yes, was stopped by auto mode's check
  on destructive git commands before anything ran. The agent did not try
  to get round it, and the fixture was unchanged. Round 2 was then run
  here on the user's own yes, as the skill says, after fetching and
  checking again. Gone: the worktree `wt-done` (first), the branches
  `wt-done`, `merged` and `squashed` (`-D`, merged by its tree), and
  `landed` on the remote. Kept, each checked: `unmerged`, `origin/cloud`
  on the remote, the locked worktree with its change, the stash, and the
  uncommitted change.
- **Across `~/projects`, read only** (no fetch, no merge-tree), it found:
  - 224 uncommitted files in 19 checkouts, and 18 in 4 dirty worktrees
  - 2 unpushed commits (shump, testgen)
  - 20 local branches, 4 of them not merged by ancestry (bearing,
    humanity, wordgame, slots2)
  - 9 worktrees
  - 7 GitHub branches besides the default, 6 of them merged (ooergolf's
    three `ccr-…` among them), and 12 local remote refs whose branches
    are gone from GitHub
  - 4 projects with no remote, so not backed up (wps, catapult-game,
    snapper, slots2D)
  - 63 open PRs, all in 5 repos with no checkout here: copper 24,
    psygallery 18, pagehammer 9, narrator 7, ooer7 5

  Every project's status and refs were fingerprinted before and after.
  All were unchanged but ooerfish, where `src/lake.ts` changed at
  17:32:33, after the run and seconds before it was looked at. ooerfish
  has a worktree in another Claude session's scratchpad: another session
  is at work there. That is what _in use_ is for, and it was left alone.
- **Changed because of it.** In the skill:
  - the default branch is read with `git ls-remote --symref` where
    `origin/HEAD` is unset
  - a project with no remote is said to be backed up nowhere
  - the host's repo name comes from the remote's URL
  - a read-only run is defined: no fetch and no merge-tree, with
    "not merged by ancestry" said for what only the tree could clear
  - _in use_ means files with uncommitted changes in the last hour, never
    a checkout's age, and takes the branch of a worktree in use with it
  - worktrees may be anywhere, and a detached one is judged by its commit
  - _stale_ is measured from a branch's newest commit or a PR's last
    update
  - deleting fetches and checks again first, and removes a worktree
    before its branch
  - the table's columns are named


# Plan 8: the mutation check gets an instrument

State: landed on main at 3ecc278, 2026-10-18.

Written 2026-10-18, on `8635746` (`v0.6.0`), on the strongest model to hand,
in plan mode. Nothing is built until the user says go.

## Aim

Point 8 of the definition of done, the mutation check, is the only point
held by the agent's word: a line in a report saying the bug was put back
and the test failed. Every other point rests on something that ran.
`checks/mutation.md` names a mutation testing tool as something that "can
stand beside it" and "is worth running now and then", which by the kit's
own rules is a check that never runs: no owner, no cadence, no figure.

The kit is used only in TypeScript projects today (the user, 2026-10-18),
so the advice can name Stryker as the tool and give its commands, with the
family (mutmut, cargo-mutants, PIT) named once for anyone else. Naming a
tool is what the check files already do (gitleaks, prettier, actionlint);
`GUARDRAILS.md` stays free of names.

Looked up 2026-10-18:

- `@stryker-mutator/core` and `@stryker-mutator/vitest-runner` are at
  10.0.0 (2026-08-14), Apache-2.0, node >= 22, vitest >= 2.
- Incremental mode (`--incremental`, `reports/stryker-incremental.json`)
  diffs mutated and test files against the last report, not git. The
  per-change form is `--incremental --force --mutate <file>`, which reruns
  only the named files and keeps the rest of the report. Vitest reports
  test locations, so changed tests are seen. Sources:
  stryker-mutator.io/docs/stryker-js/configuration/ and
  stryker-mutator.io/docs/stryker-js/incremental/.
- `thresholds.break` fails the run under a score; `null` by default, and
  `high`, `low` and `break` are given together. The json reporter writes
  `reports/mutation/mutation.json`, each mutant with a status: Killed,
  Survived, NoCoverage, Timeout, RuntimeError, CompileError, Ignored.

A guess, to be tried in part 4: that the config in the check's smallest
form runs as written against a vitest 3 project. Nothing here has been
tried.

## The design

The hand check stays as point 8: Stryker's mutants are generic (an
operator flipped, a branch dropped) and the bug a test was written for is
usually not one of them. What changes is that the tool joins it as a gate,
and the report line of the hand check becomes something a reader could
redo.

**`checks/mutation.md`, rewritten in the same four sections:**

- _What it holds_: the hand check, once per new test, as now; and, where
  the project has the tool, the suite's survivors, a count per file held
  exactly. A survivor is a mutant with status Survived or NoCoverage.
  Two runs: in the pass, over the files the change touched; the whole
  suite in the full check, or on a schedule the project file names where
  the full check cannot carry it.
- _Its smallest form_: the report lines, each naming what was changed
  (the line, or the command) so a reader could put the bug back
  themselves; then `stryker.config.mjs` (vitest runner, `mutate` over
  the logic and not the page, `incremental`, the json reporter,
  `thresholds.break` as the budget), a judging script in the shape of
  `gates.md`'s (reads the json report, counts survivors per file,
  compares exactly with `mutation-baseline.json`, with unit tests), and
  the commands: `mutate` (the whole suite, judged), `mutate:update` (the
  baseline written again, for a change meant to move it, said in the
  commit), and the per-change run written out as its two commands,
  `stryker run --incremental --force --mutate` over the files the change
  touched and the judge over the same files.
- _Seen failing_: the hand check as now. The tool: a test that asserts
  nothing added on purpose, seen as survivors in its file; the judgement
  handed counts over, under and equal to the baseline.
- _Where it cannot apply_: the picture is not mutated, only the logic the
  structure rules keep apart from it, and the project file says so. A
  language with no tool: the hand check alone, said under _What is not
  held_. A suite too slow for the full check: the whole-suite run on a
  schedule the project file names, and the per-change run still in the
  pass. The kit itself: bash, no tool.

**`checks/gates.md`:** survivors join the list of figures a gate holds,
as a count held exactly, pointing at `mutation.md`.

**`GUARDRAILS.md`:** point 8 gains one clause: where the project has a
mutation gate, it runs in the pass over the files the change touched. The
table row's words become "a test seen to fail when its bug is put back,
and the suite's survivors counted". The file stays at its length.

**`templates/AGENTS.md`:** `[mutate]` under _Commands_; a line under
_Gates_ for survivors, per file, baseline file named, held exactly; and
the _What is not held_ bullet gains the case of no mutation tool yet.

**`skills/feature/SKILL.md` and `skills/bug/SKILL.md`:** the verify
step's mutation check bullet gains the tool's per-change run, where the
project has one, with its figures kept for the report.

**`README.md`:** a `v0.7.0` row in the release table.

## Out of scope

- A new check file or table row.
- Any change to `INSTALL.md` or the install questions.
- Adding Stryker to the game template itself: that is the template's own
  change, to its definition of done, after the kit is released.
- Other harnesses.

## Parts

- [x] **1. The plan into `PLAN.md`,** as plan 8, with the lookups above
      and their sources.
- [x] **2. Tests first,** in `tests/test_mutation.sh`, each seen failing
      on the kit as it stands: - `mutation.md` no longer says "now and then", names the two
      survivor statuses, and says the count is held exactly - `mutation.md` says the per-change run is over the files the
      change touched, and that a reader could put the bug back
      themselves from the hand check's line - `gates.md` points at `mutation.md` - the template's _Gates_ and _Commands_ name mutants and `mutate` - the feature and bug skills' verify step names the mutation gate - `GUARDRAILS.md`'s point 8 names the gate

      *Check:* each red first, then green with the edits.

- [x] **3. The edits** to the seven files above. _Check:_ `tests/run`
      green, each new test mutation-checked by hand (the words taken out,
      the test seen failing, restored) and the lines in `PLAN.md`.

      Mutation checks, each seen failing alone and restored:
      - names its figure: "held exactly" turned to "kept", "Survived" and
        "NoCoverage" each turned to another word, "now and then" put back
      - runs on what the change touched: "files the change touched" cut
        to "files", the hand-check phrase turned to "redo it"
      - gates point at it: `mutation.md` turned to another file's name
      - template names it: `[mutate]` and "Surviving mutants" each taken out
      - skills run the gate: "mutation gate" taken out of each skill
      - rules name the gate: "mutation gate" taken out of point 8

- [x] **4. Trial,** by a builder agent on the cheaper model, in a
      throwaway copy of `~/projects/artshape-game-template` (commit
      `4c790eb`), never its checkout: - take in `@stryker-mutator/core@10.0.0` and the vitest runner,
      write the config from the check's smallest form, run the suite,
      and time it on a quiet machine: how many mutants, how many
      survived, the score, the seconds - the judging script from the smallest form, with its unit tests - the instrument trusted: a test that asserts nothing added, seen
      as a survivor in the json report and the judgement; removed - the per-change run over one file, timed, seen to keep the rest
      of the report - the check's commands as written seen to be the ones that work,
      and any that are not put right in the check

      *Check:* the figures, kept for `PLAN.md`'s "What plan 8's trial
      found", and the copy deleted.

- [x] **5. Release `v0.7.0`.** The commit, the tag and the pushes, each
      only on the user's word.

## Open for the user

- **Where the whole-suite run lives:** in the full check where the trial
  measures it under a few minutes (recommended, with the figure), else on
  a schedule the project file names, such as before a release. The check
  says both, and the figure from the trial decides the recommendation.
- **The commands' names:** `mutate` and `mutate:update` (recommended),
  matching `perf` and `perf:update` in `gates.md`; the per-change run is
  two commands written out, since the files are its argument.
- **`v0.7.0`** as the release, since a check's advice changes shape.

## What plan 8's trial found

Run 2026-10-18 by a builder agent on the cheaper model, in a copy of
`artshape-game-template` at `4c790eb`, with load average 3.3 at the
start. The figures were read off its logs here before anything was
changed from them.

- **Taking the tool in:** 6 s, 157 packages, node_modules from 112M to
  168M. A dependency to be taken in on purpose, in a commit of its own.
- **The whole suite,** nine logic files once the page, the scene, the
  meshes, the matrix, the debug glue and the keyboard were left out: 722
  mutants, 374 killed, 25 timed out, 297 survived, 26 not covered, score
  55.26, in 53 s wall over eleven runner processes. Repeated on an
  unchanged tree with the incremental file: 3 s. So the whole suite goes
  in the full check, and the per-change run is the pass's.
- **The baseline:** 323 survivors over nine files, `autopilot.ts` 169 of
  them, `physics.ts` none. The report's keys are relative paths, as a
  diff gives them.
- **Seen failing:** with `sled.test.ts`'s assertions taken out, the
  per-change run (7.3 s) took `sled.ts` from 17 survivors to 21, the
  judge printed `src/sled.ts: 17 -> 21` and exited 1, and every other
  file's count was unchanged in the report. Restored: 17, judge green.
  Only four more survived, since the determinism, game and autopilot
  tests cover the sled too: the check's remark that a hollow test added
  is not the fault held.
- **`thresholds.break`** fails the run as the docs say, with the score
  taken over the whole report, not the files mutated in this run.

What the check said and did not hold, each put right in it:

- **`break: 60`** failed this game on a tree equal to its baseline, at
  55.26. The check now says break is set below the first run's score and
  raised as the baseline comes down; the example says 50.
- **`mutate:update` as "stryker run, then write"** needs Stryker's exit
  code ignored when the score is under break, and `;` in an npm script
  does not hold on Windows. The check now has the update write the
  baseline from the last run's report, with no run of its own.
- **`npx tsx`** is not how the project runs a script. The check now says
  the main is run the way the project runs its scripts, apart from the
  judging functions so that a test can import them without running it,
  and the per-change judge is `npm run mutate:judge -- <files>`.
- **`--incremental` on the command line** is redundant with the config;
  dropped. **`--force`** was not needed to see the fault, since Stryker's
  own diff saw the changed test file; kept, with why.
- **The judge's default** of the report's files missed a file deleted
  since the baseline; the check's default is now the files of both.
- **`!src/**/*.test.ts`** matched nothing in a project with its tests in
  `test/`, and Stryker warned; the example glob is gone.
- **What is committed** was not said: the baseline is, `reports/` is
  ignored.
- **The failing output** is long: every survivor with every test that
  ran. The check says to read the judge's lines first.

Not done: the judge's five unit tests, green in the copy, were not
mutation-checked; nothing was run on Windows; the full `npm run check` of
the copy was not run with the new scripts in it. Adding the gate to the
template itself is the template's own change, out of scope here.


# Plan 9: CI comes out of the kit

State: landed on main at adacda4, 2026-10-18.

Written 2026-10-18, on `3ecc278` (`v0.7.0`), on the strongest model to hand,
in plan mode. Built from the answers under _Decided by the user_.

## Aim

The user said on 2026-10-18 that guardrails is for local development only,
and that anything about CI in the kit is to come out. CI is in it in
seven places: a check of its own (`checks/ci.md`, with a rule bullet, a
table row, a test and a release line), five checks that assume a runner
exists (verification's "somewhere other than here" with a workflow as its
smallest form, dependencies' audit in CI with a workflow and a Dependabot
file, secrets' history scan in CI, code scanning in CI with CodeQL's
default setup, landing's protection by required status checks), and the
landing rules and the land skill ("CI green before a PR merges", a step
for reading what CI says), plus a `[CI]` line in the project-file template
and a line in the guardrails skill.

The aim is a kit in which every check holds in one of three places, all on
the machine the work is done on: the hook, the full check, or a fresh
clone before a release. Nothing in it needs a runner, a workflow, a bot or
a host's own scanning. A project that has CI runs the same full check
there, and that is the project's own business, said once in the README.

What this gives up, said plainly in the kit: a check that passes only on
the author's machine holds the author's machine. The fresh clone stands in
for that, and it is weaker than a clean runner on a push: it is run when
someone runs it. The kit says so under verification's _Where it cannot
apply_.

## The design

**Taken out.** `checks/ci.md` is deleted. In `GUARDRAILS.md`, the table
row goes; the _least that works_ rule keeps its sense (a token, a deploy
key or a process given only what its job needs, a third-party script or
image pinned to what was read) and loses "a workflow", "action" and the
pointer to `checks/ci.md`. In _Landing a change_, "CI green before a PR
merges" becomes "the full check green on the commit merged, run by whoever
merges and said in the PR", and "with CI green" in _Merging_ becomes "with
the full check green".

**`checks/verification.md`.** The bullet _Somewhere other than here_
becomes _From a fresh clone._ Before a release, and on the user's word at
any time, the full check runs from a fresh clone of the commit (`git clone
--no-local`), with the lockfile's dependencies installed clean, on this
machine or another to hand; what passes only in the working tree (an
untracked file, a stale build, a global install, a cached dependency)
fails there. The smallest form replaces the workflow with the four shell
lines of the fresh-clone run. The paragraph on gates left out of CI by
name becomes: a gate that measures this machine's GPU or clock holds on
this machine, and the project file's _Gates_ says which machine. _Seen
failing_: a file the tests need left untracked, and the fresh-clone run
seen to fail; a gate made red and seen red there. _Where it cannot apply_
loses the no-CI bullet and gains: this is run when someone runs it, and
a project that wants it on every push has CI of its own, outside the kit.

**`checks/dependencies.md`.** "CI and every gate install from it" becomes
"every gate, and every fresh clone, installs from it". The audit runs in
the full check, and before each monthly update, because an advisory can be
published against a tree that has not changed; still not in the hook, for
the reason given. The workflow and the Dependabot file go from the
smallest form, with the sentences on Renovate, the actions' versions, and
a scheduled workflow stopping after 60 days. Question 3, _how updates
arrive_, becomes: by hand, monthly, a commit each, with the audit run
first (recommended), or on the project's own cadence; no bot. "The job"
that checks the audit's output becomes "the script". The git+ssh bullet
loses "CI is given one": a machine installing it needs a key, or the
dependency resolves over HTTPS, and a fresh clone install shows which.

**`checks/secrets.md`.** _Nothing in the history does_: the scanner runs
over the whole history in the full check (seconds, for a history of
thousands of commits), and from the fresh clone before a release. The
host's push protection and GitHub's secret scanning go, as does the
_host without push protection_ bullet. The smallest form's CI block
becomes the one line `gitleaks git --redact --verbose` in the full check.

**`checks/code-scanning.md`.** It runs in the full check, with rules
fetched fresh each run, since they improve when the code has not changed;
the bullet on reading CI workflows goes. The smallest form loses CodeQL's
default setup and keeps semgrep, run locally (`pipx run semgrep scan
--config auto --metrics=off --error`, or `uvx semgrep`); a finding is
dismissed with a `# nosemgrep: <rule>` comment that says why. _Seen
failing_: each fault planted in the working tree, seen flagged, taken out;
the workflow case goes.

**`checks/landing.md`.** The bullet _A protected default branch is
protected by the checks_ becomes _A PR carries the full check's result_:
the commit it ran on and what it counted, since nothing else runs it, and
a PR without it is not merged. The paragraph on required checks in
GitHub's settings goes, as do the _Seen failing_ line on a red PR not
being mergeable and the _CI cannot run the full check_ bullet.

**Skills.** `skills/land/SKILL.md`: the description loses "says what CI
shows"; step 4 _What CI says_ becomes _The full check, once more_: before
a merge, the full check is run on the branch as it will merge (merged
with the default branch locally, in a worktree), and the result put in
the PR; "every required check green" becomes "the full check green"; the
report's _CI_ line becomes _The full check_: its result and the commit.
`skills/guardrails/SKILL.md`: "any CI" goes from what is read, and
verification "comes once there is a full check to run from a fresh
clone".

**`templates/AGENTS.md`.** The `[CI]` line goes; `[updates]` becomes "by
hand, monthly, a commit each, the audit first".

**`README.md`.** _Left out on purpose_ gains a bullet, _CI_, saying the
above in four lines. A `v0.8.0` row in the release table. The `v0.5.0` row
stays as history. _How a change lands on a GitHub remote_ stays: reading
the branch's protection is how push or PR is decided, and is local work.

**Tests.** `tests/test_security.sh`'s least-that-works assertion no
longer asks for `checks/ci.md`; it asks that the rule is still there.
`tests/test_standards.sh`'s `CHECK_ORDER` loses `ci`. A new
`tests/test_local.sh` holds the kit to being local: no file in
`GUARDRAILS.md`, `checks/`, `skills/`, `templates/` or `INSTALL.md`
contains, as a word and in any case, `CI` (but `npm ci` and `pnpm ci`
are allowed, by excluding `npm ci`), `workflow`, `workflows`,
`Dependabot`, `Renovate`, `CodeQL`, `zizmor`, `actionlint`,
`pull_request_target`, `GITHUB_TOKEN`, `runs-on` or `.github/`; and
`checks/ci.md` is not there. `test_checks_are_each_named_by_the_rules`
already fails on a check file the table does not name, which is the
other half.

## Out of scope

- The headers check's HTTP Observatory, which grades a live host and is
  not CI: left as it is.
- The land skill's reading of branch protection, which decides push or PR
  and stays.
- CI in any project that has it.
- The game template.

## Parts

- [x] **1. The plan into `PLAN.md`,** as plan 9.
- [x] **2. Tests first:** `tests/test_local.sh`, and the two edits to
      existing tests, each seen failing on `v0.7.0` (`test_local` red on
      every file that mentions CI; the standards test red on the table
      until the row goes). _Check:_ `tests/run local` red first.
- [x] **3. The edits** to the eleven files above and the deletion of
      `checks/ci.md`. _Check:_ `tests/run` green with prettier; each new
      test mutation-checked (a `workflow` put back into one check, the
      test seen to name the file and line); every file touched read
      through for the house voice.

      Mutation checks, each seen failing alone and restored:
      - `test_local_nothing_needs_a_runner`: `workflow` put back at the
        end of a line in `checks/lint.md`; it named `checks/lint.md:5`
        and nothing else failed
      - `test_local_no_ci_check`: `checks/ci.md` copied back from
        `HEAD`; it failed, with `test_checks_are_each_named_by_the_rules`
        and the words test
      - the standards order: ` ci` put back into `CHECK_ORDER`; the order
        test failed
      - the security test: the least-that-works bullet's words changed in
        `GUARDRAILS.md`; it failed
- [x] **4. Trial,** by a builder agent on the cheaper model, in a
      throwaway clone of `~/projects/artshape-game-template` (its `main`
      as it stands, which now has the mutation gate uncommitted in the
      real checkout: clone the committed state only):
      - the fresh-clone run from verification's smallest form, as
        written, timed: `git clone --no-local`, `npm ci`, `npm run check`
      - a file the tests need left untracked in the source, and the
        fresh-clone run seen to fail
      - the history scan from secrets' smallest form (`gitleaks` 8.30 is
        on this machine), timed, and a made-up key three commits back on
        a throwaway branch seen found
      - the audit line from dependencies' smallest form, run, and
        against an unreachable registry seen to fail rather than pass
      - semgrep's line, if `pipx` or `uvx` can be had without installing
        anything globally; otherwise said to be not tried

      _Check:_ figures kept for "What plan 9's trial found", each line of
      the changed smallest forms marked worked, changed or did not hold,
      and the clone deleted.
- [x] **5. Release `v0.8.0`.** The commit, the tag and the pushes, each
      only on the user's word.

## Decided by the user

On 2026-10-18, the three questions put to them, each answered with the
recommendation:

- **Host-side services** (GitHub's push protection, secret scanning,
  CodeQL's default setup, Dependabot) go too, since the kit cannot see
  them fail and "local only" means the kit holds only what runs here.
- **The HTTP Observatory** in the headers check stays: it grades a live
  host over the network, it is not CI, and a served page's headers can be
  read nowhere else.
- **`v0.8.0`** is the release: a check removed changes the table every
  project's file points at.

## What plan 9's trial found

Run 2026-10-18 by a builder agent on the cheaper model, in a throwaway
clone of `artshape-game-template` at `f357dd4`, with node 23, npm 10.9,
gitleaks 8.30.1 and semgrep 1.181 through uvx. The figures were read
off its report here.

- **The fresh clone,** as verification's three lines are written, works
  in bash and in zsh: `$_` lands in the new clone in both. `npm ci` took
  2 s with a warm cache and `npm run check` 19 to 22 s when it passed.
  It failed in 4 of 11 runs, every one a gate's wobble on this machine
  (`frameMs` at 0.74 to 0.95 against a baseline of 0.177, and the
  physics bench 18% quicker), not the clone's. The check now says such a
  red is the gate's and is run again.
- **Seen failing, verification:** a helper moved into an untracked file
  passed the quick check in the clone and failed the fresh clone's run
  in 2 s on the missing module. As written.
- **The history scan:** 14 commits in 0.09 s, clean. A made-up key three
  commits back on a throwaway branch was found, with its rule, file,
  line, commit and fingerprint, the key redacted, exit 1. As written.
- **The audit:** the template fails its own threshold today (6 findings,
  3 of them high or critical, in vitest's tree, qs and others). Against
  an unreachable registry npm exits 1 and says so, so npm's exit code is
  enough; the check now says the `--json` guard is pnpm's.
- **semgrep:** `--config auto --metrics=off` did not hold: semgrep
  refuses to pick packs with metrics off, exit 2, nothing scanned. A
  named pack, `p/default`, ran 230 rules over 56 files in 5.6 s warm
  (24 s cold with its download). The check now gives that line, through
  uvx since pipx was not here to try. The query string written bare
  into `innerHTML` was not flagged, by any of five packs; joined to a
  literal it was, as `raw-html-concat`. The check's fault is now written
  the way the rules read it, and says so. `nosemgrep: <rule>` in a `//`
  comment silenced it, on the line or the line above. One false positive
  came up, a `data:` icon without an integrity hash, which is what the
  dismissal is for.

Not tried: `pipx run semgrep`; the shell-command fault in a real
handler; the lockfile, licence and unused faults; the `EXAMPLE` key;
the hook with a gitleaks line, which the template does not yet have.


---

# Plan 10: plans kept in the project, and where every piece of work stands

State: building, part 7 of 7.

Written 2026-10-18, on `facdfe1` (`v0.8.0` and one tick), on the strongest
model to hand, in plan mode. Agreed on 2026-10-18 as written, under
_Decided by the user_. The state line above is the shape this plan gives
every plan, and is written into `PLAN.md` with it in part 1. From part 1 on
the build is work for the cheaper model: in a session switched to it, or by
the builder agent a part at a time, with this plan as the brief.

## Aim

A plan is agreed in the harness's plan mode, which writes it to a file of
its own naming on this machine, and that copy goes stale: of the twelve
newest, six show nothing ticked, because ticking happens in a copy kept in
the repo. That copy is already the user's practice, ad hoc: ooerfish keeps
twelve plans in `docs/`, ooergolf has `GUARDRAILS-PLAN.md`, artshape-sound
and this kit each have a `PLAN.md`. No two projects keep them in the same
place, and none says in a line whether it is open, landed or parked: a
reader counts boxes. Git says nothing once work lands (four projects clean
on 2026-10-18, no branches at the remote, no PRs, because the clearing-up
rule works), and the tidy skill already finds what work leaves behind in
git. What is missing is intent: what each piece of work is, where it
stands, and what comes next.

The user chose the shape on 2026-10-18: plans live in `plans/<name>.md`,
and where work stands is read by a tool, never kept by hand. Not chosen,
and not built: a kept `NEXT.md` every session updates, or leaning on a
harness's own list of sessions.

Done looks like this. A plan is a file in the project, named for the work,
whose line under its title says where it stands in a form a script reads
without guessing. One script, shipped by the kit and needing nothing but
`sh`, `git` and `gh` where it is present, prints one screen for a project:
each open plan with its state, its progress in boxes and its first open
box; what git and the remote hold that tidy would find, by tidy's own
judgements; and what has landed on the default branch since the last tag.
A `next` skill runs it and reads it out. The rules and the skills that
touch plans say the same thing. Released as `v0.9.0`.

## The design

### Where a plan lives

`plans/<name>.md`, one plan a file, named for the work (a slug of its
title), on the work's branch, so it lands with the work. A plan agreed in
a harness's own plan file is copied there the moment it is agreed, and the
copy is the one ticked. A landed plan stays where it is, with its state
line saying so; `next` shows only what is open.

A project may instead keep its plans as sections of one `PLAN.md` at its
root, as this kit does, one `# ` heading a plan. The script reads both in
the same way: a plan is a `# ` heading, the state line under it, and the
boxes up to the next `# ` heading. Nothing else is read: a plan kept
anywhere else (ooerfish's `docs/`, ooergolf's `GUARDRAILS-PLAN.md`) is
moved into `plans/` by its project when it chooses, which is out of scope
here.

### The state line

The first non-blank line after a plan's title, in one of four forms, and
no other:

    State: agreed 2026-10-18.
    State: building, part 3 of 7.
    State: landed on main at 1a2b3c4, 2026-10-18.
    State: parked, waiting on the renderer's next release.

- **agreed**, with the date it was agreed. Nothing is built yet.
- **building, part n of m**: n is the first open box, counting from one;
  m is the boxes, dropped ones left out. Moved as each box is ticked, so
  the file says the same as the chat.
- **landed on `<branch>` at `<hash>`, `<date>`**: the default branch, the
  commit the work landed in (the merge, or the last push), and the date.
  Written in the tick commit after it lands, as this kit does already.
- **parked, `<why>`**: stopped, and why, in a few words.

The full stop at the end is allowed and not required. As patterns, for
the script and the tests (extended regular expressions, one a line):

    ^State: agreed [0-9]{4}-[0-9]{2}-[0-9]{2}\.?$
    ^State: building, part [1-9][0-9]* of [1-9][0-9]*\.?$
    ^State: landed on [^ ]+ at [0-9a-f]{7,40}, [0-9]{4}-[0-9]{2}-[0-9]{2}\.?$
    ^State: parked, .+$

A line that matches none of these, or a plan with no `State:` line under
its title, is refused by name (the file, and the title), with the line as
written, and never guessed at. A refusal does not stop the rest of the
screen, and the script exits non-zero at the end so a loop can count them.

### The boxes

A box is a list item at the start of a line: `- [ ]` open, `- [x]` ticked,
`- [-]` dropped, which the user's own plans already use for a part given
up (ooergolf's part 9). Every box at the top level counts, wherever it is
in the file: a part, or a question the user owes, which is a box like any
other, and its place in the file says whether it blocks (ooergolf's two
questions sit above its parts, and are next). A box indented under
another is not a part. Boxes inside a fenced code block are not read, and
nor is a `# ` line there.

Progress is ticked of (ticked plus open); dropped boxes are said apart
("and 1 dropped"). The next step is the first open box: its number among
the counted boxes, and its text, which is the bold run where the box has
one, else its first line, stripped of a leading number or `Part n:`, of
emphasis and backticks, and cut to fit the column at a space.

The state line is held equal to the boxes. Where it says `agreed` and a
box is ticked, or `building, part n of m` and the boxes give another n or
m, or `building` and every box is ticked, the script prints both facts on
a line under the plan's row and leaves the row standing: the line is well
formed and out of date, which is not a refusal.

### The script: `next`

`next` at the kit's root, so that a project gets it as `guardrails/next`,
beside `guardrails/GUARDRAILS.md` and `guardrails/checks/`, copied byte
for byte and compared on an update like them. POSIX `sh`, `git`, and the
tools git brings with it on every system (`awk`, `sed`, `grep`, `find`),
with `gh` where it is present and the remote is GitHub. No bash, no
`local`, no arrays, no `date -d` or `date -v`, no gawk-only syntax; it is
run under `dash` in the tests where this machine has one. On Windows it
runs under the `sh` Git for Windows installs, which is the one thing a
project already needs.

    sh guardrails/next            the project the shell is in
    sh guardrails/next <folder>   that project
    sh next                       in the kit itself

It writes nothing: no fetch, no `merge-tree`, no `git status` (which
refreshes the index); the changes in a tree are read with
`git diff-index --name-only HEAD` and `git ls-files --others
--exclude-standard`. It reads, in this order:

1. **The plans.** `plans/*.md` and `PLAN.md`, each file once through awk.
   For each open plan: the title, the state, the counts, the next box;
   the date it last moved, which is the last commit touching the file
   (`git log -1 --format=%cd --date=format:'%d %b %Y' -- <file>`, the
   year shown only when it is not this year), or `uncommitted` where the
   file has changes in the tree, or `untracked`. Where the plan is: on
   the branch the checkout is on, if that is not the default branch and
   the file differs from the default branch's copy or is absent there;
   and, on the default branch, whether any other branch, local or remote,
   holds a different copy (`git diff --quiet <ref> <default> -- <file>`
   over `git for-each-ref refs/heads refs/remotes`). An open plan on the
   default branch that no branch differs on is said so: "no branch is at
   work on it", which is what tidy reports as building while its branch
   is merged or gone. Landed plans are counted, not listed; the newest by
   its date is named when nothing is open.
2. **What tidy would find,** read only, by the tidy skill's own words in
   its step 3, so that the read-only run tidy describes is this script.
   The default branch from `git symbolic-ref -q refs/remotes/<remote>/HEAD`,
   else `git ls-remote --symref <remote> HEAD`, else, with no remote, the
   one of `main` and `master` that exists, said to be assumed; the remote
   is the first `git remote` lists. Then: the checkout's uncommitted
   changes and untracked files (a count), stashes, commits on the default
   branch not at the remote, a detached HEAD; each local branch but the
   default, ahead and behind it, merged by ancestry
   (`git merge-base --is-ancestor`) or "not merged by ancestry"; each
   worktree but this one (`git worktree list --porcelain`), its branch,
   clean or not, locked, prunable, and in use (locked, or a changed file
   modified in the last hour: the changed files from `diff-index` and
   `ls-files`, filtered by `find -mmin -60`); each remote branch but the
   default, merged by ancestry or not; stale, for a branch whose newest
   commit (`%(committerdate:unix)`) or a PR whose `updatedAt` is older
   than the project's threshold, read from the project file's
   `**Stale after:**` line, 30 days where it has none, said so. PRs by
   `gh pr list --state open --json number,title,headRefName,updatedAt,author`
   where `gh` is on the path and the remote's URL is GitHub's, else a
   line saying they were not read and why. A PR's age in days from its
   ISO timestamp by a days-from-civil sum in awk, since `date` cannot
   parse one portably.
3. **Since the last tag.** `git describe --tags --abbrev=0 <default>`,
   then `git rev-list --count <tag>..<default>` and the summaries of up to
   three of those commits; or "no tag yet" with the count of commits.

The screen, in the shape the user chose, columns fixed so a loop over
projects lines up; the project's name is the folder's, printed on the
first line only:

    guardrails      Plan 10: plans kept in the project, and whe  building, 1 of 7  next: 2, Tests first                18 Oct
                      on claude/trusting-bassi-def90b, not yet on main
                    9 plans landed
                    main: v0.8.0, 1 commit since: Tick plan 9's release, now that v0.8.0 is tagged and pushed.
                    branch claude/trusting-bassi-def90b: not merged by ancestry, 2 ahead, 0 behind, today
                    worktree .claude/worktrees/trusting-bassi-def90b on claude/trusting-bassi-def90b: in use
                    remote origin: no branches besides main; no open PRs

    ooerfish        Fights that differ, fish that get away, and   building, 4 of 5  next: 5, The pass                   17 Oct
                    The painted edge in ooerfish: the plan        building, 5 of 6  next: 5, The pass                   13 Oct
                    The crystal-clear water: the plan             parked, 14 of 14  parked: the four left are dropped   15 Oct
                                                                                     and 4 dropped
                    plans/old.md: refused, the state line is not one of the four: "State: done."
                    uncommitted: 17 files changed in the checkout; 1 stash
                    main: v0.3.0, 0 commits since

    sysmod          no plans/ and no PLAN.md
                    uncommitted: 3 files changed in the checkout
                    main: no tag yet, 212 commits

The words in the git lines are tidy's: merged, not merged by ancestry,
uncommitted, stale, in use. Nothing is recommended; that is the skill's.

### The check: `checks/plans.md`

The state line's grammar is said once, here, and the rules and the skills
point at it, as `checks/dependencies.md` holds the questions the installer
asks. Four sections like every check:

- _What it holds_: every plan says where it stands, in a form a script
  reads; the line and the boxes agree; a landed plan's commit is on the
  default branch; `next` shows only what is open.
- _Its smallest form_: `plans/<name>.md`, the four forms as the code
  block above, the box marks, and `sh guardrails/next`.
- _Seen failing_: a state line misspelt on purpose, refused by name; a
  box ticked past the line, said as a disagreement; a plan file with no
  title, refused.
- _Where it cannot apply_: a project with no plans yet, which the script
  says; one keeping its plans as sections of a `PLAN.md`, read the same
  way; a plan agreed in a harness's own file, copied in when agreed.

A row in `GUARDRAILS.md`'s table, after `landing` and before `mutation`:
"plans | every plan saying where it stands, read by a script, with what
comes next".

### The skill: `next`

`skills/next/SKILL.md`, name `next`. Run `sh guardrails/next` for the
project, or once in each project of a folder; read what it printed, and
say, in one screen: for each refusal, what the state line should say,
read from the file and the git log, not written; for each disagreement,
which is right; for each open plan, the next step in a line, from its
first open box and the check beside it; for each git line, what tidy
would put to the user, by tidy's words, and that tidy settles it; for the
commits since the last tag, whether a release is due (a tick alone is
not), which is the land skill's. Then stop: it writes nothing and changes
nothing, and what to do next is the user's to say. It names no harness,
no project command and no model.

### What else changes

- **`GUARDRAILS.md`.** _Before building_, the plan rule: "and is kept in
  a file" becomes kept in `plans/<name>.md`, named for the work, on the
  work's branch, with the line under its title saying where it stands as
  `checks/plans.md` gives, moved as each box is ticked, so where the work
  stands can be read off the file, and off every plan in a project by
  the `next` skill, at any time. _Reporting_ gains a bullet: **A report
  ends with the next step,** and the plan's state line is moved before
  the report is written, so the file and the chat say the same. The
  table gains the `plans` row. The file stays near its length.
- **`skills/feature/SKILL.md`.** Phase 2's _Parts_ bullet: the checklist
  is written to `plans/<name>.md` the moment the spec is agreed, its
  state line `agreed` with the date, in the form `checks/plans.md` gives;
  where the harness has a plan mode, the spec is written there first and
  copied in when agreed, and the copy is the one ticked. Phase 3 step 5:
  tick the part's box there and move the state line to the next part.
  Phase 5: _Parts_ names the file; the report ends with the next step.
- **`skills/guardrails/SKILL.md`.** Phase 3 writes its plan to
  `plans/<name>.md` with a state line, not "a file the project file
  points to".
- **`skills/land/SKILL.md`.** Step 7, _Clear up_, sets the plan's state
  line to landed, on the default branch at the commit it landed in with
  the date, in a tick commit of its own; where the commit is the push
  itself, the tick follows it. Step 8's report ends with the next step.
- **`skills/tidy/SKILL.md`.** Step 1's read-only run is `sh
guardrails/next`, which it runs first; step 2 gains **the plans**:
  one whose state says agreed or building, on the default branch, with no
  branch holding a different copy, is work whose branch merged or is
  gone; step 4 puts it to the user as landed, or parked with why, and
  step 5 writes the line only on the user's word. The five kinds stay.
- **`templates/AGENTS.md`.** Under _Commands_:
  `sh guardrails/next      where every plan in plans/ stands, and what comes next`.
- **`INSTALL.md`.** _Installing_ step 1 copies the kit's `next` to
  `guardrails/next`, made executable where the system has such a thing,
  and the comparison in _Updating_ step 1 covers it; the lines to add to
  a project's own `AGENTS.md` include the command; a line says the kit
  writes nothing in `plans/`, which the first plan makes.
- **`README.md`.** _What is in it_ lists `next` and the eight skills
  (the listing names five today); _Installing_'s kit-own list gains
  `guardrails/next`; a short paragraph, _Where work stands_, says where
  plans go and what `next` prints; a `v0.9.0` row in the release table.
- **This kit's `AGENTS.md`.** `sh next` under _Commands_; _Layout_ names
  `next` and `plans/`'s stand-in, `PLAN.md`.
- **Tests.** `tests/test_skills.sh`'s `SKILLS` gains `next`;
  `tests/test_standards.sh`'s `CHECK_ORDER` gains `plans` after
  `landing`; `tests/test_install_doc.sh`'s paths gain `guardrails/next`.
  New: `tests/test_next.sh` holds the script, `tests/test_plans.sh` holds
  the words.

### The kit's own plans

Each of plans 1 to 9 in `PLAN.md` gets its state line under its title,
landed on `main` at the commit the next plan was written on (plan 1 at
`e9f257c`, plan 2 at `523d208`, and so on, each read from the next plan's
own "Written on" line) or at its tag's commit for plan 9 (`adacda4`),
with the commit's date from `git log -1 --format=%cs`. Plan 10's line says
agreed, then building as its parts are ticked, then landed in the tick
commit after the release. `sh next` run at the kit's root then prints
something true, which is part 6's first check.

## Out of scope

- This machine's loop over every project, which lives in `~/.claude` and
  comes after the release.
- Taking `v0.9.0` into ooergolf, artshape-sound or any project, which
  each do by `INSTALL.md` on the user's word, and moving ooerfish's
  `docs/` plans into `plans/`.
- A kept summary file of any kind, and anything that asks a harness about
  its sessions.
- A Windows run: nothing here is on one. What stands in is the `dash` run
  in the tests, and that the script asks for nothing Git for Windows does
  not bring.

## Parts

- [x] **1. The plan into `PLAN.md`,** as plan 10, with its state line, and
      the nine before it given theirs. _Check:_ the lines are there, each
      hash on `main` (`git merge-base --is-ancestor`), and the plan reads
      as the others do.
- [x] **2. Tests first,** each seen failing on the kit as it stands
      (`tests/run next` and `tests/run plans` red), with the fixtures
      made under `mktemp -d` and never a real checkout:
      - `test_next_open_plan_prints_its_next_step`: building, part 3 of
        4, two boxes ticked: the row has `building, 2 of 4`, `next: 3,`
        and the box's text; the date is the fixture's commit date.
      - `test_next_agreed_plan_prints_its_first_step`: `agreed, 0 of 3`,
        `next: 1,`.
      - `test_next_parked_plan_prints_why`: `parked:` and the why.
      - `test_next_nothing_open_says_so`: one landed plan: "nothing
        open", the plan named, "1 plan landed".
      - `test_next_refuses_a_malformed_state_line_by_name`: a misspelt
        line, and a plan with none: each refused with the file and title,
        the line quoted, exit status non-zero, and the other plans in the
        folder still printed.
      - `test_next_says_when_the_line_and_the_boxes_disagree`: part 2 of
        5 written, three boxes ticked: both facts on the line under the
        row; `agreed` with a box ticked; `building` with every box
        ticked.
      - `test_next_reads_plan_sections_too`: a `PLAN.md` of two plans, one
        landed and one building, with a `# ` line and a box inside a
        fenced block: one row, "1 plan landed", and the fenced lines not
        read.
      - `test_next_counts_a_dropped_box_apart`: `[-]` out of m and said as
        dropped; a box indented under another not counted.
      - `test_next_says_where_the_plan_is`: on a branch, the row says so
        and that it is not on the default; on the default with no branch
        differing, "no branch is at work on it"; with a branch differing,
        that branch named.
      - `test_next_finds_what_tidy_would`: on `tests/make-leftovers`'s
        project, each thing by tidy's word: `merged` merged, `squashed`
        and `unmerged` not merged by ancestry, one stash, the uncommitted
        change, `wt-done` clean and merged, `wt-locked` in use,
        `origin/landed` merged, `origin/cloud` not merged by ancestry.
      - `test_next_calls_stale_by_the_project_file`: `**Stale after:** 2
        days` and a branch committed three days ago (`GIT_COMMITTER_DATE`)
        called stale, one of yesterday not; no project file, 30 days and
        said so.
      - `test_next_says_what_landed_since_the_last_tag`: a tag and two
        commits after it, "2 commits since v0.1.0" with their summaries;
        no tag, "no tag yet".
      - `test_next_reads_the_default_branch_and_not_main`: a remote whose
        default is `trunk`, judged against it.
      - `test_next_writes_nothing`: the tree's files, the refs, the stash
        list and the index unchanged by a run, by fingerprint before and
        after.
      - `test_next_runs_under_dash`: the open-plan and leftovers fixtures
        under `dash`, skipped with 77 where there is none.
      - `test_next_forms_in_the_check_are_the_ones_the_script_takes`: each
        `State:` line of the code block in `checks/plans.md` accepted, and
        `State: done.` refused: the check and the script held equal.
      - `test_plans_rule_names_the_place_and_the_check`: _Before building_
        names `plans/` and `checks/plans.md`; _Reporting_ has a bullet
        starting "A report ends with the next step" that names the state
        line; the table's order has `plans` after `landing`.
      - `test_plans_skills_say_the_same_thing`: the feature and guardrails
        skills write to `plans/`; the feature skill ticks there and names
        `checks/plans.md`; the land skill sets the line to landed in its
        clear-up step; the tidy skill runs the script and names a plan
        "no branch is at work on"; the `next` skill says it writes
        nothing and runs `guardrails/next`.
      - `test_plans_template_and_installer_name_the_script`: the template's
        _Commands_ has `next`; `INSTALL.md` names `guardrails/next` in
        _Installing_ and _Updating_, and says `plans/` is not written.

      _Check:_ `tests/run next` and `tests/run plans` red first, every
      function failing for the reason its name gives.

- [x] **3. The script.** `next` at the kit's root, executable, header
      saying what it is for and what would go wrong without it, each
      section a function, the plan parser in one awk program. _Check:_
      `tests/run next` green under `sh` and `dash`; each test
      mutation-checked (a fault put in the script, the test seen to name
      it, the fault taken out), the mutations listed here when done.

      Mutation checks, each put into `next`, the test seen to name it,
      and taken out again:
      - a ticked box counted open: `building, 1 of 3` not said
      - the fence flag dropped: `Not a heading` said
      - a dropped box counted in m: `2 of 4` where `1 of 3` was held
      - `parked` taken with nothing after it: survived, until a bare
        `State: parked` joined the refusals test; then refused by name
      - the disagreement line printed for every plan: "the state line
        says" said where it should not be
      - `is-ancestor` inverted: `branch old: merged`
      - `, stale` on every branch: a branch of yesterday called stale
      - the locked worktree's judgement swapped: both worktree tests
      - the tag's commits counted from the wrong side: `2 commits since`
        not said
      - `git status` in place of `diff-index`: survived while
        `GIT_OPTIONAL_LOCKS=0` stands, since git then skips the index
        refresh; with both gone, `test_next_writes_nothing` names
        `.git/index`
      - the folder name's padding dropped: survived, until the first
        line was held to the name padded to 16 columns

      One case added, since the fixture's locked worktree is changed as
      well as locked: built with `FIXTURE_BREAK=locked`, it reads
      `in use (changed in the last hour)`. The script runs in 0.7 s on
      this repository.
- [x] **4. The check and the skill.** `checks/plans.md` and
      `skills/next/SKILL.md`. _Check:_ `tests/run` green with
      `PRETTIER=~/projects/artshape-game-template/node_modules/.bin/prettier`,
      the checks, skills, standards and format tests included.
- [x] **5. The rules, the four skills, the template, the installer, the
      README,** and this kit's `AGENTS.md`, as _What else changes_ says.
      _Check:_ `tests/run` green; each `test_plans_*` mutation-checked;
      every file touched read through for what it says and in the house
      voice.

      Mutation checks: each phrase `tests/test_plans.sh` holds was taken
      out of its file, the test seen to name it, and put back. Two
      phrases appear twice, `no branch is at work on` in the tidy skill
      and `plans/` in the guardrails skill, and both copies had to go
      before the test failed. Read through afterwards: two paragraphs of
      `INSTALL.md` rewrapped, and `AGENTS.md`'s _What is not held_ given
      the script on Windows.
- [x] **6. Trial.**
      - `sh next` at the kit's root, in this worktree and in the main
        checkout: plan 10 the one open plan, nine landed, the branch and
        worktree named, the one commit since `v0.8.0`. Kept for the
        hand-back as printed.
      - The script over every git project under `~/projects`, read only,
        timed, with each project's tree, refs and stash list
        fingerprinted before and after and seen unchanged; what it says
        of artshape-sound's `PLAN.md` (refused, no state line: true until
        that project takes the kit in) and of ooergolf's checkout.
      - The `next` skill followed by a builder agent on the cheaper
        model in a throwaway project made from `tests/make-leftovers`
        with a `plans/` of one of each state and one refusal: its report
        read here against the fixture, nothing written by it, and what it
        had to guess put into the skill.
      - `INSTALL.md` followed by a builder agent on the cheaper model
        into a throwaway clone of a real project, from this local kit,
        as the kit's own _Done, here_ asks of any change to the
        installer: `guardrails/next` arrives byte for byte and
        executable, `sh guardrails/next` runs there, and the clone's
        diff is read against what the file says should have happened.

      _Check:_ the figures and the screens kept for "What plan 10's trial
      found", and every throwaway folder deleted.

- [ ] **7. Release `v0.9.0`.** The commit, the tag and the pushes, each
      only on the user's word; then the tick commit that sets plan 10's
      line to landed.

## Decided

- **A script, not a model, prints the screen,** as the user recommended:
  the kit's checks are already the project's own scripts, its tests are
  shell, and a machine can run it over every checkout in one loop. The
  skill is the agent's reading of its output.
- **The script lives at the kit's root as `next`,** so a project gets it
  as `guardrails/next`, one copy at a path every harness and a loop can
  call, installed and updated like the rules. The other place considered
  was inside the skill's folder, which the Agent Skills specification
  allows: that is two copies in a project with both harness folders, at a
  path that differs by harness.
- **The grammar lives in `checks/plans.md`,** said once, with the rules
  and the skills pointing at it, and a test holding the script to the
  forms the check gives. The other place was the `next` skill alone,
  which the feature skill would then have to read to write a plan.
- **Every top-level box counts, and `[-]` is dropped,** read off the
  user's own plans: ooergolf's two questions above its parts are its
  "next", and its dropped part 9 is `[-]`. A box whose text says dropped
  but is still `[ ]` is open to the script, and the skill says so.
- **The date column is git's,** the last commit touching the plan file,
  never a date kept by hand, with `uncommitted` where the file has
  changes.
- **The state line's `n of m` is held equal to the boxes** by the script,
  as the rules hold anything said twice, and a disagreement is printed
  with both facts, not guessed at.
- **`v0.9.0`**: a check, a skill and a script are added, and the table
  every project's file points at gains a row.

## Decided by the user, and changed while building

On 2026-10-18 the plan was agreed as written, the three recommendations
with it: the first open box only on a plan's row, the read-only run of
tidy being this script, and the nine landed plans given their lines in
part 1.

Changed while building: part 6 gains a trial of the installer, which the
kit's own _Done, here_ asks of any change to `INSTALL.md`.

## Open for the user (as written; answered above)

- **The first open box only,** on the plan's row, with the skill reading
  the rest from the file: recommended, since a plan with ten open boxes
  would otherwise take the screen. The alternative is every open box, one
  a line under the row, as the user's sketch listed ooergolf's two.
- **The read-only run of tidy is this script,** so that the judgement has
  one implementation and tidy's own find then fetches and judges by tree
  what the script called not merged by ancestry: recommended. The
  alternative keeps tidy's find as words of its own, with the script
  beside it.
- **The nine landed plans get their lines now,** in part 1, so `sh next`
  on the kit says something true on the first run: recommended; nine
  lines, hashes read from the plans themselves. The alternative leaves
  them, and the script refuses each by name until they are added.

## What plan 10's trial found

Run 2026-10-18, on this machine.

- **On this repository,** in the worktree the work is in: plan 10 the
  one open plan, `building, 5 of 7`, `next: 6, Trial`, dated
  `uncommitted`; nine plans landed; the branch merged by ancestry, since
  its work is not yet committed; the main checkout listed as a worktree,
  clean and merged; no open PRs; `main: v0.8.0, 1 commit since`, the
  tick named. 0.7 s, under `sh` and `dash` alike. In the main checkout,
  on `main` as it stands: the nine plans refused by name, each "no state
  line under" its title, which is true until this lands; the worktree in
  use (changed in the last hour); exit 1.
- **Over every git project under `~/projects`,** forty-eight of them, read
  only, in one loop: 66 s in all, none over 3 s, and no project's refs,
  stash list, tree or index moved, by a fingerprint taken before and
  after each run. Forty-six have no `plans/` and no `PLAN.md`.
  artshape-sound's `PLAN.md` is refused by name, no state line under
  its title, true until it takes the kit in, and its screen says what
  git does: three commits on `main` not pushed, three since `v0.2.0`,
  each named. ooergolf and ooerfish are clean with no tag; ooergolf's
  `GUARDRAILS-PLAN.md` is not read, by design, and its screen says it
  has no `plans/`. Four projects have no remote, and their PRs are said
  to be not read for that reason. The game template shows four merged
  `claude/…` branches with their worktrees, which is tidy's to settle.
- **The installer, fresh, into a throwaway clone of sysmod,** by an
  agent on the cheaper model, from a throwaway copy of the kit tagged
  `v0.9.0`: 44 files written and none of the project's touched, the one
  file it would have written and did not being the project's own
  `CLAUDE.md`, with the `@AGENTS.md` line first in its report;
  `guardrails/next` byte for byte with the kit's and executable, checked
  here; `sh guardrails/next` run in the clone and true: no plans, the
  filled-in threshold read, 44 files untracked, no tag. Of the fourteen
  things the agent found unclear in `INSTALL.md`, one was this plan's:
  the byte-for-byte check did not cover the executable bit, which the
  check step now names. The rest predate it and are named in the
  hand-back, not done: the `[updates]` line's answer has stood
  unbracketed since plan 9, so "replace the bracketed default" has
  nothing to replace; step 5's "a difference is put right" reads against
  step 3's filled-in answers; _Before anything_ names files under
  `guardrails/` that a fresh install does not have yet; and the file
  never says what the kit's own repo looks like, nor where a hook the
  project had already might be.
- **The installer, updating a throwaway clone of ooergolf** from
  `v0.5.0`, by an agent on the cheaper model, from the same throwaway
  kit: no hand edit found, the diff shown, and on the yes the rules,
  eight checks and the two kit-owned skills replaced, `plans.md`,
  `guardrails/next`, `next` and `tidy` added, `ci.md` removed, the
  project's own four skills untouched, the record rewritten; every file
  byte for byte with the kit's, checked here, the script executable;
  `sh guardrails/next` true in the clone. Four things it had to guess
  were this plan's, and are now said in _Updating_: the diff step shows
  the script too, a file neither copy has is no difference, the write
  step makes the script executable, and the report gives the lines the
  project's own `AGENTS.md` lacks. Named, not done: the landing
  questions are read from the project's installed copy, which lacks the
  third, where the dependency questions are read from the newer kit's;
  an old answer that no longer matches a reworded question has no rule;
  and the example folder in _Updating_'s opening is one the record may
  list as the project's own.
- **The `next` skill, followed by an agent on the cheaper model** in a
  throwaway project made from `tests/make-leftovers` with a plan of each
  state and one with no state line: its report read the screen rightly,
  the refusal, the question box as the user's, the parked plan, the two
  plans no branch is at work on, and every branch, worktree and stash by
  tidy's words, the locked worktree's branch in use with it; nothing was
  written, by a fingerprint of the project taken before and after. What
  it had to guess, and what changed because of it:
  - the screen cut a parked why and a question box at forty characters,
    losing "release." and the question mark; nothing is cut now
  - a landed plan naming a commit the repository does not have was
    counted landed without a word; the commit is checked against the
    default branch and said
  - the checkout's own fresh change was not called in use, where a
    worktree's would be; it is now
  - `git diff-index` calls a file touched and unchanged changed, since
    it reads no contents; the tree is read with `git status --porcelain`
    under `GIT_OPTIONAL_LOCKS=0`, which compares contents and writes no
    index
  - the lock's reason, the relative path of a worktree under the
    project, a branch in use with its worktree, and the newest commits
    where there is no tag, each now printed
  - the skill said "a bullet a kind of line" and had none for a third of
    the lines; said "stopped" of an agreed plan that is waiting on its
    first question; sent the reader to the file only for a refusal, when
    the check beside a box is only in the file; and had its report lead
    two ways at once. Each is said now, with the form a refused plan's
    boxes give, and tidy's in-use command is the script's `-mmin -60`,
    since one shell's `find` refused `-newermt`.

After those changes, run again on the same fixture: the question box in
full with its question mark, the parked why to its full stop, the landed
plan said to name a commit `main` does not have, the checkout's fresh
change called in use, `in use (locked): a session at work`, the locked
worktree's branch in use with it, and the three newest commits under
"no tag yet". `tests/run` is 72 green with prettier, under `sh` and
`dash`; `sh next .` on this repository takes 1.2 s, most of it `gh`.
Not verified: the `sh` Git for Windows installs, and `gh` against a
remote that refuses it.
