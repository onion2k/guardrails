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
    install.sh           puts the kit into a project
    tests/run            the kit's own checks

## Putting it in a project

    ./install.sh ~/projects/some-project

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
  `install.sh --harness` leaves out the folder a project does not need.
- **Codex has no import**, and its docs say nothing of reading
  `CLAUDE.md`. Neither matters here: it reads `AGENTS.md`, and is told in
  words to read `GUARDRAILS.md`.

## Installing

    ./install.sh <project> [--harness claude,codex,gemini,cursor] [--yes]

All four harnesses are the default. `--harness` leaves out what a project
does not use: `codex` alone writes no `.claude/` and no `CLAUDE.md`.

It writes two kinds of file, and treats them differently.

**The kit's own,** which a newer kit replaces:

    guardrails/GUARDRAILS.md
    guardrails/checks/*.md
    guardrails/VERSION
    guardrails/MANIFEST       what was written, so an edit can be told from an update
    .agents/skills/<skill>/   for Codex, Gemini CLI and Cursor
    .claude/skills/<skill>/   for Claude Code

These are not edited in the project. A change to a rule is made in the kit
and installed again; a rule the project keeps beyond the kit's goes in its
own `AGENTS.md`. Installed again, a kit that has changed shows its diff and
writes nothing until `--yes` is given, and a file edited by hand since it
was installed stops the update altogether, named, so that nothing is lost.

**The project's own,** written once from `templates/`, where there is
none, and never over one that is there:

    AGENTS.md                 the project file, every heading still to be written
    CLAUDE.md, GEMINI.md      one line each: @AGENTS.md
    .githooks/pre-commit      refuses every commit until its quick check is named

Where one is there already, the installer prints what to add to it. A
skill folder the project already has, of the same name as one of the
kit's, is the project's own and is left alone, and the installer says so.

The hook is not running until the project's quick check is named in it and
git is pointed at `.githooks`. The `guardrails` skill does both, and asks
first.

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
