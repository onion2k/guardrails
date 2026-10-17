# The templates a project is given: the project file with the headings the
# rules say it must have, and the files that point each harness at it.

# The headings GUARDRAILS.md says a project file has, read off its list:
# each bold name at the start of a list item, under "The project's file".
project_file_headings() {
  awk '/^## The project.s file/{on=1; next} /^## /{on=0} on' "$KIT/GUARDRAILS.md" \
    | grep -o '^- \*\*[^*]*\*\*' | sed -E 's/^- \*\*//; s/\*\*$//; s/[:,]$//'
}

test_templates_project_file_has_the_rules_headings() {
  local want got
  want="$(project_file_headings)"
  [[ -n "$want" ]] || { echo "found no headings in GUARDRAILS.md's list"; return 1; }
  [[ -f "$KIT/templates/AGENTS.md" ]] || { echo "templates/AGENTS.md is not there"; return 1; }
  got="$(grep '^## ' "$KIT/templates/AGENTS.md" | sed 's/^## //')"
  if [[ "$got" != "$want" ]]; then
    echo "templates/AGENTS.md has headings:"; printf '%s\n' "$got" | sed 's/^/  /'
    echo "GUARDRAILS.md lists:"; printf '%s\n' "$want" | sed 's/^/  /'
    return 1
  fi
}

test_templates_project_file_brings_in_the_rules() {
  local file="$KIT/templates/AGENTS.md" line
  [[ -f "$file" ]] || { echo "templates/AGENTS.md is not there"; return 1; }
  line="$(grep -n 'guardrails/GUARDRAILS.md' "$file" | head -1)"
  [[ -n "$line" ]] || { echo "templates/AGENTS.md does not name guardrails/GUARDRAILS.md"; return 1; }
  # Said in words, for a harness that expands no imports, and imported on the
  # same line, outside a code span, for one that does.
  grep -qiE 'read [^@]*guardrails/GUARDRAILS\.md' "$file" \
    || { echo "templates/AGENTS.md does not tell the reader to read the rules"; return 1; }
  grep -qE '(^|[^`])@guardrails/GUARDRAILS\.md([^`]|$)' "$file" \
    || { echo "templates/AGENTS.md does not import @guardrails/GUARDRAILS.md outside a code span"; return 1; }
}

test_templates_harness_files_point_at_the_project_file() {
  local bad=0 name
  for name in CLAUDE.md GEMINI.md; do
    if [[ "$(cat "$KIT/templates/$name" 2>/dev/null)" != "@AGENTS.md" ]]; then
      echo "templates/$name is not the one line @AGENTS.md"; bad=1
    fi
  done
  return $bad
}

test_templates_hook_refuses_until_it_is_told_the_check() {
  local hook="$KIT/templates/pre-commit" out
  [[ -x "$hook" ]] || { echo "templates/pre-commit is not there, or not executable"; return 1; }
  # A hook with no check named passes every commit in silence unless it
  # refuses; one that has been told runs what it was told.
  if out="$(sh "$hook" 2>&1)"; then echo "the hook passed with no check named"; return 1; fi
  grep -q 'quick check' <<<"$out" || { echo "the hook refused without saying why: $out"; return 1; }
  local d; d="$(mktemp -d)"
  sed "s|^QUICK_CHECK=.*|QUICK_CHECK='exit 0'|" "$hook" >"$d/ok"
  sed "s|^QUICK_CHECK=.*|QUICK_CHECK='exit 3'|" "$hook" >"$d/bad"
  sh "$d/ok" || { echo "the hook refused with a passing check named"; return 1; }
  if sh "$d/bad" >/dev/null 2>&1; then echo "the hook passed with a failing check named"; return 1; fi
  rm -rf "$d"
}
