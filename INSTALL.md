# Installing the kit

This file is the installer. An agent follows it, in whatever harness and
on whatever system, to put the guardrails kit into a project, and later to
take a newer kit in. It asks nothing of the machine but git. A user starts
it by telling their agent to follow this file, by its address on GitHub or
by a path to a copy of the kit.

Three promises hold through every step, and an agent that cannot keep one
stops and says so:

- **Nothing of the project's is written over.** A file the project has is
  the project's, and what the kit would have put there is said, not
  written.
- **A newer kit is shown before it is taken in,** as a diff, and taken in
  only on the user's yes.
- **A hand edit is never lost.** A kit file changed in the project since
  it was installed stops an update, named.

## Before anything

1. **The project:** the folder the user named, or the one the agent is
   working in. It must be a git repo; see _No git_ under _Refusals_.
2. **The work tree is clean,** or what is not clean is said, so that what
   the kit writes can be told apart from what was there. Nothing of
   another person's or session's is committed, stashed, reset or
   reformatted.
3. **Which harnesses,** asked of the user, with all four as the
   recommendation:

   | Harness     | Reads skills from | Pointer file it needs |
   | ----------- | ----------------- | --------------------- |
   | Claude Code | `.claude/skills/` | `CLAUDE.md`           |
   | Codex       | `.agents/skills/` | none                  |
   | Gemini CLI  | `.agents/skills/` | `GEMINI.md`           |
   | Cursor      | `.agents/skills/` | none                  |

   Cursor reads `.claude/skills/` as well, so with both it may list each
   skill twice. That is said, and left to the user.

## Getting the kit

The kit is released as git tags, `v0.1.0` and on. The newest is the
highest version among

    git ls-remote --tags https://github.com/onion2k/guardrails.git

and a copy of it is made in a temporary folder, outside the project:

    git clone --depth 1 --branch <tag> https://github.com/onion2k/guardrails.git <temporary folder>

Where the user names a local copy of the kit instead, that copy is used,
at the tag they name, or as it stands if they name none; the version
recorded is then the tag, or the commit's hash. The temporary folder is
deleted at the end, whatever happened.

## Installing

Where the project has no `guardrails/` folder.

1. **The rules.** Copy the kit's `GUARDRAILS.md` to
   `guardrails/GUARDRAILS.md`, and its `checks/` to `guardrails/checks/`,
   file for file, byte for byte. Nothing in them is changed, formatted or
   wrapped: an update tells a hand edit from the kit by comparing bytes.
2. **The skills.** For each skill folder in the kit's `skills/`, and for
   each skills folder the chosen harnesses read (`.agents/skills/`,
   `.claude/skills/`, or both):
   - where the project has no folder of that name there, copy the kit's
     folder in, every file, byte for byte;
   - where it has one, it is the project's own, and is left exactly as it
     is. Say so.
3. **The project file and its pointers,** each only where the project has
   none:
   - `AGENTS.md`, from `templates/AGENTS.md`
   - `CLAUDE.md`, from `templates/CLAUDE.md`, for Claude Code
   - `GEMINI.md`, from `templates/GEMINI.md`, for Gemini CLI
   - `.githooks/pre-commit`, from `templates/pre-commit`, made executable
     where the system has such a thing

   These are the project's from then on, and an update never touches
   them.

4. **The record.** Write `guardrails/INSTALLED.md`, in this shape:

       # What the guardrails kit put here

       version: v0.1.0
       harnesses: claude code, codex, gemini cli, cursor

       The kit's, replaced by an update:

       - .agents/skills/bug
       - .claude/skills/bug

       The project's own, left alone:

       - .claude/skills/feature

   It is the only file the agent writes in `guardrails/` itself, and it
   is how an update tells the kit's folders from the project's.

5. **What is left for the project,** said to the user, each only where it
   applies:
   - **A project file of its own.** Where `AGENTS.md` was there already
     and does not name the rules, the line to add near its top is:

         Read guardrails/GUARDRAILS.md before changing anything: @guardrails/GUARDRAILS.md

     and each heading of `templates/AGENTS.md` it lacks is listed: the
     skills look for them by name.

   - **A pointer file of its own.** Where `CLAUDE.md` or `GEMINI.md` was
     there already and does not bring in `@AGENTS.md`, that harness never
     sees the kit. The line to add at its top is `@AGENTS.md`. This is
     said first, as the one change without which nothing else here reaches
     that harness.
   - **A formatter.** Where the project has one (a prettier, biome or
     dprint config), it is told to leave `guardrails/` and the kit's skill
     folders alone. The kit's files are formatted as prettier formats them
     by default; a formatter that writes over them turns the next update
     into a hand edit.
   - **The hook.** A hook the project had already is left, and should run
     its quick check. The kit's own refuses every commit until its
     `QUICK_CHECK` is named, and runs only once git is pointed at its
     folder with `git config core.hooksPath .githooks`. Both are the
     `guardrails` skill's to do, and it asks first.
6. **Report:** every file written, every file left as the project's,
   and that nothing is committed. The next step is the `guardrails` skill,
   run in the project.

## Updating

Where the project has a `guardrails/` folder with
`guardrails/INSTALLED.md` in it. Two copies of the kit are got as
_Getting the kit_ says: the **installed** one, at the version the record
names, and the **newer** one.

1. **Hand edits first.** Compare, byte for byte, the project's
   `guardrails/GUARDRAILS.md`, each file of `guardrails/checks/`, and each
   skill folder the record lists as the kit's, with the same files in the
   installed copy. Any difference, a file added or a file gone is a hand
   edit: see _A hand edit_. Nothing is written.
2. **The diff.** Show the user the difference between the installed copy
   and the newer one, in the files the project has: the rules, the checks,
   and the skills the record lists as the kit's. A skill new in the newer
   kit is listed as one that would be added, unless the project has a
   folder of that name, which stays its own.
3. **Wait for the user's yes.** Without it nothing is written.
4. **Write.** Replace the rules, the checks and the kit's skill folders
   with the newer kit's, byte for byte; remove a check or a skill the
   newer kit no longer has; add the new ones. The project's own files and
   folders are not touched. Update `guardrails/INSTALLED.md` to the newer
   version, and its lists to what is now there.
5. **Report** what changed, by file, and that nothing is committed. Where
   the newer kit's templates have changed, say what changed in them: the
   project's files made from them are its own, and taking a change in is
   the user's call.

## Refusals

Each stops the work before anything is written, and is said to the user
by name, with what to do about it.

### A hand edit

A kit file in the project differs from the kit at the installed version.
Name every file, with its diff. A change to a rule belongs in the kit,
where every project gets it, or in the project's own `AGENTS.md`; once it
is there, the file is put back as the kit had it, and the update run
again.

### A guardrails folder the kit did not write

A `guardrails/` folder with no `guardrails/INSTALLED.md` in it is not the
kit's, and nothing in it is read or written. The user renames it, or says
where the kit should go instead.

### The kit itself

The project is the kit's own repo. The kit is not installed into itself.

### No git

The project is not a git repo, or git is not on the machine. Without git
the kit cannot be got, the hook cannot run, and nothing the agent writes
can be told from what was there. The user makes it a repo first.
