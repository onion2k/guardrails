# The kit's markdown, formatted as prettier formats it by default. A
# project that installs the kit and checks its own formatting checks these
# files too, and one the kit got wrong breaks that project's hook: it is
# what the first trial found.

# Prettier from the PATH, or from $PRETTIER.
prettier_here() { command -v "${PRETTIER:-prettier}" 2>/dev/null; }

test_format_kit_markdown_is_as_prettier_writes_it() {
  local bin; bin="$(prettier_here)"
  [[ -n "$bin" ]] || { echo "no prettier here; set PRETTIER to one"; return 77; }
  local out
  out="$(cd "$KIT" && "$bin" --no-config --check GUARDRAILS.md README.md checks/*.md skills/*/SKILL.md templates/*.md 2>&1)" \
    || { echo "$out" | grep warn; return 1; }
}
