# Dependencies: a rule in GUARDRAILS.md that points at its check, the
# questions a project answers written once in the check and asked at
# install, and a new dependency a decision in a feature's spec.

test_dependencies_rule_points_at_its_check() {
  awk '/^## Structure/{on=1; next} /^## /{on=0} on' "$KIT/GUARDRAILS.md" | grep -q 'checks/dependencies.md' \
    || { echo "Structure does not point at checks/dependencies.md"; return 1; }
}

test_dependencies_questions_are_written_once_and_asked() {
  local bad=0 check="$KIT/checks/dependencies.md" before
  [[ -f "$check" ]] || { echo "no checks/dependencies.md"; return 1; }
  grep -q '^The questions a project answers' "$check" || { echo "the check does not hold the questions a project answers"; bad=1; }
  before="$(awk '/^## Before anything/{on=1; next} /^## /{on=0} on' "$KIT/INSTALL.md")"
  grep -q 'checks/dependencies.md' <<<"$before" || { echo "INSTALL.md's Before anything does not point at the dependency questions"; bad=1; }
  local word
  for word in "audit threshold" "allowed licences" "how updates arrive"; do
    grep -qi "$word" <<<"$before" || { echo "INSTALL.md does not ask: $word"; bad=1; }
    grep -qi "$word" "$check" || { echo "the check does not hold the question: $word"; bad=1; }
  done
  return $bad
}

test_dependencies_template_has_somewhere_for_the_answers() {
  local bad=0 t="$KIT/templates/AGENTS.md"
  awk '/^## Commands/{on=1; next} /^## /{on=0} on' "$t" | grep -qi 'audit' || { echo "the template's Commands has no audit"; bad=1; }
  awk '/^## Commands/{on=1; next} /^## /{on=0} on' "$t" | grep -qi 'updates' || { echo "the template's Commands has no updates"; bad=1; }
  awk '/^## Gates/{on=1; next} /^## /{on=0} on' "$t" | grep -qi 'licences' || { echo "the template's Gates has no allowed licences"; bad=1; }
  return $bad
}

test_dependencies_feature_spec_decides_a_new_one() {
  grep -qi 'new dependency' "$KIT/skills/feature/SKILL.md" \
    || { echo "the feature skill does not make a new dependency a decision in the spec"; return 1; }
}
