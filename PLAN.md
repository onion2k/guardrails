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


---

# Plan 4: how a change lands

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
- **Not verified:** the planted key refused by the gitleaks hook, and a
  history scan, since gitleaks is not installed here; and zizmor run on
  the workflows, which were read by eye against `ci.md` instead. The
  hook's line is the one gitleaks' own pre-commit hook runs.

