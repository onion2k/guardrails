# The checks' files: each in the shape a reader relies on, and each one
# the rules lean on present, with none here the rules do not name.

# The sections every check's file has, in this order.
CHECK_SECTIONS=("What it holds" "Its smallest form" "Seen failing" "Where it cannot apply")

test_checks_have_their_sections() {
  local bad=0 file
  for file in "$KIT"/checks/*.md; do
    [[ -e "$file" ]] || { echo "no check files in checks/"; return 1; }
    local got
    got="$(grep '^## ' "$file" | sed 's/^## //')"
    local want
    want="$(printf '%s\n' "${CHECK_SECTIONS[@]}")"
    if [[ "$got" != "$want" ]]; then
      echo "${file#"$KIT"/} has sections:"
      printf '%s\n' "$got" | sed 's/^/  /'
      bad=1
    fi
    if ! head -1 "$file" | grep -q '^# '; then
      echo "${file#"$KIT"/} does not start with a title"
      bad=1
    fi
  done
  return $bad
}

test_checks_are_each_named_by_the_rules() {
  local bad=0 named file
  named="$(grep -o '(checks/[a-z-]*\.md)' "$KIT/GUARDRAILS.md" | tr -d '()' | sort -u)"
  [[ -n "$named" ]] || { echo "GUARDRAILS.md names no checks"; return 1; }
  for file in $named; do
    [[ -f "$KIT/$file" ]] || { echo "GUARDRAILS.md names $file, which is not there"; bad=1; }
  done
  for file in "$KIT"/checks/*.md; do
    [[ -e "$file" ]] || continue
    grep -qx "${file#"$KIT"/}" <<<"$named" || { echo "${file#"$KIT"/} is not in GUARDRAILS.md's table"; bad=1; }
  done
  return $bad
}
