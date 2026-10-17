# Nothing left behind: the rule under Clearing up, the tidy skill's five
# kinds and its care with what it may not undo, and the stale threshold
# asked where the other landing questions are.

test_tidy_rule_is_under_clearing_up() {
  awk '/^## Landing a change/{on=1; next} /^## /{on=0} on' "$KIT/GUARDRAILS.md" \
    | awk '/^- \*\*Clearing up/{on=1; print; next} /^- \*\*/{on=0} on' \
    | tr '\n' ' ' | grep -qi 'leaves nothing of its own behind' \
    || { echo "Clearing up does not say a session leaves nothing of its own behind"; return 1; }
}

test_tidy_skill_names_its_kinds_and_its_care() {
  local file="$KIT/skills/tidy/SKILL.md" bad=0 kind
  [[ -f "$file" ]] || { echo "no tidy skill"; return 1; }
  # Read step 3 as one line, so that the formatter's wrapping does not matter.
  local kinds; kinds="$(awk '/^## 3\./{on=1; next} /^## /{on=0} on' "$file" | tr '\n' ' ' | tr -s ' ')"
  for kind in merged unmerged uncommitted stale "in use"; do
    grep -q -- "- \*\*$kind:\*\*" <<<"$kinds" || { echo "the tidy skill's step 3 does not say what $kind is"; bad=1; }
  done
  grep -qi 'a name is never enough' <<<"$kinds" || { echo "the tidy skill does not say a name is never enough"; bad=1; }
  # In the step's opening, before its first action, where it binds them all.
  awk '/^## 5\./{on=1; next} /^## /{on=0} on && /^- /{exit} on' "$file" | tr '\n' ' ' | grep -qi "only on the user's word" \
    || { echo "the tidy skill's acting step does not hold itself to the user's word"; bad=1; }
  grep -qi 'squash' "$file" || { echo "the tidy skill does not say how a squashed branch is known merged"; bad=1; }
  return $bad
}

test_tidy_landing_check_points_at_it() {
  grep -q 'tidy' "$KIT/checks/landing.md" || { echo "checks/landing.md does not point at the tidy skill"; return 1; }
}

test_tidy_stale_threshold_is_asked() {
  local bad=0
  grep -qi 'stale' "$KIT/templates/AGENTS.md" || { echo "the template has no stale threshold"; bad=1; }
  awk '/^## Landing a change/{on=1; next} /^## /{on=0} on' "$KIT/GUARDRAILS.md" | grep -q '^[0-9]\. \*\*Stale after' \
    || { echo "GUARDRAILS.md's landing questions do not ask the stale threshold"; bad=1; }
  return $bad
}
