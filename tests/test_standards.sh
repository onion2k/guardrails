# The standards: each rule said once, in GUARDRAILS.md, and held by a check
# that has a file of its own. These hold the rules and the checks to
# pointing at each other, and the quick check to not saying again what its
# parts' files say.

# The section of a markdown file under a "## " heading, up to the next.
section() { awk -v h="## $2" '$0==h{on=1; next} /^## /{on=0} on' "$KIT/$1"; }

test_standards_rules_point_at_their_checks() {
  local bad=0
  section GUARDRAILS.md Style | grep -q 'checks/formatting.md' || { echo "Style does not point at checks/formatting.md"; bad=1; }
  section GUARDRAILS.md Style | grep -q 'checks/lint.md' || { echo "Style does not point at checks/lint.md"; bad=1; }
  section GUARDRAILS.md Structure | grep -q 'checks/structure.md' || { echo "Structure does not point at checks/structure.md"; bad=1; }
  section GUARDRAILS.md Verifying | grep -q 'checks/verification.md' || { echo "Verifying does not point at checks/verification.md"; bad=1; }
  return $bad
}

test_standards_quick_check_points_and_does_not_repeat() {
  local bad=0 file="$KIT/checks/quick-check.md"
  grep -q '(formatting.md)' "$file" || { echo "quick-check.md does not link to formatting.md"; bad=1; }
  grep -q '(lint.md)' "$file" || { echo "quick-check.md does not link to lint.md"; bad=1; }
  local found; found="$(grep -niE 'type-aware|promise' "$file")"
  [[ -z "$found" ]] || { echo "quick-check.md says what lint.md says:"; sed 's/^/  /' <<<"$found"; bad=1; }
  return $bad
}

# The order a project takes the checks on, as the table gives it.
CHECK_ORDER="quick-check formatting lint structure dependencies unit test-api invariants fuzzer determinism persisted-shapes bounded gates look verification landing mutation"

test_standards_table_is_in_the_order_they_are_taken_on() {
  local got
  got="$(grep '^| \[' "$KIT/GUARDRAILS.md" | grep -o '(checks/[a-z-]*\.md)' | sed 's|(checks/||; s|\.md)||' | tr '\n' ' ' | sed 's/ $//')"
  [[ "$got" == "$CHECK_ORDER" ]] || { echo "the table's order is: $got"; echo "want:               $CHECK_ORDER"; return 1; }
}
