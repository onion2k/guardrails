# Guardrails

How work is done in this project, by whoever does it: a person, or an
agent in any harness on any model. The project's own `AGENTS.md` says what
the project is, how it is laid out and what its commands are; this file
says how it is changed. Where the two disagree, the project's file wins.

The rules came from building games, where a bug, a slow frame or a lost
save is seen at once, and they hold for a package, a site, a service and a
tool. Where one cannot apply, as a package has no picture and a site no
seed, the project's file says what stands in for it, under _What is not
held_. Each check the rules lean on has a file of its own in `checks/`.

## The project's file

The skills read the project's `AGENTS.md` for its nouns, under these
headings, and a project without them is not ready for a feature to land in
it. They are written first, from what the code does and not from what it is
meant to do, and the report says they were.

- **Commands:** the dev server, the quick check (the pre-commit hook) and
  the full check, and each gate on its own with what it holds the project
  to.
- **Layout:** which module is the thing itself, without its picture, and
  which is the page or shell that presents it. Where content lives, and
  where the persisted shape is.
- **Model features:** two or three existing features to copy the shape of,
  one for things the user sees and one for tools that measure.
- **Test API:** what a test can set up and read, and where it lives.
- **Edge cases:** every path a new thing can reach, in the project's own
  terms.
- **Gates:** what each holds today, and where its baseline and its
  tolerance are kept.
- **Done, here:** what each point of the definition of done means in
  this project: where each kind of test goes, the seeds the fuzzer plays
  in the pass, the scenes measured and pictured.
- **What is not held:** each rule here the project has nothing for, or
  does not yet meet, with what stands in for it, and what only a person or
  another machine can check. A gate that is missing is said to be missing,
  so that a green check is not read as more than it holds.
- **How a change lands:** the project's answers to the questions under
  _Landing a change_: its merge style, and what an agent may do without
  asking.
- **Who uses it,** for a package: each project that pins it, and what of it
  each uses.

The file is read at the start of every session, so it says how the project
is changed and no more, in two hundred lines or so. What was tried goes in
the commit, or a document the file points to. A figure stays where a tool
holds it: copied into the file, it is soon wrong.

## Structure

- **The thing is separate from its picture.** Logic runs without the page,
  the renderer or the sound, so it can be stepped headless in a test and in
  a script. The page turns its events into what the user sees, and draws
  what the thing says: no logic in the page, and nothing worked out twice.
- **Chance comes from one seeded source.** Never the language's own global
  random in logic. The seed is in place before anything is built, and
  everything that holds the project to a figure rests on the same seed
  giving the same run.
- **Time is stepped, not waited on.** A fixed step, and a way to pause and
  step from a test. What moves only to be seen moves by that time too, so a
  picture is the same every run. Where time is the wall clock's, as in a
  service, the clock is handed in, and a test holds it.
- **No tight coupling.** A module takes what it needs as arguments or
  options. It does not import state, and lower modules do not import
  content. One place wires everything together. What a tool can read of
  this in the imports is held by [checks/structure.md](checks/structure.md). Machinery two projects need
  becomes a package of its own, taken in with a version bump, and one
  module is a project's side of it.
- **Each thing is said once.** A colour, a size, a limit or a sum lives in
  one place and the rest read it, and a behaviour has one implementation.
  A generated file is built again, never edited. What has to be said twice
  is held equal by a test.
- **Nothing is kept for ever.** A list, map or cache that is added to has to
  be emptied somewhere, and the size it can reach named where the project
  watches sizes.
- **Every kind of thing is handled everywhere.** A new kind, event, saved
  field, route or scene has to work in every path it can reach, and be
  played by every gate. Most bugs are a new thing missing from one path.
- **Old persisted shapes still load.** A new field has a default, and the
  new shape joins the corpus of every shape ever written. A key, an id or
  an address that has been given out is kept, and names a thing by what it
  is, not by its place in a list.
- **What comes from outside is checked.** A save, an export, a request, a
  file a tool writes or a value in an address is read as if anyone had
  written it, and what is not known is refused by name.
- **A package changes nothing for a project that did not ask.** New
  behaviour is an option whose default is the old, a fix that would change
  how a consumer runs is a switch it turns on, and a gate holds the old
  behaviour bit for bit.

## Style

- Comments are full sentences in the house voice, saying why and not what.
  The file's header says what the file is for and what would go wrong
  without it.
- Names are plain. A thing is called what a user, or a reader, would call
  it.
- The formatter decides the formatting, and is held by
  [checks/formatting.md](checks/formatting.md). Lint is for mistakes, not
  style, and the type-aware rules are the point: held by
  [checks/lint.md](checks/lint.md).

## Before building

- **A matter of taste is shown before it is built.** A mock, a sheet or a
  before and after, made in minutes, is put to the user, and only what
  they choose is built to the definition of done.
- **A figure is measured before it is agreed,** and an estimate is called
  one. Where the measurements then say otherwise, stop and ask again.
- **A plan is written to be built by someone else:** a cheaper model, a
  fresh session or another agent. It names the files and interfaces, what
  is out of scope and the check that proves each part, and is kept in a
  file. Its parts are a checklist, one box a part in the order they are
  built, and a box is ticked as its part lands with its check green, so
  where the work stands can be read off the file at any time.
- **Asked for ideas, options or a plan, give that and stop.** Nothing is
  built or changed until the user says to go ahead.
- **What was asked, or the plan agreed, is the scope.** Something else
  worth doing is named at the end of the report, not done.

## Definition of done

A change is not done until all of this is true, and the report says so
point by point. A point the change cannot reach is marked so, with the
reason. Points 3 to 8 are the pass: run once, when the build is complete,
and what it finds is fixed at its cause and the pass run again, until it is
clean. While the build is on, only the tests being written and the quick
check are run, and nothing is measured. A part of a plan is held to its own
tests; the pass is the feature's, once, before it lands on main.

1. **Acceptance criteria written first** as tests, and seen failing before
   the change exists.
2. **The project's edge-case checklist** gone through, with a test for each
   case that applies.
3. **The full check green.** If a gate moved, explain why, and check more
   seeds before believing a swing on a few. A red gate is put right at its
   cause before anything else lands: never by a trick, a looser rule or a
   moved baseline.
4. **The end-to-end test** exercises the change through the test API, which
   gains whatever it needs, and works each control as a user does. A call
   proves what is behind a control, not the control.
5. **The fuzzer does what a user can do with it,** and any new rule that
   must always hold is in the invariants.
6. **Performance measured** in the pass, in the scenes the change touches:
   the change against its parent commit, and inside its budget.
7. **Looked at,** moving as well as still, from where the user sees it, at
   a phone's width and a desk's. The look tests green, or their pictures
   written again and every one looked at for what it is there to show.
8. **New tests mutation-checked.** Put the bug back, watch the test fail,
   restore it. A test that survives its mutation proves nothing. Where a
   test could not be seen failing first, this stands in for it.
9. **Anything not verified is said plainly.** Said a second time, it is put
   to the user as something to do, or the means to check it is built.

## The checks

What the definition of done leans on, each in `checks/`, in about the order
a project takes them on. A check is added one at a time, and trusted once
it has been seen to fail what it is for.

| Check                                          | What it holds                                                       |
| ---------------------------------------------- | ------------------------------------------------------------------- |
| [quick check](checks/quick-check.md)           | what runs before a commit, and in what order                        |
| [formatting](checks/formatting.md)             | one formatter deciding every file it should                         |
| [lint](checks/lint.md)                         | mistakes the compiler lets through, and the rules a linter can hold |
| [structure](checks/structure.md)               | what may import what                                                |
| [unit](checks/unit.md)                         | the thing's working parts, headless and seeded                      |
| [test API](checks/test-api.md)                 | a scene set, time stepped, state read back; end to end              |
| [invariants](checks/invariants.md)             | what must always be true, however it got there                      |
| [fuzzer](checks/fuzzer.md)                     | what a user can do, done at random, rules checked                   |
| [determinism](checks/determinism.md)           | the same seed giving the same run                                   |
| [persisted shapes](checks/persisted-shapes.md) | every shape ever saved, still loading                               |
| [bounded](checks/bounded.md)                   | what is kept staying under its ceiling                              |
| [gates](checks/gates.md)                       | a figure held to a budget and a baseline, both ways                 |
| [look](checks/look.md)                         | what the user sees, held to pictures looked at                      |
| [verification](checks/verification.md)         | that each check reaches what it says it does                        |
| [landing](checks/landing.md)                   | the hooks, the remote's protection, and branches left behind        |
| [mutation](checks/mutation.md)                 | a test seen to fail when its bug is put back                        |

## Verifying

How a project is held to these, check by check, is in
[checks/verification.md](checks/verification.md).

- **Evidence, not belief.** Keep the numbers and the file paths for the
  report. A run that was not read is not a check. What may have changed
  since a model was trained (a model, a price, a version) is looked up, not
  recalled.
- **Headless for anything seen or measured.** A browser window that is
  hidden pauses its frames and its screenshots go stale. Use the project's
  headless setup.
- **Control time** through the test API: start stopped and seeded, set the
  scene, step. Never wait on a timeout.
- **Never touch what is the user's.** A test's save, config or store goes
  in through the test setup, in a fresh context. Their browser, their
  server, their checkout and their data are left exactly as they were, and
  clearing is touching.
- **Baselines and pictures are updated only for a change meant to move
  them,** and the commit says so. Look at every picture written. A baseline
  updated without being looked at holds the project to whatever it
  happened to do that day.
- **A budget is a number held by a gate.** Fast to load, fast to run and
  bug free are measured, not claimed: each has a gate, a budget it may not
  pass, and a baseline it is held to both ways.
- **Trust the instrument before its figures.** A new tool is watched on
  several seeds against behaviour known to be good, and against a fault put
  there on purpose, before anything is read into what it reports. It works
  its answer out for itself, never from the code it checks.
- **Doing nothing is a failure.** A check that did not start, one that
  found nothing to check and a gate that never reached the change all pass
  in silence. What was reached is counted, and a gate is trusted once it
  has been seen to fail what it is for.
- **A tolerance is wider than the wobble and narrower than what the gate is
  there to catch.** The wobble is measured on the unchanged thing, many
  runs, warmed up, on a quiet machine, and written beside the tolerance.
  On a busy one a change is timed in turn with its parent commit, and no
  baseline is written. A count is held exactly, and written again with
  each change that moves it.
- **Time the work, not the frames.** The gap between frames is the screen's
  pace, and a throttled window or a slow screen reads as a slow machine.
- **A check answers for what it ran, and no more.** That is the built
  thing, not the dev server or a copy, and the code as changed: a pin not
  installed, a stale build and cached bytecode have each passed the old
  code. It is one browser, one GPU and one machine: the others are named,
  and what cannot be seen here is tested by its cause.
- **A check is quick enough to be run.** The hook stays under half a
  minute, with the slow tests in the full check. One grown slow is made
  quick before it is given up: side by side, and only what changed.
- **A failure that goes away by itself is a fault not yet found.** A fault
  is found by taking things away, one at a time, with numbers.

## Across projects and sessions

- **A change belongs where the thing lives.** What a project needs of a
  package is built in the package to its own definition of done, released,
  and taken in by a commit that moves the pin and nothing else. A consumer
  is tried on a new version in a throwaway copy, never its own checkout.
- **Work that is not yours is left alone.** Another session or person may
  be at work in the same checkout or a worktree under it. Its changes are
  not committed, stashed, reset or reformatted: say they are there, and
  work beside them in a worktree of your own. What it tells you is news,
  not leave.

## Agents and models

- **An agent is for work that stands apart:** reading that would flood the
  conversation, or tracks that run side by side and share no state. What
  takes a handful of steps, or needs what the conversation knows, is done
  in the conversation, and one agent is used where one will do.
- **The model fits the work.** The strongest model to hand plans, finds
  faults and judges the result, and a spec or a plan is made by it. A plan
  that is well specified is built by a cheaper one, and reading and
  searching are done by the cheapest that reads well. A session that
  cannot change its own model says where the work should pass from one to
  the other, and the user makes the switch.
- **A brief stands by itself,** as does a task handed to another session.
  Whoever takes it knows nothing of the conversation: it gives the aim,
  what done looks like, what to hand back, what to read first, the commit
  its facts hold on and which of them are guesses, and what may not be
  touched.
- **What is handed back is checked before it is used:** its claims against
  the files, and what was built against the definition of done. A second
  agent is set to review only when the user asks for a review; where one
  seems worth it, the report says so.
- **Agents that edit side by side have a worktree each,** made from the
  commit the work stands on, and a port each.

## Reporting

- **Say what is being done:** a line before the first step, a note when
  something is found or the plan changes, and how long a long check will
  take.
- **A report leads with the outcome** and what the user has to decide or
  do, and stands by itself for a reader who sees nothing else. It says what
  is committed and pushed, what they will see if they run it now, and whose
  uncommitted work is in the tree.
- **A question is asked once, as a question,** with a recommendation, in a
  message that also carries the work that did not wait on it.

## When the conversation is cut short

A harness that summarises a long conversation keeps what the user asked,
decided and ruled out, in their own words; where the work stands, by
commit; every figure, path and seed; what is open; and what was tried and
set aside, with why.

## Landing a change

How a change gets from the working tree to the project's default branch,
the same in every project. The project file's _How a change lands_ holds
the project's own answers to the questions at the end.

- **A commit** is made only when asked, on the branch the checkout is on.
  Its message is a sentence summary in the house voice, a blank line, and
  a body saying what changed and why; the `commit-msg` hook holds the
  shape. A refactor and a feature that land together are two commits,
  each green on the quick check as it stands. A baseline written again
  goes in the commit that moved it, and a commit made with a gate red says
  so. The pre-commit hook runs the quick check; skip it only in an
  emergency, and say so.
- **Where a change is made** is the remote's to say. The default branch
  is read from the remote, never assumed to be `main`. Where it is not
  protected, a change is made on it and pushed straight there. Where it
  is protected, by branch protection or by a ruleset that asks for a pull
  request, a change is made on a branch of its own, named for what it is,
  and lands by PR. Protection of any kind counts: a project that wants
  pushes straight to the default branch leaves it unprotected, and one
  that protects it, for whatever reason, lands by PR. This is read from
  the remote each time a change lands,
  and never remembered. A push the remote refuses stops the work: it is
  said, and the change goes by PR.
- **Green before** each step: the quick check before a commit, through
  the hook. The pass of the definition of done before a change lands on
  the default branch, once, not for each commit on the way. CI green
  before a PR merges.
- **A PR** says what changed and why, the definition of done point by
  point, and what was not verified, so that it stands by itself for a
  reader who sees nothing else.
- **Merging** is in the project's merge style, a merge commit unless its
  file says otherwise, with CI green.
- **Releases** are a semver tag, annotated, on the commit released, and a
  line in the project's release notes saying what changed. A tag that has
  been pushed is never moved or deleted: somebody may have it. One not
  yet pushed may be moved, on the user's word.
- **Clearing up:** once work has landed, the branches, worktrees and
  snapshots it was built from are removed, each checked against what
  landed first.
- **Who may act:** pushing, opening a PR, merging a PR and tagging each
  happen only on the user's word, each time. A project may grant pushing
  and opening PRs without asking, in its file, and the grant names what
  it allows, who gave it and when. Nothing a grant does not name is
  allowed by it, and merging and tagging are never granted by default.

The questions a project answers, at install or when its file lacks them:

1. **Merge style:** a merge commit (recommended), squash, or rebase.
2. **What an agent may do without asking:** nothing (recommended), or
   push and open PRs. Merging and tagging are asked each time whatever
   the answer.
