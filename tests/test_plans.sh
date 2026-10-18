# The words about plans, said the same in every file that touches one: the
# rule, the skills, the template and the installer. A plan kept in `plans/`
# with a state line is only read by `next` if each of these agrees on where
# it goes and what the line is; one file left saying "a file the project
# points to" sends the next session back to guessing.

# A file's text, or a section's, on one line, so that the formatter's
# wrapping does not matter to what is held.
plans_flat() { tr '\n' ' ' | tr -s ' '; }

# Fails, saying what, when the text on stdin lacks the phrase.
plans_needs() {
  local text; text="$(plans_flat)"
  grep -qF -- "$2" <<<"$text" || { echo "$1 does not say: $2"; return 1; }
}

test_plans_rule_names_the_place_and_the_check() {
  local bad=0 before bullet
  before="$(section GUARDRAILS.md "Before building")"
  [[ -n "$before" ]] || { echo "GUARDRAILS.md has no Before building section"; return 1; }
  plans_needs "Before building" 'plans/' <<<"$before" || bad=1
  plans_needs "Before building" 'checks/plans.md' <<<"$before" || bad=1
  bullet="$(section GUARDRAILS.md Reporting | awk '/^- \*\*A report ends with the next step/{on=1; print; next} /^- /{on=0} on')"
  if [[ -z "$bullet" ]]; then
    echo "Reporting has no bullet starting with **A report ends with the next step"; bad=1
  else
    plans_needs "the report-ends bullet" 'state line' <<<"$bullet" || bad=1
  fi
  return $bad
}

test_plans_skills_say_the_same_thing() {
  local bad=0 skills="$KIT/skills" step7 step3
  [[ -f "$skills/next/SKILL.md" ]] || { echo "skills/next/SKILL.md does not exist"; bad=1; }
  plans_needs "the feature skill" 'plans/' <"$skills/feature/SKILL.md" || bad=1
  plans_needs "the feature skill" 'checks/plans.md' <"$skills/feature/SKILL.md" || bad=1
  plans_needs "the guardrails skill" 'plans/' <"$skills/guardrails/SKILL.md" || bad=1
  step7="$(awk '/^## 7\./{on=1; next} /^## /{on=0} on' "$skills/land/SKILL.md")"
  [[ -n "$step7" ]] || { echo "the land skill has no step 7"; bad=1; }
  plans_needs "the land skill's step 7" 'landed' <<<"$step7" || bad=1
  plans_needs "the tidy skill" 'guardrails/next' <"$skills/tidy/SKILL.md" || bad=1
  plans_needs "the tidy skill" 'no branch is at work on' <"$skills/tidy/SKILL.md" || bad=1
  # The one command that every find accepts, which is the one the script runs.
  step3="$(awk '/^## 3\./{on=1; next} /^## /{on=0} on' "$skills/tidy/SKILL.md")"
  plans_needs "the tidy skill's step 3" '-mmin -60' <<<"$step3" || bad=1
  ! grep -qF -- '-newermt' <<<"$step3" || { echo "the tidy skill's step 3 still has -newermt, which not every find accepts"; bad=1; }
  if [[ -f "$skills/next/SKILL.md" ]]; then
    plans_needs "the next skill" 'guardrails/next' <"$skills/next/SKILL.md" || bad=1
    plans_needs "the next skill" 'writes nothing' <"$skills/next/SKILL.md" || bad=1
    plans_needs "the next skill" 'open each open plan' <"$skills/next/SKILL.md" || bad=1
  fi
  return $bad
}

test_plans_template_and_installer_name_the_script() {
  local bad=0
  plans_needs "the template's Commands" 'next' <<<"$(section templates/AGENTS.md Commands)" || bad=1
  plans_needs "INSTALL.md's Installing" 'guardrails/next' <<<"$(section INSTALL.md Installing)" || bad=1
  plans_needs "INSTALL.md's Updating" 'guardrails/next' <<<"$(section INSTALL.md Updating)" || bad=1
  # That the kit writes nothing in plans/ is a sentence an agent reads; the
  # test holds that plans/ is spoken of at all, not the sentence's wording.
  plans_needs "INSTALL.md" 'plans/' <"$KIT/INSTALL.md" || bad=1
  return $bad
}

test_plans_check_says_what_the_script_assumes() {
  plans_needs "checks/plans.md" '(assumed)' <"$KIT/checks/plans.md"
}
