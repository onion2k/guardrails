# The installer, on throwaway projects made here, never a real checkout.
# What it must do: put the kit in, never write over what is the project's,
# do nothing when there is nothing to do, and show a newer kit's changes
# before writing them.

# A fresh project, at a path with a space in it, as a git repo unless asked.
new_project() {
  local root; root="$(mktemp -d)"
  mkdir -p "$root/a project"
  [[ "${1:-git}" == git ]] && git -C "$root/a project" init -q
  printf '%s\n' "$root/a project"
}

# Every file under a folder with its checksum, to tell whether anything moved.
fingerprint() {
  (cd "$1" && find . -type f ! -path './.git/*' -print0 | sort -z | xargs -0 cksum)
}

install_into() { "$KIT/install.sh" "$@" 2>&1; }

test_install_fresh_puts_the_kit_in() {
  local p bad=0 out; p="$(new_project)"
  out="$(install_into "$p")" || { echo "install failed:"; echo "$out"; return 1; }
  cmp -s "$KIT/GUARDRAILS.md" "$p/guardrails/GUARDRAILS.md" || { echo "guardrails/GUARDRAILS.md is not the kit's"; bad=1; }
  diff -r "$KIT/checks" "$p/guardrails/checks" >/dev/null || { echo "guardrails/checks is not the kit's"; bad=1; }
  cmp -s "$KIT/VERSION" "$p/guardrails/VERSION" || { echo "guardrails/VERSION is not the kit's"; bad=1; }
  local name skills
  for name in AGENTS.md CLAUDE.md GEMINI.md; do
    cmp -s "$KIT/templates/$name" "$p/$name" || { echo "$name is not the template"; bad=1; }
  done
  [[ -x "$p/.githooks/pre-commit" ]] || { echo ".githooks/pre-commit is not there, or not executable"; bad=1; }
  for skills in .agents/skills .claude/skills; do
    diff -r "$KIT/skills" "$p/$skills" >/dev/null || { echo "$skills is not the kit's skills"; bad=1; }
  done
  [[ -f "$p/guardrails/MANIFEST" ]] || { echo "no guardrails/MANIFEST"; bad=1; }
  return $bad
}

test_install_again_changes_nothing() {
  local p before after out; p="$(new_project)"
  install_into "$p" >/dev/null || { echo "first install failed"; return 1; }
  before="$(fingerprint "$p")"
  # A file written with the same bytes is still written: its time shows it.
  local mark; mark="$(mktemp)"; sleep 1
  out="$(install_into "$p")" || { echo "second install failed:"; echo "$out"; return 1; }
  after="$(fingerprint "$p")"
  [[ "$before" == "$after" ]] || { echo "the second install changed:"; diff <(echo "$before") <(echo "$after"); return 1; }
  local touched; touched="$(find "$p" -newer "$mark" ! -path '*/.git/*' ! -path "$p")"
  [[ -z "$touched" ]] || { echo "the second install wrote again:"; echo "$touched"; return 1; }
  grep -qi 'up to date' <<<"$out" || { echo "the second install did not say it was up to date:"; echo "$out"; return 1; }
}

test_install_leaves_the_projects_own_files() {
  local p before after out bad=0; p="$(new_project)"
  printf '# Ours\n\nOur own rules.\n' >"$p/AGENTS.md"
  printf 'Our Claude notes.\n' >"$p/CLAUDE.md"
  printf 'Our Gemini notes.\n' >"$p/GEMINI.md"
  printf '{}\n' >"$p/.prettierrc.json"
  mkdir -p "$p/.githooks" "$p/.claude/skills/feature"
  printf '#!/bin/sh\nexit 0\n' >"$p/.githooks/pre-commit"
  printf -- '---\nname: feature\ndescription: ours\n---\n' >"$p/.claude/skills/feature/SKILL.md"
  before="$(cd "$p" && cksum AGENTS.md CLAUDE.md GEMINI.md .githooks/pre-commit .claude/skills/feature/SKILL.md)"
  out="$(install_into "$p")" || { echo "install failed:"; echo "$out"; return 1; }
  after="$(cd "$p" && cksum AGENTS.md CLAUDE.md GEMINI.md .githooks/pre-commit .claude/skills/feature/SKILL.md)"
  [[ "$before" == "$after" ]] || { echo "the project's own files were written over:"; diff <(echo "$before") <(echo "$after"); bad=1; }
  grep -q 'guardrails/GUARDRAILS.md' <<<"$out" || { echo "it did not say what to add to AGENTS.md"; bad=1; }
  grep -q '@AGENTS.md' <<<"$out" || { echo "it did not say what to add to CLAUDE.md and GEMINI.md"; bad=1; }
  grep -q "own .githooks/pre-commit" <<<"$out" || { echo "it did not say the project's own hook was left"; bad=1; }
  grep -q "formatter" <<<"$out" || { echo "it did not say to have the project's formatter leave the kit's files"; bad=1; }
  grep -qi "own feature skill" <<<"$out" || { echo "it did not say the project's own feature skill was left"; bad=1; }
  [[ -f "$p/.claude/skills/bug/SKILL.md" ]] || { echo "the skills the project did not have were not put in"; bad=1; }
  [[ -f "$p/.agents/skills/feature/SKILL.md" ]] || { echo "the feature skill was left out of .agents/skills, where the project had none"; bad=1; }
  # Installed again, the project's own skill is still its own, and still said to be.
  out="$(install_into "$p")"
  [[ "$(cd "$p" && cksum .claude/skills/feature/SKILL.md)" == "$(grep 'claude/skills/feature' <<<"$after")" ]] || { echo "the project's skill was written over on a second install"; bad=1; }
  return $bad
}

test_install_for_one_harness() {
  local p out bad=0; p="$(new_project)"
  out="$(install_into "$p" --harness codex)" || { echo "install failed:"; echo "$out"; return 1; }
  [[ -d "$p/.agents/skills/bug" ]] || { echo "no .agents/skills for codex"; bad=1; }
  [[ ! -e "$p/.claude" ]] || { echo ".claude was written for codex alone"; bad=1; }
  [[ ! -e "$p/CLAUDE.md" && ! -e "$p/GEMINI.md" ]] || { echo "CLAUDE.md or GEMINI.md was written for codex alone"; bad=1; }
  [[ -f "$p/AGENTS.md" ]] || { echo "no AGENTS.md"; bad=1; }
  return $bad
}

test_install_refuses_what_it_does_not_know() {
  local p out bad=0; p="$(new_project)"
  if out="$(install_into "$p" --harness claude,vscode)"; then echo "an unknown harness was let through"; bad=1; fi
  grep -q 'vscode' <<<"$out" || { echo "the refusal did not name the harness: $out"; bad=1; }
  [[ -z "$(ls -A "$p" | grep -v '^\.git$')" ]] || { echo "something was written before the refusal"; bad=1; }
  if out="$(install_into "$p" --colour)"; then echo "an unknown option was let through"; bad=1; fi
  grep -q -- '--colour' <<<"$out" || { echo "the refusal did not name the option: $out"; bad=1; }
  if out="$(install_into "$p/not here")"; then echo "a project that is not there was let through"; bad=1; fi
  return $bad
}

# A copy of the kit, a version on, with one rule and one skill changed.
newer_kit() {
  local k; k="$(mktemp -d)/kit"
  cp -R "$KIT" "$k"
  rm -rf "$k/.git"
  echo 0.2.0 >"$k/VERSION"
  printf '\nA rule added in the newer kit.\n' >>"$k/GUARDRAILS.md"
  printf '\nA line added to the bug skill.\n' >>"$k/skills/bug/SKILL.md"
  printf '%s\n' "$k"
}

test_install_shows_a_newer_kit_before_writing_it() {
  local p k before out bad=0; p="$(new_project)"; k="$(newer_kit)"
  install_into "$p" >/dev/null || { echo "first install failed"; return 1; }
  before="$(fingerprint "$p")"
  if out="$("$k/install.sh" "$p" 2>&1)"; then echo "a newer kit was written without --yes"; bad=1; fi
  grep -q 'A rule added in the newer kit' <<<"$out" || { echo "the diff did not show the changed rule"; bad=1; }
  grep -q 'A line added to the bug skill' <<<"$out" || { echo "the diff did not show the changed skill"; bad=1; }
  [[ "$(fingerprint "$p")" == "$before" ]] || { echo "something was written without --yes"; bad=1; }
  out="$("$k/install.sh" "$p" --yes 2>&1)" || { echo "the update with --yes failed:"; echo "$out"; return 1; }
  grep -q 'A rule added in the newer kit' "$p/guardrails/GUARDRAILS.md" || { echo "the rule was not updated"; bad=1; }
  grep -q 'A line added to the bug skill' "$p/.claude/skills/bug/SKILL.md" || { echo "the skill was not updated in .claude/skills"; bad=1; }
  grep -q 'A line added to the bug skill' "$p/.agents/skills/bug/SKILL.md" || { echo "the skill was not updated in .agents/skills"; bad=1; }
  [[ "$(cat "$p/guardrails/VERSION")" == 0.2.0 ]] || { echo "VERSION was not updated"; bad=1; }
  out="$("$k/install.sh" "$p" 2>&1)" || { echo "installing the same newer kit again failed"; bad=1; }
  grep -qi 'up to date' <<<"$out" || { echo "after the update it was not up to date"; bad=1; }
  return $bad
}

test_install_refuses_to_write_over_a_hand_edit() {
  local p k out bad=0; p="$(new_project)"; k="$(newer_kit)"
  install_into "$p" >/dev/null || { echo "first install failed"; return 1; }
  printf '\nEdited by hand in the project.\n' >>"$p/guardrails/checks/fuzzer.md"
  printf '\nEdited by hand too.\n' >>"$p/.agents/skills/commit/SKILL.md"
  if out="$("$k/install.sh" "$p" --yes 2>&1)"; then echo "a hand edit was written over"; bad=1; fi
  grep -q 'guardrails/checks/fuzzer.md' <<<"$out" || { echo "the refusal did not name the edited check: $out"; bad=1; }
  grep -q '.agents/skills/commit/SKILL.md' <<<"$out" || { echo "the refusal did not name the edited skill: $out"; bad=1; }
  grep -q 'Edited by hand in the project' "$p/guardrails/checks/fuzzer.md" || { echo "the hand edit is gone"; bad=1; }
  ! grep -q 'A rule added in the newer kit' "$p/guardrails/GUARDRAILS.md" || { echo "the update went half in"; bad=1; }
  return $bad
}

test_install_outside_git_says_the_hook_is_not_active() {
  local p out; p="$(new_project nogit)"
  out="$(install_into "$p")" || { echo "install failed outside git:"; echo "$out"; return 1; }
  grep -qi 'not a git repo' <<<"$out" || { echo "it did not say the hook cannot run outside git:"; echo "$out"; return 1; }
}
