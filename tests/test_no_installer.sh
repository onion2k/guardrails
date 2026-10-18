# The shell installer is gone: an agent installs the kit by following
# INSTALL.md, on any system, with nothing but git. Nothing the kit ships may
# still send a reader to the installer, its manifest or a version file. The
# plan keeps the history, and is left out. Only what git tracks is read: a
# worktree under the folder is a copy of the kit, not the kit.

test_no_installer_is_named() {
  local found
  found="$(cd "$KIT" && git ls-files -z -- '*.md' '*.sh' templates/pre-commit tests/run \
    | xargs -0 grep -nE 'install\.sh|MANIFEST|guardrails/VERSION|\bVERSION\b' /dev/null \
    | grep -v '^PLAN\.md:' | grep -v '^tests/test_no_installer\.sh:')"
  [[ -z "$found" ]] || { echo "still named:"; sed 's/^/  /' <<<"$found"; return 1; }
  [[ ! -e "$KIT/install.sh" && ! -e "$KIT/VERSION" ]] || { echo "install.sh or VERSION is still there"; return 1; }
}
