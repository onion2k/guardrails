# The mutation check: said as a figure someone owns and a run that can be
# redone, and not as a tool that "can stand beside" the hand check. What
# can go wrong is the check going back to advice nobody follows, or the
# rules, the gates, the template and the skills not pointing at it.

# The section of a markdown file under a "## " heading, up to the next.
mutation_section() { awk -v h="## $2" '$0==h{on=1; next} /^## /{on=0} on' "$KIT/$1"; }

test_mutation_check_names_its_figure() {
  local bad=0 file="$KIT/checks/mutation.md" word flat
  # Read as one line, so that the formatter's wrapping does not matter.
  flat="$(tr '\n' ' ' <"$file" | tr -s ' ')"
  ! grep -q 'now and then' <<<"$flat" || { echo "checks/mutation.md still says the tool is run now and then"; bad=1; }
  for word in Survived NoCoverage 'held exactly'; do
    grep -q -- "$word" <<<"$flat" || { echo "checks/mutation.md does not say $word"; bad=1; }
  done
  return $bad
}

test_mutation_check_runs_on_what_the_change_touched() {
  local bad=0 file="$KIT/checks/mutation.md"
  tr '\n' ' ' <"$file" | tr -s ' ' | grep -q 'files the change touched' \
    || { echo "checks/mutation.md does not say the per-change run is over the files the change touched"; bad=1; }
  tr '\n' ' ' <"$file" | tr -s ' ' | grep -q 'put the bug back themselves' \
    || { echo "checks/mutation.md does not say a reader could put the bug back themselves"; bad=1; }
  return $bad
}

test_mutation_gates_point_at_it() {
  grep -q 'mutation.md' "$KIT/checks/gates.md" || { echo "checks/gates.md does not point at mutation.md"; return 1; }
}

test_mutation_template_names_it() {
  local bad=0
  mutation_section templates/AGENTS.md Commands | grep -q 'mutate' || { echo "the template's Commands does not name mutate"; bad=1; }
  mutation_section templates/AGENTS.md Gates | grep -q 'mutants' || { echo "the template's Gates does not name mutants"; bad=1; }
  return $bad
}

test_mutation_skills_run_the_gate() {
  local bad=0
  mutation_section skills/feature/SKILL.md '4. Verify and fix, once, at the end' | tr '\n' ' ' | grep -q 'mutation gate' \
    || { echo "the feature skill's verify step does not name the mutation gate"; bad=1; }
  mutation_section skills/bug/SKILL.md '5. Verify' | tr '\n' ' ' | grep -q 'mutation gate' \
    || { echo "the bug skill's verify step does not name the mutation gate"; bad=1; }
  return $bad
}

test_mutation_rules_name_the_gate() {
  # Point 8 only: from its number to the next point's.
  awk '/^8\. \*\*/{on=1} /^9\. \*\*/{on=0} on' "$KIT/GUARDRAILS.md" | tr '\n' ' ' | grep -q 'mutation gate' \
    || { echo "GUARDRAILS.md's point 8 does not name the mutation gate"; return 1; }
}
