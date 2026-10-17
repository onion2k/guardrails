# The leftovers fixture, held to being what it says it is, so that a
# trial of the tidy skill against it is held to the right answer.

build_fixture() { local d; d="$(mktemp -d)"; "$KIT/tests/make-leftovers" "$d" >/dev/null 2>&1 || return 1; printf '%s\n' "$d"; }

# Merged, as the tidy skill judges it: by ancestry, or merging it into main
# would change nothing.
landed_on_main() {
  local repo="$1" ref="$2" main="${3:-main}"
  git -C "$repo" merge-base --is-ancestor "$ref" "$main" && return 0
  [[ "$(git -C "$repo" merge-tree --write-tree "$main" "$ref" 2>/dev/null)" == "$(git -C "$repo" rev-parse "$main^{tree}")" ]]
}

test_fixture_is_what_it_says() {
  local d w bad=0
  d="$(build_fixture)" || { echo "the fixture would not build"; return 1; }
  w="$d/work"
  git -C "$w" merge-base --is-ancestor merged main || { echo "merged is not an ancestor of main"; bad=1; }
  ! git -C "$w" merge-base --is-ancestor squashed main || { echo "squashed is an ancestor, so it tests nothing"; bad=1; }
  landed_on_main "$w" squashed || { echo "squashed is not landed by its tree"; bad=1; }
  ! landed_on_main "$w" unmerged || { echo "unmerged is landed"; bad=1; }
  ! git -C "$w" show-ref -q refs/heads/landed || { echo "landed is still a local branch"; bad=1; }
  landed_on_main "$w" origin/landed origin/main || { echo "origin/landed is not landed"; bad=1; }
  ! landed_on_main "$w" origin/cloud origin/main || { echo "origin/cloud is landed"; bad=1; }
  [[ "$(git -C "$w" stash list | wc -l | tr -d ' ')" == 1 ]] || { echo "there is not one stash"; bad=1; }
  [[ -n "$(git -C "$w" status --porcelain)" ]] || { echo "nothing is uncommitted"; bad=1; }
  [[ -z "$(git -C "$d/wt-done" status --porcelain)" ]] || { echo "wt-done is not clean"; bad=1; }
  git -C "$w" worktree list --porcelain | grep -A4 "wt-locked$" | grep -q '^locked' || { echo "wt-locked is not locked"; bad=1; }
  [[ -n "$(git -C "$d/wt-locked" status --porcelain)" ]] || { echo "wt-locked has no change in it"; bad=1; }
  return $bad
}
