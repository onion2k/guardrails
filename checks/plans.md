# Plans

Where a plan lives, the line under its title that says where it stands,
and the script that reads every plan in a project and prints what comes
next. Without it a plan is agreed in a harness's own file and goes stale
there, each project keeps its plans somewhere else, and where the work
stands is counted off boxes by whoever asks.

## What it holds

- **A plan lives in the project.** In `plans/<name>.md`, one plan a file,
  named for the work, on the work's branch, so that it lands with the
  work. Or as a `# ` section of a `PLAN.md` at the project's root, which
  is read the same way. A plan agreed in a harness's own plan file is
  copied there the moment it is agreed, and the copy is the one ticked.
- **Its state line says where it stands.** It is the first line under the
  plan's title, in one of four forms and no other: agreed, with the date;
  building, with the part in hand and the count; landed, on the default
  branch at a commit, with the date; parked, with why. A line in none of
  them is refused by name, never guessed at.
- **The line and the boxes agree.** A box is `- [ ]`, `- [x]` or `- [-]`
  (dropped) at the start of a line. Every one at the top level is a part,
  and so is a question the user owes, in the order they are built. The
  part in hand is the first open box, and the count leaves dropped boxes
  out. Where a building line gives another part or count than the boxes,
  or building has every box ticked, or agreed has a box ticked, both
  facts are printed and the line is moved. A landed or parked line is not
  held to its boxes, and only a landed one to its commit, which must be
  on the default branch.
- **What is open is shown.** A landed plan stays, its commit on the
  default branch, and is not shown.
- **Nothing else is kept by hand.** The date a plan last moved, which
  branch has it, and what git and the remote hold are read each time.

## Its smallest form

    plans/<name>.md

The four forms of the line, the full stop at the end allowed and not
required:

```
State: agreed 2026-10-18.
State: building, part 3 of 7.
State: landed on main at 1a2b3c4, 2026-10-18.
State: parked, waiting on the renderer's next release.
```

The script, which the kit ships:

    sh guardrails/next             one screen for this project
    sh guardrails/next <folder>    the same for another project

It prints each open plan with its state, its boxes and its first open
box; what git and the remote hold that the tidy skill would find, in
tidy's own words; and what has landed on the default branch since the
last tag. The row shows boxes ticked of boxes counted (`building, 2 of 4`
is two ticked of four, while the line's `part 3 of 4` is the one in
hand), the first open box's text in full, and when the plan file last
moved, by its last commit, or `uncommitted`. The screen cuts nothing. It
asks the remote for its default branch only where the clone does not know
it, which is a read and not a fetch; where the remote cannot be reached
it takes `main` or `master` and says `(assumed)`. It needs `sh` and
`git`, and `gh` where the remote is GitHub. It writes nothing: no fetch,
nothing under `.git/`, so it can run while sessions are at work. A plan
whose line is in no form is refused by name with the rest still printed,
and the exit status says whether anything was refused, so that a loop
over projects can count.

## Seen failing

- A state line misspelt on purpose, and the script seen to refuse it by
  file and title, with the line as written.
- A box ticked past the line, and the script seen to print both facts
  under the plan's row.

Each fault is put back as it was, and nothing is committed by the trial.

## Where it cannot apply

- **A project with no plans yet** has nothing to read, and the script
  says so in a line.
- **A plan kept as a section of a `PLAN.md`,** as the kit's own are, is
  read the same way.
- **A plan kept anywhere else** is not read until it is moved into
  `plans/`, and the project file says where it is until then.
