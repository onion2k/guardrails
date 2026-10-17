# The skills: loadable by every harness that reads the Agent Skills format,
# and saying nothing only one harness, one model or one project would know.

SKILLS=(bug commit feature gate-moved guardrails land tidy)

# Words that belong to one harness, one vendor or one model. A skill or a
# rule that uses one works in that harness and reads as noise in the rest.
HARNESS_WORDS='EnterPlanMode|ExitPlanMode|AskUserQuestion|TodoWrite|TaskCreate|SendMessage|opusplan|\bopus\b|\bsonnet\b|\bhaiku\b|Claude|Anthropic|Codex|OpenAI|Gemini|Cursor|Copilot|\.claude/|CLAUDE\.md'

# A harness's own tools and the models: wrong even in INSTALL.md, which has
# to name the harnesses themselves to say where each looks.
TOOL_WORDS='EnterPlanMode|ExitPlanMode|AskUserQuestion|TodoWrite|TaskCreate|SendMessage|opusplan|\bopus\b|\bsonnet\b|\bhaiku\b'

# What a project names in its own file, and a skill must read from there.
PROJECT_WORDS='npm |npx |yarn |pnpm |vitest|playwright|jest|pytest|cargo |\btest/|\bsmoke/|\bsrc/|\bscripts/|seeds 1-'

test_skills_are_the_ones_the_kit_ships() {
  local got want
  got="$(cd "$KIT/skills" 2>/dev/null && ls -d */ 2>/dev/null | tr -d / | sort)"
  want="$(printf '%s\n' "${SKILLS[@]}" | sort)"
  [[ "$got" == "$want" ]] || { echo "skills/ has: $(echo $got)"; echo "want:       $(echo $want)"; return 1; }
}

# The frontmatter as the Agent Skills specification has it, and no more:
# Cursor is the strictest of the harnesses about it.
test_skills_frontmatter_is_to_the_specification() {
  local bad=0 skill file
  for skill in "${SKILLS[@]}"; do
    file="$KIT/skills/$skill/SKILL.md"
    [[ -f "$file" ]] || { echo "$skill: no SKILL.md"; bad=1; continue; }
    [[ "$(head -1 "$file")" == "---" ]] || { echo "$skill: SKILL.md does not open with ---"; bad=1; continue; }
    local front
    front="$(awk 'NR==1{next} /^---$/{exit} {print}' "$file")"
    local keys
    keys="$(grep -oE '^[a-zA-Z_-]+:' <<<"$front" | tr -d : | sort | tr '\n' ' ')"
    [[ "$keys" == "description name " ]] || { echo "$skill: frontmatter keys are: $keys"; bad=1; }
    local name desc
    name="$(sed -n 's/^name: *//p' <<<"$front")"
    desc="$(sed -n 's/^description: *//p' <<<"$front")"
    [[ "$name" == "$skill" ]] || { echo "$skill: name is '$name', not its folder's"; bad=1; }
    [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ && ${#name} -le 64 ]] || { echo "$skill: name '$name' is not lowercase words joined by hyphens, under 65"; bad=1; }
    [[ "$desc" != [\>\|]* ]] || { echo "$skill: description is a YAML block; the length cannot be checked, and some harnesses read one line"; bad=1; }
    ((${#desc} >= 1 && ${#desc} <= 1024)) || { echo "$skill: description is ${#desc} characters, not 1 to 1024"; bad=1; }
    local lines; lines="$(wc -l <"$file")"
    ((lines < 500)) || { echo "$skill: SKILL.md is $lines lines; the specification asks for under 500"; bad=1; }
  done
  return $bad
}

test_skills_and_rules_name_no_harness() {
  local found
  found="$(grep -nE "$HARNESS_WORDS" "$KIT"/skills/*/SKILL.md "$KIT/GUARDRAILS.md" "$KIT"/checks/*.md 2>/dev/null)"
  [[ -z "$found" ]] || { echo "names a harness, a vendor or a model:"; sed "s|$KIT/||; s/^/  /" <<<"$found"; return 1; }
}

test_install_doc_names_no_harness_tool() {
  local found
  found="$(grep -nE "$TOOL_WORDS" "$KIT/INSTALL.md" 2>/dev/null)"
  [[ -z "$found" ]] || { echo "INSTALL.md names a harness's own tool or a model:"; sed "s|$KIT/||; s/^/  /" <<<"$found"; return 1; }
}

test_skills_name_no_project_command_or_path() {
  local found
  found="$(grep -nE "$PROJECT_WORDS" "$KIT"/skills/*/SKILL.md 2>/dev/null)"
  [[ -z "$found" ]] || { echo "names what the project file should say:"; sed "s|$KIT/||; s/^/  /" <<<"$found"; return 1; }
}
