---
name: tidy
description: Find what work has left behind in a project, wherever it was done (a local session, a worktree, a cloud session's branch, by hand), say what each thing is, and settle each on the user's word. Covers uncommitted changes, stashes, unpushed commits, branches merged and not deleted or not merged at all, worktrees, remote branches and open PRs. Never deletes or discards anything unmerged without the user's word for that item. Use when the user asks to tidy, clean up, or find abandoned or unmerged work, in one project or across a folder of them.
---

# tidy

Find what is left in a project, say what each thing is, and settle each
on the user's word, as `guardrails/GUARDRAILS.md`'s _Clearing up_ says.
The project file's _How a change lands_ gives its stale threshold.

Work is found by what it leaves in git and at the remote, never by asking
a harness about its sessions. A cloud session's work is the branch or PR
it pushed, and a local one's is its tree, its branches and its worktree.
Whether a session is still running cannot be seen in git. Where it might
be, the thing is left alone and said.

For a folder of projects, steps 1 to 3 run in each and the report is one
table. Steps 4 and 5 are done one project at a time.

## 1. Fetch

`git fetch --prune` from each remote. Then read the remote's default
branch, never assumed to be `main`: `git ls-remote --symref origin HEAD`
says it without changing anything, where `origin/HEAD` has not been set
locally. A project with no remote is judged against the branch its
history is built on, and the user is asked where that is unclear, and
told that nothing in it is backed up anywhere. The remote's name on its
host is read from its URL, which may differ from the folder's.

Asked for a read-only run, as across someone's projects while sessions
may be at work in them, skip the fetch, and judge remote branches from
the refs there and from the host, saying the refs may be out of date. Do
not run `git merge-tree` either: it writes objects into the repository,
unreferenced and harmless, but written. A branch that ancestry calls
unmerged is then reported as _not merged by ancestry_, since it may have
been squashed in. Everything below is judged against the default branch, local or
remote as the thing is.

## 2. Find, read only

- **The checkout:** uncommitted changes, files not tracked and not
  ignored, stashes, commits on the default branch not pushed, a detached
  HEAD.
- **Local branches:** each, with how far ahead and behind the default
  branch it is.
- **Worktrees** (`git worktree list --porcelain`): each one's branch,
  whether its tree is clean, and whether git marks it locked or
  prunable. A worktree may be anywhere on the machine, not only under the
  project: say where. One on a detached HEAD is judged by its commit.
- **The remote:** its branches besides the default, and the open PRs,
  with their age, author, and whether their checks are green. On GitHub,
  `gh pr list --state open`.

## 3. Say what each is

Each thing found is one of:

- **merged:** everything in it is on the default branch. Judged by
  ancestry (`git merge-base --is-ancestor`). Where that says no, as it
  does for a branch that was squashed or rebased in, it is merged if
  merging it would change nothing:
  `git merge-tree --write-tree <default> <branch>` gives the default
  branch's own tree. A PR merged from it is a third way to know. A name
  is never enough: a branch called `done` or `merged` is judged like
  any other.
- **unmerged:** it has work that is nowhere else.
- **uncommitted:** changes in a working tree, or a stash.
- **stale:** a branch whose newest commit, or an open PR whose last
  update, is older than the project's threshold.
- **in use:** a worktree that is locked, or a tree with a file holding an
  uncommitted change made in the last hour (files only:
  `find <tree> -type f -newermt '-60 minutes'`, leaving out `.git` and
  what is ignored). A checkout's own age does not count: a
  tree just cloned is not in use. Something in use may be a session still
  at work. A branch checked out in a worktree that is in use is in use
  with it, merged or not.

Show the user a table with a row for each thing: what it is, its place,
its kind, its age, how it was judged (the command and what it gave), and
the recommendation. The report's _Found_ is the same table.

## 4. Stop, and put it to the user

Group what was found, and give a recommendation for each group:

- **merged, local or remote:** delete it.
- **unmerged:** land it (the land skill), park it, or drop it. Say what is
  in it, in a line a commit.
- **uncommitted:** park it, or leave it.
- **stale PRs:** close each with a comment saying why, or keep it.
- **in use:** leave it.

PRs in a repo with no checkout here are listed with their links and left:
they are checked and closed in their own repo.

Then stop, and wait for the user's word.

## 5. Act on each yes, and on nothing else

Each step here happens only on the user's word. A word for a group covers
what is merged in it. Anything unmerged or uncommitted needs the user's
word for that item.

- **Delete:** fetch again, and check it again as in step 3, because
  something may have moved since. A worktree goes before its branch,
  since git will not delete a branch that is checked out. A local branch goes with `git branch -d` where git
  agrees it is merged, and `-D` only for one step 3 found merged by its
  tree. A remote one goes with `git push <remote> --delete <branch>`. A
  worktree goes with `git worktree remove`, which refuses a dirty one; it
  is never forced.
- **Park:** commit the work on a new branch named
  `parked/<date>-<what it is>`, with a message saying what it is and why
  it stopped, and push it only on the user's word. A stash is parked the
  same way (`git stash branch`). Nothing is thrown away to be tidied.
- **Land:** hand it to the land skill.
- **Close a PR:** with a comment saying why, on GitHub `gh pr close
<number> --comment "..."`, never deleting its branch unless that too
  was agreed.

## 6. Report

- **Found:** the table from step 3.
- **Done:** each thing acted on, and how.
- **Left,** and why: waiting on the user's word, in use, or in a repo not
  here.
- **Not seen:** anything git cannot show, such as a session still running
  somewhere, said plainly.
