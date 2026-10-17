# How a change lands: said once in GUARDRAILS.md, asked at install, carried
# out by the land skill, and held where it can be by the commit-msg hook.

# The parts of "Landing a change", in the order a change meets them.
LANDING_PARTS=("A commit" "Where a change is made" "Green before" "A PR" "Merging" "Releases" "Clearing up" "Who may act")

landing_section() { awk '/^## Landing a change/{on=1; next} /^## /{on=0} on' "$KIT/GUARDRAILS.md"; }

test_landing_rules_have_their_parts_in_order() {
  local got want
  got="$(landing_section | grep -o '^- \*\*[^*]*\*\*' | sed -E 's/^- \*\*//; s/\*\*$//; s/[.:,]$//')"
  want="$(printf '%s\n' "${LANDING_PARTS[@]}")"
  [[ -n "$got" ]] || { echo "GUARDRAILS.md has no Landing a change section, or it has no parts"; return 1; }
  [[ "$got" == "$want" ]] || { echo "Landing a change has:"; sed 's/^/  /' <<<"$got"; echo "want:"; sed 's/^/  /' <<<"$want"; return 1; }
  ! grep -q '^## Commits' "$KIT/GUARDRAILS.md" || { echo "GUARDRAILS.md still has a Commits section beside it"; return 1; }
}

test_landing_project_file_has_its_heading() {
  awk '/^## The project.s file/{on=1; next} /^## /{on=0} on' "$KIT/GUARDRAILS.md" | grep -q '^- \*\*How a change lands' \
    || { echo "GUARDRAILS.md's project file headings do not include How a change lands"; return 1; }
}

test_landing_install_asks_and_points_at_the_rules() {
  # The questions are asked in "Before anything", before anything is written.
  local bad=0 doc; doc="$(awk '/^## Before anything/{on=1; next} /^## /{on=0} on' "$KIT/INSTALL.md")"
  grep -qi 'merge style' <<<"$doc" || { echo "INSTALL.md does not ask the merge style"; bad=1; }
  grep -qi 'without asking' <<<"$doc" || { echo "INSTALL.md does not ask about acting without asking"; bad=1; }
  grep -q '_Landing a change_' <<<"$doc" || { echo "INSTALL.md does not point at GUARDRAILS.md's Landing a change"; bad=1; }
  return $bad
}

test_landing_skill_acts_only_on_the_word_or_a_grant() {
  local file="$KIT/skills/land/SKILL.md" bad=0
  [[ -f "$file" ]] || { echo "no land skill"; return 1; }
  # Each step that reaches the remote says so itself, not only the opening.
  local step
  for step in "## 3\\." "## 5\\." "## 6\\."; do
    awk -v h="^$step" '$0 ~ h {on=1; next} /^## /{on=0} on' "$file" | grep -qi "only on the user's word" \
      || { echo "the land skill's step ${step//\\/} does not say only on the user's word"; bad=1; }
  done
  grep -qi "grant" "$file" || { echo "the land skill never mentions the project file's grant"; bad=1; }
  grep -qi "default branch" "$file" || { echo "the land skill assumes a branch name instead of reading the default"; bad=1; }
  return $bad
}

# The commit-msg hook, run as git runs it: with the path of a file holding
# the message.
run_commit_msg() {
  local f; f="$(mktemp)"; printf '%b' "$1" >"$f"
  sh "$KIT/templates/commit-msg" "$f" >/dev/null 2>&1
}

test_landing_commit_msg_hook_holds_the_shape() {
  local bad=0
  [[ -x "$KIT/templates/commit-msg" ]] || { echo "templates/commit-msg is not there, or not executable"; return 1; }
  run_commit_msg 'Say what the change does now.\n\nThe body says why.\n' || { echo "refused a good message"; bad=1; }
  run_commit_msg 'Say what the change does now.\n\nThe body says why.\n# a comment git strips\n' || { echo "refused a good message with a comment"; bad=1; }
  run_commit_msg "Merge branch 'feature' into main\n" || { echo "refused git's own merge message"; bad=1; }
  if run_commit_msg 'Say what the change does now.\n'; then echo "let through a message with no body"; bad=1; fi
  if run_commit_msg 'Say what the change does now.\nThe body, with no blank line.\n'; then echo "let through no blank line"; bad=1; fi
  if run_commit_msg 'say what it does without a stop\n\nBody.\n'; then echo "let through a summary that is not a sentence"; bad=1; fi
  if run_commit_msg "X$(printf 'x%.0s' {1..99}).\n\nBody.\n"; then echo "let through a summary over 100 characters"; bad=1; fi
  if run_commit_msg '\n\n'; then echo "let through an empty message"; bad=1; fi
  return $bad
}
