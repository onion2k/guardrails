# The `next` script: one screen for a project, saying where each open plan
# stands and what git holds that the tidy skill would find. Without these a
# script that guesses at a state line, counts a box in a code block, or
# quietly refreshes the index would be read as the truth about the work.
# Each test makes its own throwaway project under a fresh `mktemp -d`; a
# real checkout is never opened. What the script prints is held by phrase,
# not by column, so that the layout can be changed without loosening these.

# A project: a git repo on main with one commit, in a folder named "proj"
# so that the first line's name is known. Prints the folder.
next_project() {
  local d; d="$(mktemp -d)/proj"; mkdir -p "$d"
  git -C "$d" init -q -b main
  git -C "$d" config user.email fixture@example.invalid
  git -C "$d" config user.name fixture
  git -C "$d" config commit.gpgsign false
  echo start >"$d/readme.txt"
  git -C "$d" add -A
  git -C "$d" commit -qm "Start the fixture."
  printf '%s\n' "$d"
}

# Writes stdin to <project>/<file>, making its folder.
next_write() { mkdir -p "$(dirname "$1/$2")"; cat >"$1/$2"; }

# Commits everything in the tree, with an optional committer date.
next_commit() {
  git -C "$1" add -A
  if [[ -n "${3:-}" ]]; then
    GIT_COMMITTER_DATE="$3" GIT_AUTHOR_DATE="$3" git -C "$1" commit -qm "$2"
  else
    git -C "$1" commit -qm "$2"
  fi
}

# A time in the past, as git takes it, n days ago; GNU and BSD date differ.
next_days_ago() { date -u -d "$1 days ago" '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -v-"$1"d '+%Y-%m-%dT%H:%M:%SZ'; }

# Runs the script under a shell, from outside the project: its output and
# status are left in NEXT_OUT and NEXT_STATUS.
next_run() {
  NEXT_OUT="$(cd "$TMPDIR" && "$1" "$KIT/next" "$2" 2>&1)"
  NEXT_STATUS=$?
}

# Fails, saying what and showing the screen, when the output lacks the phrase.
next_has() {
  [[ "$NEXT_OUT" == *"$1"* ]] && return 0
  echo "the screen does not say: $1"; sed 's/^/  | /' <<<"$NEXT_OUT"; return 1
}
next_lacks() {
  [[ "$NEXT_OUT" != *"$1"* ]] && return 0
  echo "the screen says, and should not: $1"; sed 's/^/  | /' <<<"$NEXT_OUT"; return 1
}
# The first line of the screen that has the phrase, or nothing.
next_line() { grep -F -m1 -- "$1" <<<"$NEXT_OUT"; }
# Holds that the line with the first phrase also has the second.
next_line_has() {
  local line; line="$(next_line "$1")"
  [[ -n "$line" ]] || { echo "no line has: $1"; sed 's/^/  | /' <<<"$NEXT_OUT"; return 1; }
  [[ "$line" == *"$2"* ]] || { echo "the line with \"$1\" lacks \"$2\":"; echo "  | $line"; return 1; }
}

# The date a fixture's commit has, as the screen shows it: today, no year.
next_today() { date '+%d %b'; }

next_open_plan() {
  local d; d="$(next_project)"
  next_write "$d" plans/work.md <<'PLAN'
# Work on it

State: building, part 3 of 4.

- [x] **1. First,** done
- [x] **2. Second.**
- [ ] **3. Third part:** the one in hand
- [ ] 4. Fourth
PLAN
  next_commit "$d" "Add the plan."
  printf '%s\n' "$d"
}

next_check_open_plan() {
  local d bad=0 first rest; d="$(next_open_plan)"
  next_run "$1" "$d"
  next_has "building, 2 of 4" || bad=1
  next_has "next: 3, Third part" || bad=1
  next_line_has "Work on it" "$(next_today)" || bad=1
  next_lacks "the state line says" || bad=1
  next_lacks "refused" || bad=1
  ((NEXT_STATUS == 0)) || { echo "exit status was $NEXT_STATUS, not 0"; bad=1; }
  first="$(head -1 <<<"$NEXT_OUT")"
  [[ "${first:0:16}" == "proj            " ]] || { echo "the first line does not start with the folder's name padded to 16 columns: $first"; bad=1; }
  rest="$(tail -n +2 <<<"$NEXT_OUT" | grep -v '^                ' || true)"
  [[ -z "$rest" ]] || { echo "a later line is not indented by 16 spaces: $rest"; bad=1; }
  return $bad
}

test_next_open_plan_prints_its_next_step() { next_check_open_plan sh; }

test_next_agreed_plan_prints_its_first_step() {
  local d bad=0; d="$(next_project)"
  next_write "$d" plans/fresh.md <<'PLAN'
# Fresh start

State: agreed 2026-10-18.

- [ ] Write the tests first
- [ ] Build it
- [ ] Release it
PLAN
  next_commit "$d" "Add the plan."
  next_run sh "$d"
  next_has "agreed, 0 of 3" || bad=1
  next_has "next: 1, Write the tests first" || bad=1
  return $bad
}

test_next_parked_plan_prints_why() {
  local d bad=0; d="$(next_project)"
  next_write "$d" plans/stopped.md <<'PLAN'
# Stopped for now

State: parked, waiting on the renderer

- [x] One
- [ ] Two
- [ ] Three
PLAN
  next_commit "$d" "Add the plan."
  next_run sh "$d"
  next_has "parked, 1 of 3" || bad=1
  next_has "parked: waiting on the renderer" || bad=1
  next_lacks "next: 2" || bad=1
  return $bad
}

test_next_nothing_open_says_so() {
  local d bad=0; d="$(next_project)"
  next_write "$d" plans/old.md <<'PLAN'
# Old work

State: landed on main at 1a2b3c4, 2026-10-01.

- [x] One
PLAN
  next_commit "$d" "Add the plan."
  next_run sh "$d"
  next_has "nothing open; last landed: Old work, 2026-10-01" || bad=1
  next_has "1 plan landed" || bad=1
  next_lacks "of 1" || bad=1
  return $bad
}

test_next_refuses_a_malformed_state_line_by_name() {
  local d bad=0; d="$(next_project)"
  next_write "$d" plans/good.md <<'PLAN'
# Good plan

State: agreed 2026-10-18.

- [ ] Do it
PLAN
  next_write "$d" plans/bad.md <<'PLAN'
# Bad one

State: done.

- [ ] Do it
PLAN
  next_write "$d" plans/none.md <<'PLAN'
# No state

Only some words, and no state line.

- [ ] Do it
PLAN
  next_write "$d" plans/parked-bare.md <<'PLAN'
# Parked for nothing

State: parked

- [ ] Do it
PLAN
  next_write "$d" plans/untitled.md <<'PLAN'
State: agreed 2026-10-18.

- [ ] Do it
PLAN
  next_commit "$d" "Add the plans."
  next_run sh "$d"
  next_has 'plans/bad.md: refused, the state line is not one of the four: "State: done."' || bad=1
  next_has 'plans/none.md: refused, no state line under "No state"' || bad=1
  next_has 'plans/untitled.md: refused, no title' || bad=1
  next_has 'plans/parked-bare.md: refused, the state line is not one of the four: "State: parked"' || bad=1
  # A refusal does not stop the rest of the screen.
  next_has "Good plan" || bad=1
  next_has "agreed, 0 of 1" || bad=1
  ((NEXT_STATUS == 1)) || { echo "exit status was $NEXT_STATUS, not 1"; bad=1; }
  # A plan kept in PLAN.md is named as PLAN.md.
  d="$(next_project)"
  next_write "$d" PLAN.md <<'PLAN'
# Only plan

State: finished

- [ ] Do it
PLAN
  next_commit "$d" "Add the plan."
  next_run sh "$d"
  next_has 'PLAN.md: refused, the state line is not one of the four: "State: finished"' || bad=1
  ((NEXT_STATUS == 1)) || { echo "exit status was $NEXT_STATUS, not 1 for PLAN.md"; bad=1; }
  return $bad
}

test_next_says_when_the_line_and_the_boxes_disagree() {
  local d bad=0; d="$(next_project)"
  next_write "$d" plans/a-behind.md <<'PLAN'
# Behind the boxes

State: building, part 2 of 5.

- [x] One
- [x] Two
- [x] Three
- [ ] Four
- [ ] Five
PLAN
  next_write "$d" plans/b-agreed.md <<'PLAN'
# Agreed but started

State: agreed 2026-10-18.

- [x] One
- [ ] Two
- [ ] Three
PLAN
  next_write "$d" plans/c-finished.md <<'PLAN'
# Finished but building

State: building, part 2 of 2.

- [x] One
- [x] Two
PLAN
  next_write "$d" plans/d-right.md <<'PLAN'
# Right as it stands

State: building, part 2 of 2.

- [x] One
- [ ] Two
PLAN
  next_commit "$d" "Add the plans."
  next_run sh "$d"
  next_has "the state line says part 2 of 5; the boxes say 3 of 5 ticked, next 4" || bad=1
  next_has "the state line says agreed; 1 ticked" || bad=1
  next_has "the state line says building; every box is ticked: say landed, or parked" || bad=1
  next_has "every box ticked: say landed, or parked" || bad=1
  # The row stands: a line out of date is well formed, and not a refusal.
  next_line_has "Behind the boxes" "building, 3 of 5" || bad=1
  next_lacks "refused" || bad=1
  ((NEXT_STATUS == 0)) || { echo "exit status was $NEXT_STATUS, not 0"; bad=1; }
  # The plan that agrees with its boxes has no line saying it does not.
  local count; count="$(grep -cF 'the state line says' <<<"$NEXT_OUT")"
  ((count == 3)) || { echo "$count disagreement lines, not 3"; bad=1; }
  return $bad
}

test_next_reads_plan_sections_too() {
  local d bad=0; d="$(next_project)"
  next_write "$d" PLAN.md <<'PLAN'
# Plan one

State: landed on main at 1a2b3c4, 2026-09-01.

- [x] One

# Plan two

State: building, part 2 of 2.

- [x] One
- [ ] **The step in hand**

```text
# Not a heading
- [ ] not a box
State: nonsense
```
PLAN
  sed "s/1a2b3c4/$(git -C "$d" rev-parse HEAD)/" "$d/PLAN.md" >"$d/PLAN.tmp" && mv "$d/PLAN.tmp" "$d/PLAN.md"
  next_commit "$d" "Add the plans."
  next_run sh "$d"
  next_has "Plan two" || bad=1
  next_has "building, 1 of 2" || bad=1
  next_has "next: 2, The step in hand" || bad=1
  next_has "1 plan landed" || bad=1
  next_lacks "Not a heading" || bad=1
  next_lacks "not a box" || bad=1
  next_lacks "Plan one" || bad=1
  next_lacks "refused" || bad=1
  next_lacks "nothing open" || bad=1
  return $bad
}

test_next_counts_a_dropped_box_apart() {
  local d bad=0; d="$(next_project)"
  next_write "$d" plans/pruned.md <<'PLAN'
# Pruned

State: building, part 2 of 3.

- [x] First part
- [-] Given up
- [ ] Second part
  - [ ] a box under another, not a part
- [ ] Third part
PLAN
  next_commit "$d" "Add the plan."
  next_run sh "$d"
  next_has "building, 1 of 3" || bad=1
  next_has "next: 2, Second part" || bad=1
  next_has "and 1 dropped" || bad=1
  next_lacks "the state line says" || bad=1
  return $bad
}

test_next_says_where_the_plan_is() {
  local d bad=0; d="$(next_project)"
  next_write "$d" plans/there.md <<'PLAN'
# Placed

State: agreed 2026-10-18.

- [ ] One
PLAN
  next_commit "$d" "Add the plan."
  # On the default branch with no branch differing: nobody is at work.
  next_run sh "$d"
  next_has "no branch is at work on it" || bad=1
  next_lacks "not yet on" || bad=1
  # On a branch that changes the plan: the row says so.
  git -C "$d" checkout -qb work
  echo "- [ ] Two" >>"$d/plans/there.md"
  next_commit "$d" "Add a part."
  next_run sh "$d"
  next_has "on work, not yet on main" || bad=1
  next_lacks "no branch is at work on it" || bad=1
  # Back on the default branch, with the branch holding a different copy.
  git -C "$d" checkout -q main
  next_run sh "$d"
  next_has "differs on work" || bad=1
  next_lacks "no branch is at work on it" || bad=1
  # A plan that exists only on the branch is not on the default yet.
  git -C "$d" checkout -q work
  next_write "$d" plans/only-here.md <<'PLAN'
# Only on the branch

State: agreed 2026-10-18.

- [ ] One
PLAN
  next_commit "$d" "Add another plan."
  next_run sh "$d"
  next_line_has "Only on the branch" "agreed" || bad=1
  next_has "on work, not yet on main" || bad=1
  return $bad
}

# What tidy would find, in tidy's words, on the project with one of
# everything: shared by the plain run and the dash run.
next_check_leftovers() {
  local d bad=0 root; root="$(mktemp -d)"
  "$KIT/tests/make-leftovers" "$root" >/dev/null 2>&1 || { echo "the leftovers fixture would not build"; return 1; }
  d="$root/work"
  next_run "$1" "$d"
  next_has "no plans/ and no PLAN.md" || bad=1
  next_has "git: on main, default main (origin), stale after 30 days (the project file does not say)" || bad=1
  next_has "branch merged: merged" || bad=1
  next_has "branch squashed: not merged by ancestry" || bad=1
  next_has "branch unmerged: not merged by ancestry" || bad=1
  next_has "branch origin/landed: merged" || bad=1
  next_has "branch origin/cloud: not merged by ancestry" || bad=1
  next_has "stash: 1" || bad=1
  next_has "uncommitted: 1 file changed, 0 untracked, in use (changed in the last hour)" || bad=1
  next_line_has "on wt-done:" "clean, merged" || bad=1
  next_line_has "on wt-locked:" "in use (locked): a session at work" || bad=1
  next_has "branch wt-locked: merged, in use with its worktree" || bad=1
  next_line_has "branch wt-done:" "merged" || bad=1
  [[ "$(next_line "branch wt-done:")" != *"in use"* ]] || { echo "a branch of an idle worktree is called in use"; bad=1; }
  next_has "PRs not read:" || bad=1
  next_has "main: no tag yet," || bad=1
  next_lacks "not pushed to" || bad=1
  # The tree the script runs in is not one of the worktrees it lists.
  grep -E '^[[:space:]]*worktree .* on main:' <<<"$NEXT_OUT" && { echo "the checkout itself is listed as a worktree"; bad=1; }
  return $bad
}

test_next_finds_what_tidy_would() { next_check_leftovers sh; }

# The fixture's locked worktree has a change in it too; unlocked, it is in
# use for the change made a moment ago, and the lock is not what says so.
test_next_calls_a_changed_worktree_in_use_unlocked() {
  local root; root="$(mktemp -d)"
  FIXTURE_BREAK=locked "$KIT/tests/make-leftovers" "$root" >/dev/null 2>&1 || { echo "the leftovers fixture would not build"; return 1; }
  next_run sh "$root/work"
  next_line_has "on wt-locked:" "in use (changed in the last hour)"
}

test_next_calls_stale_by_the_project_file() {
  local d bad=0; d="$(next_project)"
  printf '%s\n' '- **Stale after:** 2 days' >"$d/AGENTS.md"
  next_commit "$d" "Say when stale."
  git -C "$d" checkout -qb old
  echo old >"$d/old.txt"; next_commit "$d" "Old work." "$(next_days_ago 3)"
  git -C "$d" checkout -q main
  git -C "$d" checkout -qb recent
  echo recent >"$d/recent.txt"; next_commit "$d" "Recent work." "$(next_days_ago 1)"
  git -C "$d" checkout -q main
  next_run sh "$d"
  next_has "stale after 2 days" || bad=1
  next_lacks "the project file does not say" || bad=1
  next_line_has "branch old:" "3 days old, stale" || bad=1
  next_line_has "branch recent:" "1 day old" || bad=1
  [[ "$(next_line "branch recent:")" != *stale ]] || { echo "a branch of yesterday is called stale"; bad=1; }
  # With no remote, the default is assumed, and said so.
  next_has "default main (assumed)" || bad=1
  # No project file line: 30 days, and said so.
  d="$(next_project)"
  next_run sh "$d"
  next_has "stale after 30 days (the project file does not say)" || bad=1
  return $bad
}

test_next_says_what_landed_since_the_last_tag() {
  local d bad=0; d="$(next_project)"
  echo a >"$d/a.txt"; next_commit "$d" "Add alpha."
  echo b >"$d/b.txt"; next_commit "$d" "Add beta."
  next_run sh "$d"
  next_has "main: no tag yet, 3 commits" || bad=1
  next_has "Add beta." || bad=1
  git -C "$d" tag v0.1.0 HEAD~2
  next_run sh "$d"
  next_has "main: v0.1.0, 2 commits since" || bad=1
  next_has "Add alpha." || bad=1
  next_has "Add beta." || bad=1
  next_lacks "Start the fixture." || bad=1
  return $bad
}

test_next_reads_the_default_branch_and_not_main() {
  local root w bad=0; root="$(mktemp -d)"
  git init -q --bare -b trunk "$root/remote.git"
  git clone -q "$root/remote.git" "$root/proj" 2>/dev/null
  w="$root/proj"
  git -C "$w" config user.email fixture@example.invalid
  git -C "$w" config user.name fixture
  git -C "$w" config commit.gpgsign false
  git -C "$w" symbolic-ref HEAD refs/heads/trunk
  echo start >"$w/readme.txt"; next_commit "$w" "Start the fixture."
  git -C "$w" push -q origin trunk 2>/dev/null
  git -C "$w" checkout -qb done
  git -C "$w" checkout -qb topic
  echo topic >"$w/topic.txt"; next_commit "$w" "Add topic work."
  git -C "$w" checkout -q trunk
  next_run sh "$w"
  next_has "default trunk (origin)" || bad=1
  next_lacks "(assumed)" || bad=1
  next_has "branch done: merged" || bad=1
  next_has "branch topic: not merged by ancestry" || bad=1
  next_has "trunk: no tag yet," || bad=1
  return $bad
}

# Everything that tells of a repo's state, and of its tree, in one string.
next_fingerprint() {
  git -C "$1" for-each-ref
  git -C "$1" stash list
  git -C "$1" diff-index --name-only HEAD
  git -C "$1" ls-files --others --exclude-standard
  cksum "$1/.git/index"
}

test_next_writes_nothing() {
  local d bad=0 before after marker changed; d="$(next_project)"
  next_write "$d" plans/busy.md <<'PLAN'
# Busy plan

State: building, part 1 of 2.

- [ ] One
- [ ] Two
PLAN
  next_commit "$d" "Add the plan."
  git -C "$d" branch side
  echo more >>"$d/readme.txt"; git -C "$d" stash -q
  echo changed >>"$d/readme.txt"
  echo loose >"$d/loose.txt"
  [[ -n "$(git -C "$d" stash list)" ]] || { echo "the fixture holds no stash"; return 1; }
  before="$(next_fingerprint "$d")"
  marker="$(mktemp -d)/marker"
  sleep 1; touch "$marker"; sleep 1
  next_run sh "$d"
  next_has "Busy plan" || bad=1
  after="$(next_fingerprint "$d")"
  [[ "$before" == "$after" ]] || { echo "the project changed under the run:"; diff <(echo "$before") <(echo "$after"); bad=1; }
  changed="$(find "$d" -newer "$marker" -type f)"
  [[ -z "$changed" ]] || { echo "files touched by the run:"; sed 's/^/  /' <<<"$changed"; bad=1; }
  return $bad
}

test_next_runs_under_dash() {
  command -v dash >/dev/null 2>&1 || { echo "dash is not on this machine"; return 77; }
  local bad=0
  next_check_open_plan dash || bad=1
  next_check_leftovers dash || bad=1
  return $bad
}

# The state lines the check shows are the ones the script takes, so that
# neither can move without the other.
test_next_forms_in_the_check_are_the_ones_the_script_takes() {
  local file="$KIT/checks/plans.md" d bad=0 line n=0 forms
  [[ -f "$file" ]] || { echo "checks/plans.md does not exist"; return 1; }
  forms="$(awk '/^## Its smallest form/{on=1; next} /^## /{on=0} on && /^```/{f=!f; next} on && f && /^[[:space:]]*State:/{sub(/^[[:space:]]+/, ""); print}' "$file")"
  [[ -n "$forms" ]] || { echo "the code block under \"Its smallest form\" has no State: lines"; return 1; }
  d="$(next_project)"
  while IFS= read -r line; do
    n=$((n + 1))
    mkdir -p "$d/plans"
    printf '# Form %s\n\n%s\n\n- [ ] A step\n' "$n" "$line" >"$d/plans/f$n.md"
  done <<<"$forms"
  ((n >= 4)) || { echo "the check shows $n forms, not the four"; bad=1; }
  next_commit "$d" "Add one plan to each form."
  next_run sh "$d"
  next_lacks "refused" || bad=1
  ((NEXT_STATUS == 0)) || { echo "exit status was $NEXT_STATUS for the check's forms"; bad=1; }
  # And a form it does not show is refused.
  d="$(next_project)"
  printf '# Not a form\n\nState: done.\n\n- [ ] A step\n' | next_write "$d" plans/x.md
  next_commit "$d" "Add a plan."
  next_run sh "$d"
  next_has 'refused, the state line is not one of the four: "State: done."' || bad=1
  return $bad
}

# Nothing on the screen is cut: a reader cannot tell what was lost.
test_next_cuts_nothing() {
  local d bad=0 next60 title70
  d="$(next_project)"
  next60="Does the sixty character next column show all of it, question?"
  title70="A title of seventy characters or so that is longer than the column it sits in"
  next_write "$d" plans/long.md <<PLAN
# $title70

State: building, part 1 of 1.

- [ ] $next60
PLAN
  next_write "$d" plans/stopped.md <<'PLAN'
# Stopped

State: parked, waiting on the renderer's next release.

- [ ] One
PLAN
  next_commit "$d" "Add the plans."
  next_run sh "$d"
  next_has "next: 1, $next60" || bad=1
  next_has "$title70" || bad=1
  next_has "parked: waiting on the renderer's next release." || bad=1
  return $bad
}

# A landed plan's commit has to be on the default branch.
test_next_checks_that_a_landed_plans_commit_is_on_the_default_branch() {
  local d bad=0 head; d="$(next_project)"; head="$(git -C "$d" rev-parse HEAD)"
  printf '# Real landing\n\nState: landed on main at %s, 2026-10-01.\n\n- [x] One\n' "$head" | next_write "$d" plans/real.md
  printf '# Imagined landing\n\nState: landed on main at 1a2b3c4, 2026-10-02.\n\n- [x] One\n' | next_write "$d" plans/imagined.md
  next_commit "$d" "Add the plans."
  next_run sh "$d"
  next_has "Imagined landing: landed at 1a2b3c4, which main does not have" || bad=1
  next_lacks "Real landing: landed at" || bad=1
  next_has "2 plans landed" || bad=1
  return $bad
}

# A file touched and not changed is not a change: status compares contents.
test_next_does_not_call_a_touched_file_changed() {
  local d bad=0; d="$(next_project)"
  next_write "$d" plans/steady.md <<'PLAN'
# Steady plan

State: agreed 2026-10-18.

- [ ] One
PLAN
  next_commit "$d" "Add the plan."
  sleep 1; touch "$d/readme.txt" "$d/plans/steady.md"
  next_run sh "$d"
  next_lacks "uncommitted" || bad=1
  next_line_has "Steady plan" "$(next_today)" || bad=1
  return $bad
}

# A worktree under the project is named from the project's own root.
test_next_names_a_worktree_under_the_project_relatively() {
  local d bad=0; d="$(next_project)"
  git -C "$d" worktree add -q "$d/inside" -b inside
  next_run sh "$d"
  next_has "worktree inside on inside:" || bad=1
  next_lacks "worktree /" || bad=1
  return $bad
}
