#!/usr/bin/env bash
# Puts the guardrails kit into a project, and takes a newer kit in later.
#
#   ./install.sh <project> [--harness claude,codex,gemini,cursor] [--yes]
#
# Two kinds of file are written, and treated differently:
#
# - The kit's own: guardrails/ (the rules, the checks, the version) and
#   each skill, in .agents/skills/ and .claude/skills/. These are the kit's
#   and are replaced by a newer one, but only after the changes have been
#   shown and --yes given, and never over a file edited by hand since it
#   was installed: guardrails/MANIFEST records what was written, so an edit
#   can be told from an update.
# - The project's: AGENTS.md, CLAUDE.md, GEMINI.md and .githooks/pre-commit.
#   Written once, from the templates, where there is none; never over one
#   that is there. Where one is there, what to add to it is printed.
#
# A skill folder the project already has, of the same name as one of the
# kit's, is the project's own and is left alone.
#
# Plain bash, 3.2 and on, so that it runs on the bash macOS ships.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
HARNESSES_KNOWN="claude codex gemini cursor"

usage() {
  sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'
}

refuse() {
  echo "install: $*" >&2
  exit 1
}

# --- What was asked ---------------------------------------------------------

project=""
harnesses="$HARNESSES_KNOWN"
yes=0
while (($#)); do
  case "$1" in
    --harness)
      [[ $# -ge 2 ]] || refuse "--harness needs a list, such as claude,codex"
      harnesses="$(tr ',' ' ' <<<"$2")"
      shift 2
      ;;
    --harness=*)
      harnesses="$(tr ',' ' ' <<<"${1#--harness=}")"
      shift
      ;;
    --yes) yes=1; shift ;;
    -h | --help) usage; exit 0 ;;
    -*) refuse "no such option: $1" ;;
    *)
      [[ -z "$project" ]] || refuse "one project at a time: $project, and $1"
      project="$1"
      shift
      ;;
  esac
done

[[ -n "$project" ]] || { usage >&2; exit 1; }
[[ -d "$project" ]] || refuse "no such folder: $project"
project="$(cd "$project" && pwd)"
[[ "$project" != "$KIT" ]] || refuse "that is the kit itself"

for h in $harnesses; do
  case " $HARNESSES_KNOWN " in
    *" $h "*) ;;
    *) refuse "no such harness: $h (known: $HARNESSES_KNOWN)" ;;
  esac
done
[[ -n "${harnesses// /}" ]] || refuse "--harness names none"

wants() { case " $harnesses " in *" $1 "*) return 0 ;; esac; return 1; }

# Which skill folders, and which one-line pointer files, the harnesses read.
skill_dirs=""
wants codex || wants gemini || wants cursor && skill_dirs="$skill_dirs .agents/skills"
wants claude && skill_dirs="$skill_dirs .claude/skills"
pointers=""
wants claude && pointers="$pointers CLAUDE.md"
wants gemini && pointers="$pointers GEMINI.md"

manifest="$project/guardrails/MANIFEST"
if [[ -d "$project/guardrails" && ! -f "$manifest" ]]; then
  refuse "guardrails/ is there, and was not put there by this installer (no guardrails/MANIFEST)"
fi

sum() { cksum <"$1" | awk '{print $1 " " $2}'; }

# --- Hand edits stop everything ---------------------------------------------

edited=""
if [[ -f "$manifest" ]]; then
  while IFS= read -r line; do
    path="${line#* * }"
    was="${line%% "$path"}"
    if [[ ! -f "$project/$path" ]]; then
      edited="$edited
  $path (removed)"
    elif [[ "$(sum "$project/$path")" != "$was" ]]; then
      edited="$edited
  $path"
    fi
  done <"$manifest"
fi
if [[ -n "$edited" ]]; then
  refuse "these were edited by hand since the kit put them there, and would be lost:$edited
Move each change into the kit, or into the project's own AGENTS.md, and put the file back as it was."
fi

# --- What the kit would write -----------------------------------------------

# Pairs of "source<TAB>destination", the destination relative to the project.
pairs="$(mktemp)"
trap 'rm -f "$pairs"' EXIT
printf '%s\t%s\n' "$KIT/GUARDRAILS.md" "guardrails/GUARDRAILS.md" >>"$pairs"
printf '%s\t%s\n' "$KIT/VERSION" "guardrails/VERSION" >>"$pairs"
for f in "$KIT"/checks/*.md; do
  printf '%s\t%s\n' "$f" "guardrails/checks/$(basename "$f")" >>"$pairs"
done

own_skills=""
for dir in $skill_dirs; do
  for skill in "$KIT"/skills/*/; do
    name="$(basename "$skill")"
    # A folder of the same name with nothing of the kit's in it is the project's.
    if [[ -d "$project/$dir/$name" ]] && ! grep -q " $dir/$name/" "$manifest" 2>/dev/null; then
      own_skills="$own_skills
  the project's own $name skill, in $dir/$name, is left alone"
      continue
    fi
    (cd "$skill" && find . -type f | sed 's|^\./||' | sort) | while IFS= read -r rel; do
      printf '%s\t%s\n' "$skill$rel" "$dir/$name/$rel"
    done >>"$pairs"
  done
done

added=""
changed=""
while IFS=$'\t' read -r src dest; do
  if [[ ! -f "$project/$dest" ]]; then
    added="$added $dest"
  elif ! cmp -s "$src" "$project/$dest"; then
    changed="$changed $dest"
  fi
done <"$pairs"

removed=""
if [[ -f "$manifest" ]]; then
  while IFS= read -r line; do
    path="${line#* * }"
    cut -f2 "$pairs" | grep -qxF "$path" || removed="$removed $path"
  done <"$manifest"
fi

# The project's own files, from the templates, only where there are none.
templates=""
for name in AGENTS.md $pointers; do
  [[ -e "$project/$name" ]] || templates="$templates $name"
done
[[ -e "$project/.githooks/pre-commit" ]] || templates="$templates .githooks/pre-commit"

# --- A newer kit is shown before it is written ------------------------------

if [[ -n "$changed$removed" && $yes -eq 0 ]]; then
  echo "The kit has changed since it was installed ($(cat "$project/guardrails/VERSION" 2>/dev/null || echo "no version") to $(cat "$KIT/VERSION")):"
  echo
  while IFS=$'\t' read -r src dest; do
    case " $changed " in *" $dest "*) diff -u "$project/$dest" "$src" --label "$dest (installed)" --label "$dest (kit)" || true ;; esac
  done <"$pairs"
  for path in $removed; do echo "--- $path: no longer in the kit, and would be removed"; done
  for path in $added; do echo "+++ $path: new"; done
  echo
  echo "Nothing was written. Run again with --yes to take these in."
  exit 2
fi

# --- Write ------------------------------------------------------------------

if [[ -z "$added$changed$removed$templates" ]]; then
  echo "The kit is up to date in $project ($(cat "$KIT/VERSION"))."
else
  while IFS=$'\t' read -r src dest; do
    case " $added $changed " in
      *" $dest "*)
        mkdir -p "$(dirname "$project/$dest")"
        cp "$src" "$project/$dest"
        ;;
    esac
  done <"$pairs"
  for path in $removed; do
    rm -f "$project/$path"
    rmdir -p "$(dirname "$project/$path")" 2>/dev/null || true
  done
  for name in $templates; do
    case "$name" in
      .githooks/pre-commit)
        mkdir -p "$project/.githooks"
        cp "$KIT/templates/pre-commit" "$project/$name"
        chmod +x "$project/$name"
        ;;
      *) cp "$KIT/templates/$name" "$project/$name" ;;
    esac
  done
  # The manifest is what the kit wrote, and only that: never the project's files.
  if [[ -n "$added$changed$removed" ]]; then
    cut -f2 "$pairs" | sort | while IFS= read -r dest; do
      printf '%s %s\n' "$(sum "$project/$dest")" "$dest"
    done >"$manifest.new"
    mv "$manifest.new" "$manifest"
  fi
  echo "The kit ($(cat "$KIT/VERSION")) is in $project."
  for path in $added; do echo "  added    $path"; done
  for path in $changed; do echo "  updated  $path"; done
  for path in $removed; do echo "  removed  $path"; done
  for name in $templates; do echo "  written  $name, from the template"; done
fi

# --- What is left for the project to do ------------------------------------

[[ -z "$own_skills" ]] || echo "$own_skills"
if [[ -e "$project/.githooks/pre-commit" ]] && ! cmp -s "$KIT/templates/pre-commit" "$project/.githooks/pre-commit"; then
  echo "  the project's own .githooks/pre-commit is left alone: it should run the project's quick check"
fi

if [[ -f "$project/AGENTS.md" ]] && ! grep -q 'guardrails/GUARDRAILS.md' "$project/AGENTS.md"; then
  echo
  echo "AGENTS.md is the project's own, and was left as it is. Add this line near its top:"
  echo
  echo "  Read guardrails/GUARDRAILS.md before changing anything: @guardrails/GUARDRAILS.md"
fi
if [[ -f "$project/AGENTS.md" ]]; then
  missing="$(grep '^## ' "$KIT/templates/AGENTS.md" | while IFS= read -r heading; do
    grep -qxF "$heading" "$project/AGENTS.md" || echo "  $heading"
  done)"
  if [[ -n "$missing" ]]; then
    echo
    echo "AGENTS.md lacks headings the skills look for (the guardrails skill writes them from the code):"
    echo "$missing"
  fi
fi
for name in $pointers; do
  if [[ -f "$project/$name" ]] && ! grep -q '^@AGENTS.md' "$project/$name"; then
    echo
    echo "$name is the project's own, and was left as it is. Add this line to it, so that it brings in AGENTS.md:"
    echo
    echo "  @AGENTS.md"
  fi
done

# The kit's files are formatted as prettier formats them by default, and
# are not the project's to format: a formatter told otherwise would fail them
# in the hook, or write over them, which stops the next update as an edit.
for config in "$project"/.prettierrc* "$project"/prettier.config.* "$project"/biome.json "$project"/biome.jsonc "$project"/dprint.json; do
  if [[ -e "$config" ]]; then
    echo
    echo "The project has a formatter ($(basename "$config")). Have it leave the kit's files alone:"
    echo
    echo "  guardrails/"
    for dir in $skill_dirs; do
      for skill in "$KIT"/skills/*/; do echo "  $dir/$(basename "$skill")/"; done
    done
    break
  fi
done

echo
if git -C "$project" rev-parse --git-dir >/dev/null 2>&1; then
  if [[ "$(git -C "$project" config core.hooksPath || true)" != ".githooks" ]]; then
    echo "The pre-commit hook is not running yet: it needs the project's quick check named in it,"
    echo "and git pointed at .githooks. The guardrails skill does both."
  fi
else
  echo "$project is not a git repo, so the pre-commit hook will not run until it is one."
fi
echo "Next, in the project, run the guardrails skill."
