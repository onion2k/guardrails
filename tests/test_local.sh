# The kit is for local development, and holds nothing that needs a runner, a
# workflow, a bot or a host's own scanning. What can go wrong is a check, a
# rule or a skill growing a line that assumes one, so that a project with no
# CI is told to do something it cannot. These hold the kit's files to the
# words that give it away, and the CI check to staying gone.

# The words that mean a runner, or something that runs on one. `npm ci` and
# `pnpm ci` are the package managers' own command for a clean install, and
# are taken out of each line before it is matched.
LOCAL_WORDS='ci|workflow|workflows|dependabot|renovate|codeql|zizmor|actionlint|pull_request_target|github_token|runs-on'

test_local_nothing_needs_a_runner() {
  local bad=0 file hits
  for file in "$KIT/GUARDRAILS.md" "$KIT/INSTALL.md" "$KIT"/checks/*.md "$KIT"/skills/*/SKILL.md "$KIT"/templates/*; do
    [[ -f "$file" ]] || continue
    hits="$({
      sed -E 's/(npm|pnpm) ci//g' "$file" | grep -niwE "$LOCAL_WORDS"
      sed -E 's/(npm|pnpm) ci//g' "$file" | grep -nF '.github/'
    } | sort -n -u)"
    if [[ -n "$hits" ]]; then
      while IFS= read -r line; do
        echo "${file#"$KIT"/}:$line"
      done <<<"$hits"
      bad=1
    fi
  done
  return $bad
}

test_local_no_ci_check() {
  [[ ! -e "$KIT/checks/ci.md" ]] || { echo "checks/ci.md is there; the kit holds nothing that needs a runner"; return 1; }
}
