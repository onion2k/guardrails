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

This holds for an update as much as for an install.

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

   The skills folders written are every folder the chosen harnesses read,
   so all four means both. Cursor reads `.claude/skills/` as well, so with
   both it may list each skill twice. That is said, and left to the user.
   On an update, the user is asked whether the harnesses are still the
   ones the record names.

4. **Dependencies,** the three questions under _The questions a project
   answers_ in `guardrails/checks/dependencies.md`, asked as they are
   written there, each with its recommendation: the **audit threshold**,
   the **allowed licences**, and **how updates arrive**. The answers go
   into the project file's _Gates_ and _Commands_. On an update, they are
   read from the newer kit's copy of that file, and asked only where the
   project file has no answers yet; a bracketed default is no answer.
   Since an update never writes the project file, the answers are given
   to the user as the lines to add.
5. **How a change lands,** the three questions at the end of
   `guardrails/GUARDRAILS.md`'s _Landing a change_, asked as they are
   written there, each with its recommendation:
   - the **merge style**: a merge commit, squash, or rebase
   - **what an agent may do without asking**: nothing, or push and open
     PRs. A yes is a grant, recorded with who gave it and the date.
     Merging and tagging are asked each time, whatever the answer.
   - the **stale threshold**: 30 days, or the project's own

   On an update, these are asked only where the project file has no
   answers to them yet.

## Getting the kit

The kit is released as git tags, `v0.1.0` and on. The newest is the
highest version among

    git ls-remote --tags https://github.com/onion2k/guardrails.git

compared as versions, number by number, not as text; a line ending in
`^{}` is the same tag again, and is passed over. A copy of the kit at a
tag is made in a temporary folder, outside the project:

    git clone --depth 1 --branch <tag> https://github.com/onion2k/guardrails.git <temporary folder>

Where the user names a local copy of the kit instead, that copy is used
the same way: its tags are listed by `git ls-remote --tags <path>`, and it
is cloned without `--depth`, which git ignores for a local path. It
is used at the tag the user names, or at its newest; where it has no tags,
at its commit, and the version recorded is then the commit's hash, got
again later with `git checkout <hash>` in a fresh clone.

The temporary folder is kept until the work is done and checked, and then
deleted, whatever happened, a refusal included.

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

   Each skills folder is decided by itself. A project with its own `bug`
   in `.claude/skills/` and none in `.agents/skills/` gets the kit's in
   the second, and keeps its own in the first, so two harnesses run two
   different skills of one name. That is said to the user.

3. **The project file and its pointers,** each only where the project has
   none:
   - `AGENTS.md`, from `templates/AGENTS.md`
   - `CLAUDE.md`, from `templates/CLAUDE.md`, for Claude Code
   - `GEMINI.md`, from `templates/GEMINI.md`, for Gemini CLI
   - `.githooks/pre-commit`, from `templates/pre-commit`, and
     `.githooks/commit-msg`, from `templates/commit-msg`, each made
     executable where the system has such a thing

   Where the install writes `AGENTS.md`, it fills in the answers to the
   questions in _Before anything_, each bracketed default replaced by the
   answer in plain words: under _Gates_, the audit threshold and the
   allowed licences; under _Commands_, how updates arrive; and under _How
   a change lands_, the merge style, what an agent may do without asking,
   with the grant's who and date where there is one, and the stale
   threshold.

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

   The first list is every skill folder the kit wrote. The second is every
   folder the kit would have written and did not, because the project had
   one of that name, and nothing else; where there is none, it is the one
   line `- none`. The harnesses are named as in the table, in lower case.
   It is the only file the agent writes in `guardrails/` itself, and it
   is how an update tells the kit's folders from the project's.

5. **Check the copy.** Before the temporary folder goes, compare every
   file written with the kit's, byte for byte, and every template written
   with its template. A difference is put right and said; a copy that was
   not checked is said to be unchecked.

6. **What is left for the project,** said to the user in the report, in
   this order, each only where it applies:
   - **A pointer file of its own,** first of all. Where `CLAUDE.md` or
     `GEMINI.md` was there already and does not bring in `@AGENTS.md`,
     that harness never sees the kit. The line to add at its top is
     `@AGENTS.md`. Where that file holds the project's real instructions,
     the `AGENTS.md` just written from the template is still to be filled
     in, and the `guardrails` skill does so, from the code and that file.
   - **A project file of its own.** Where `AGENTS.md` was there already
     and does not name the rules, the line to add near its top is:

         Read guardrails/GUARDRAILS.md before changing anything: @guardrails/GUARDRAILS.md

     and each heading of `templates/AGENTS.md` it lacks is listed: the
     skills look for them by name. The answers to the questions about how
     a change lands are given as the lines to add under _How a change
     lands_.

   - **A formatter.** Where the project has one (a prettier, biome or
     dprint config file at its root, or a `prettier` key in its
     `package.json`), the user is told to have it leave `guardrails/` and
     each skill folder the record lists as the kit's alone, by its ignore
     file, and given those paths, one a line. The agent does not
     edit the ignore file itself. The kit's files are formatted as
     prettier formats them by default; a formatter that writes over them
     turns the next update into a hand edit.
   - **The hook.** A hook the project had already is left, and read: say
     what it runs, and whether that is the project's quick check. The
     kit's own refuses every commit until its `QUICK_CHECK` is named, and
     runs only once git is pointed at its folder with
     `git config core.hooksPath .githooks`. Both are the `guardrails` skill's to do,
     and it asks first.
7. **Report,** in one message: what is left for the project, in the order
   above; every file written; every file left as the project's; whether
   the copy was checked; and that nothing is committed. The next step is
   the `guardrails` skill, run in the project.

## Updating

Where the project has a `guardrails/` folder with
`guardrails/INSTALLED.md` in it. Two copies of the kit are got as
_Getting the kit_ says, from the same place: the **installed** one, at the
version the record names, and the **newer** one. The newer kit's
`INSTALL.md` is the one followed from here: the installed kit's may be out
of date.

A folder the record lists, such as `.claude/skills/bug`, is compared with
the kit's `skills/bug`. `guardrails/INSTALLED.md` itself is never
compared: it is the agent's.

1. **Hand edits first.** Compare, byte for byte, the project's
   `guardrails/GUARDRAILS.md`, each file of `guardrails/checks/`, and each
   skill folder the record lists as the kit's, with the same files in the
   installed copy. Any difference is a hand edit, and so is a file added
   to one of them or a file gone: see _A hand edit_. Nothing is written.
2. **The diff.** Show the user the difference between the installed copy
   and the newer one, in the files the project has: the rules, the checks,
   and the skills the record lists as the kit's. A skill new in the newer
   kit is listed as one that would be added, unless the project has a
   folder of that name, which stays its own. A skill in two folders is
   shown once, and said to be in both. Where the templates have
   changed, show that too, as something the user may take into the files
   made from them; those are the project's, and are not written.
3. **Wait for the user's yes.** Without it nothing is written.
4. **Write.** Replace the rules, the checks and the kit's skill folders
   with the newer kit's, byte for byte; remove a check or a skill the
   newer kit no longer has; add the new ones. The project's own files and
   folders are not touched. Update `guardrails/INSTALLED.md` to the newer
   version, and its lists made again from what is now there, as
   _Installing_ says; where nothing was added or removed, they stay as
   they were. Check the
   copy, as _Installing_ says.
5. **Report** what changed, by file, whether the copy was checked, and
   that nothing is committed.

## Refusals

Each stops the work before anything is written, and is said to the user
by name, with what to do about it.

### A hand edit

A kit file in the project differs from the kit at the installed version.
Name every file, with its diff. A change to a rule belongs in the kit,
where every project gets it, or in the project's own `AGENTS.md`; once it
is there, the file is put back as the kit had it, and the update run
again. Putting it back loses the edit, so the agent does it only on the
user's word.

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
