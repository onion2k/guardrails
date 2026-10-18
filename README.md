# guardrails

A kit of plain files that gives a project the dev loop it needs to change
safely, whoever is doing the changing: a person, or an agent in any harness
on any model. It is the rules, the checks a project stacks up, the
definition of done, and the skills that work through them, taken from a
line of browser games where a bug, a slow frame or a lost save is seen at
once, and written so that a package, a site, a service or a tool can hold
itself to the same.

It is written for Claude first, and needs nothing from Claude to work.

## What is in it

    GUARDRAILS.md        the rules: structure, verifying, the definition of done
    checks/              one file per check: what it holds, its smallest form,
                         how it is seen to fail, and what stands in where it cannot apply
    templates/           the project file (AGENTS.md), the files that point each
                         harness at it, and the pre-commit hook
    skills/              guardrails, feature, bug, gate-moved, commit
    INSTALL.md           the installer: an agent follows it to put the kit in, or update it
    tests/run            the kit's own checks

## Putting it in a project

Tell the agent working in the project, in any harness:

    Follow https://github.com/onion2k/guardrails/blob/main/INSTALL.md to install the guardrails kit here.

What it writes, and what it will not, is in [Installing](#installing).
Then, in the project, run the `guardrails` skill: it reads the project,
says which checks it has and which it has not, and takes it up them one at
a time, each seen failing before it is trusted.

## How each harness reads it

Checked against each vendor's own documentation on 2026-10-17. A harness
changes faster than a kit, so this is looked up again before it is relied
on, and the date moved.

| Harness     | Reads the project file                                       | Expands `@file`         | Finds skills in                                         |
| ----------- | ------------------------------------------------------------ | ----------------------- | ------------------------------------------------------- |
| Claude Code | `CLAUDE.md`; `AGENTS.md` only where no `CLAUDE.md` is found  | yes, four hops deep     | `.claude/skills/`                                       |
| Codex CLI   | `AGENTS.md`                                                  | no                      | `.agents/skills/`                                       |
| Gemini CLI  | `GEMINI.md`; `AGENTS.md` only if `context.fileName` names it | yes                     | `.agents/skills/`, `.gemini/skills/`                    |
| Cursor      | `AGENTS.md`, and `.cursor/rules/*.mdc`                       | no: names the file only | `.agents/skills/`, `.cursor/skills/`, `.claude/skills/` |

What the kit does about it:

- **`AGENTS.md` is the project file,** and the only one with anything in
  it. `CLAUDE.md` and `GEMINI.md` are one line each, `@AGENTS.md`. Claude
  Code's own docs give that import as the way that works in every session,
  including those where it cannot read `AGENTS.md` by itself, and it never
  loads the file twice.
- **`GUARDRAILS.md` is reached two ways at once.** The project file says
  to read it before changing anything, in words, and imports it with
  `@GUARDRAILS.md` on the same line. A harness that expands imports has it
  in context from the start; one that does not is told to read it, and
  does. The import is written in plain text: Claude Code ignores one inside
  a code span.
- **Skills are written to the Agent Skills specification** (agentskills.io):
  `name` and `description` only, the name the same as the folder, lowercase
  with hyphens, the description under 1,024 characters. That is the most
  any of the four asks. Cursor is the strictest about it; Claude Code the
  least.
- **Skills are copied to `.agents/skills/` and `.claude/skills/`.** Codex,
  Gemini CLI and Cursor read the first, and Claude Code only the second.
  They are copies and not a link, so a clone works on any machine and in
  any harness without anything set up.
- **No skill names a harness's own tool,** a model, or a product. Where a
  harness has a plan mode, a question box or a way to start another agent,
  the skill says what it is for, and a harness that has one uses it.
- **What holds the line is git's and the project's,** not a harness's: a
  pre-commit hook and the project's own `check` and quick check. A harness
  hook holds only the agents that run in that harness.

Sources:
[Claude Code, memory](https://code.claude.com/docs/en/memory),
[Claude Code, skills](https://code.claude.com/docs/en/skills),
[Codex, AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md),
[Codex, skills](https://learn.chatgpt.com/docs/build-skills),
[Gemini CLI, GEMINI.md](https://google-gemini.github.io/gemini-cli/docs/cli/gemini-md.html),
[Gemini CLI, skills](https://geminicli.com/docs/cli/skills/),
[Cursor, rules](https://cursor.com/docs/context/rules),
[Cursor, skills](https://cursor.com/docs/context/skills),
[Agent Skills specification](https://agentskills.io/specification).

Not settled from the docs:

- **Gemini CLI's skills page** was found only at `geminicli.com`, which
  may not be Google's own; its page under `google-gemini.github.io` was
  missing. The folders it gives agree with Cursor's and Codex's.
- **Cursor reads both skill folders,** so it may list each skill twice.
  Cursor's docs do not say what it does with two of the same name.
  The install asks which harnesses a project uses, and leaves out a
  folder it does not need.
- **Codex has no import**, and its docs say nothing of reading
  `CLAUDE.md`. Neither matters here: it reads `AGENTS.md`, and is told in
  words to read `GUARDRAILS.md`.

## How a change lands on a GitHub remote

Read as a stranger on 2026-10-17, with `gh api`:

| Repo               | Default branch | `protected` | Ruleset rule types on it                             |
| ------------------ | -------------- | ----------- | ---------------------------------------------------- |
| cli/cli            | `trunk`        | true        | copilot_code_review                                  |
| microsoft/vscode   | `main`         | true        | deletion, non_fast_forward, pull_request, …          |
| facebook/react     | `main`         | true        | deletion, non_fast_forward, pull_request             |
| github/docs        | `main`         | true        | pull_request, merge_queue, required_status_checks, … |
| golang/go          | `master`       | true        | none                                                 |
| onion2k/guardrails | `main`         | false       | none                                                 |

What the kit does about it:

- **The default branch is read, never assumed to be `main`:**
  `gh api repos/<owner>/<repo> --jq .default_branch`.
- **A change lands by PR** where `gh api repos/<owner>/<repo>/branches/<default>`
  says `protected: true`, or where `gh api repos/<owner>/<repo>/rules/branches/<default>`
  lists a rule of type `pull_request`, `update` or `merge_queue`.
  Both are readable by anyone who can read the repo; the protection's
  detail, at `.../protection`, is not.
- **A push the remote refuses** stops the work, is said, and the change
  goes by PR instead.

Not settled: whether a ruleset alone, with no classic protection, sets
`protected`. Every repo read above that had rulesets also reported
`protected: true`. Only a repo of one's own can show it, and none was to
hand, so the kit reads both and counts either.

## Installing

There is no script to run: an agent installs the kit by following
[INSTALL.md](INSTALL.md), so it works on any system with git, Windows
included, and in any harness. It asks which harnesses the project uses,
gets the kit at its newest tag, and writes two kinds of file, which it
treats differently.

**The kit's own,** which a newer kit replaces:

    guardrails/GUARDRAILS.md
    guardrails/checks/*.md
    guardrails/INSTALLED.md   the version, the harnesses, and which skill folders are the kit's
    .agents/skills/<skill>/   for Codex, Gemini CLI and Cursor
    .claude/skills/<skill>/   for Claude Code

These are not edited in the project. A change to a rule is made in the kit
and released; a rule the project keeps beyond the kit's goes in its own
`AGENTS.md`. To update, tell the agent to follow `INSTALL.md` again, or run
the `guardrails` skill, which does so first. A kit file edited by hand
since it was installed stops the update, named, so that nothing is lost,
and a newer kit is shown as a diff and taken in only on a yes.

**The project's own,** written once from `templates/`, where there is
none, and never over one that is there:

    AGENTS.md                 the project file, every heading still to be written
    CLAUDE.md, GEMINI.md      one line each: @AGENTS.md
    .githooks/pre-commit      refuses every commit until its quick check is named

Where one is there already, the agent says what to add to it. A skill
folder the project already has, of the same name as one of the kit's, is
the project's own and is left alone.

The hook is not running until the project's quick check is named in it and
git is pointed at `.githooks`. The `guardrails` skill does both, and asks
first.

### Releases

Each release is a git tag, `v0.1.0` and on. `INSTALL.md` installs the
newest, and an update compares the project's files with the kit at the tag
it has, which is how a hand edit is told from the kit's own.

| Tag      | What changed                                                                                                                                |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `v0.1.0` | The first: the rules, eleven checks, five skills, installed by an agent alone.                                                              |
| `v0.2.0` | Formatting, lint, structure and verification as checks of their own; the quick check points at them.                                        |
| `v0.3.0` | How a change lands: the remote's protection picks push or PR, merge style and grants asked at install, the land skill, the commit-msg hook. |
| `v0.4.0` | Dependencies: a rule that one is taken in on purpose, and a check for exact installs, advisories, licences, unused packages and updates.    |
| `v0.5.0` | Security: secrets kept out of the tree, code scanning, CI held to least access and pinned actions, and a served page's headers.             |
| `v0.6.0` | Nothing left behind: the tidy skill finds what work left anywhere, says what each is, and settles it on the user's word.                    |
| `v0.7.0` | Mutation: the hand check's line says what was changed, and a mutation tool's survivors are a gate, counted per file and held exactly.       |

## Left out on purpose

The rules began as one person's house rules for their own machine. What
was left out of `GUARDRAILS.md`, and why:

- **Starting a new game from a template,** and what a game finds wrong
  with its template being put right there too. That is about one line of
  games, not about how a change is made.
- **The house rules for websites** (an accessibility bar, the look chosen
  and not defaulted, the words the author's). They are a matter of one
  person's taste and one person's bar, and a project that wants them says
  so in its own file.
- **Names of models, products and tools:** a plan made "on opus, in plan
  mode", screenshots "with Playwright", "the in-app browser pane". Each is
  said by what it is for, so that the rule holds in a harness that has
  something else.
