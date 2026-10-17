# Security: the rules point at the checks that hold them, the agent's own
# handling of a secret is said where verifying is, and the kit ships
# nothing a project's secret scanner would stop.

section_of() { awk -v h="## $2" '$0==h{on=1; next} /^## /{on=0} on' "$KIT/$1"; }

test_security_rules_point_at_their_checks() {
  local bad=0 s; s="$(section_of GUARDRAILS.md Structure)"
  grep -A8 '^- \*\*A secret never enters the tree' <<<"$s" | grep -q 'checks/secrets.md' \
    || { echo "the secrets rule does not point at checks/secrets.md"; bad=1; }
  grep -A8 '^- \*\*The least that works' <<<"$s" | grep -q 'checks/ci.md' \
    || { echo "the least-that-works rule does not point at checks/ci.md"; bad=1; }
  return $bad
}

test_security_agent_never_repeats_a_secret() {
  section_of GUARDRAILS.md Verifying | grep -qi 'a secret is never printed' \
    || { echo "Verifying does not say a secret is never printed"; return 1; }
}

test_security_quick_check_runs_the_secret_scan() {
  grep -q '(secrets.md)' "$KIT/checks/quick-check.md" \
    || { echo "quick-check.md does not point at secrets.md"; return 1; }
}

# Shapes a scanner stops: an AWS key id, a GitHub token, a private key's
# armour. The kit names them in words, never by example.
test_security_kit_ships_nothing_shaped_like_a_secret() {
  local found
  found="$(cd "$KIT" && grep -rnE 'AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36}|-----BEGIN [A-Z ]*PRIVATE KEY-----' \
    --include='*.md' --include='*.sh' --include='pre-commit' --include='commit-msg' . | grep -v '^\./tests/test_security\.sh:')"
  [[ -z "$found" ]] || { echo "shaped like a secret:"; sed 's/^/  /' <<<"$found"; return 1; }
}
