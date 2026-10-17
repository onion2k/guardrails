# INSTALL.md is the installer: an agent follows it to put the kit into a
# project and to take a newer one in. What the shell installer held in code
# it holds in words, so these tests hold the words to naming each thing it
# must: every path the kit writes, every refusal, every harness.

install_doc() { cat "$KIT/INSTALL.md" 2>/dev/null; }

test_install_doc_names_every_path_the_kit_writes() {
  local doc bad=0 path
  doc="$(install_doc)"; [[ -n "$doc" ]] || { echo "no INSTALL.md"; return 1; }
  for path in guardrails/GUARDRAILS.md guardrails/checks/ guardrails/INSTALLED.md \
    .agents/skills/ .claude/skills/ AGENTS.md CLAUDE.md GEMINI.md .githooks/pre-commit \
    templates/AGENTS.md templates/CLAUDE.md templates/GEMINI.md templates/pre-commit; do
    grep -qF -- "$path" <<<"$doc" || { echo "INSTALL.md does not name $path"; bad=1; }
  done
  return $bad
}

test_install_doc_names_every_harness() {
  local doc bad=0 h
  doc="$(install_doc)"; [[ -n "$doc" ]] || { echo "no INSTALL.md"; return 1; }
  for h in "Claude Code" "Codex" "Gemini CLI" "Cursor"; do
    grep -qF "$h" <<<"$doc" || { echo "INSTALL.md does not name $h"; bad=1; }
  done
  return $bad
}

# The refusals, each a heading of its own under "Refusals", so that an
# agent finds them and a reader can count them.
INSTALL_REFUSALS=("A hand edit" "A guardrails folder the kit did not write" "The kit itself" "No git")

test_install_doc_names_every_refusal() {
  local got want
  [[ -f "$KIT/INSTALL.md" ]] || { echo "no INSTALL.md"; return 1; }
  got="$(awk '/^## Refusals/{on=1; next} /^## /{on=0} on && /^### /' "$KIT/INSTALL.md" | sed 's/^### //')"
  want="$(printf '%s\n' "${INSTALL_REFUSALS[@]}")"
  [[ "$got" == "$want" ]] || { echo "Refusals has:"; sed 's/^/  /' <<<"$got"; echo "want:"; sed 's/^/  /' <<<"$want"; return 1; }
}

# What it tells the agent to add to a project's own AGENTS.md is the
# template's own line, word for word: said twice, held equal.
test_install_doc_gives_the_templates_read_line() {
  local line
  line="$(grep 'guardrails/GUARDRAILS.md before changing anything' "$KIT/templates/AGENTS.md")"
  [[ -n "$line" ]] || { echo "the template has no read line"; return 1; }
  grep -qF -- "$line" "$KIT/INSTALL.md" 2>/dev/null || { echo "INSTALL.md does not give the template's line: $line"; return 1; }
}

test_install_doc_says_how_to_get_the_kit_and_update() {
  local doc bad=0 word
  doc="$(install_doc)"; [[ -n "$doc" ]] || { echo "no INSTALL.md"; return 1; }
  for word in "git clone" "--branch" "ls-remote" "## Installing" "## Updating" "core.hooksPath"; do
    grep -qF -- "$word" <<<"$doc" || { echo "INSTALL.md does not say: $word"; bad=1; }
  done
  return $bad
}
