# The shell installer is gone: an agent installs the kit by following
# INSTALL.md, on any system, with nothing but git. Nothing the kit ships may
# still send a reader to the installer, its manifest or a version file. The
# plan keeps the history, and is left out.

test_no_installer_is_named() {
  local found
  found="$(cd "$KIT" && grep -rnE 'install\.sh|MANIFEST|guardrails/VERSION|\bVERSION\b' \
    --include='*.md' --include='*.sh' --include='pre-commit' --include='run' . \
    | grep -v '^\./PLAN\.md:' | grep -v '^\./tests/test_no_installer\.sh:')"
  [[ -z "$found" ]] || { echo "still named:"; sed 's/^/  /' <<<"$found"; return 1; }
  [[ ! -e "$KIT/install.sh" && ! -e "$KIT/VERSION" ]] || { echo "install.sh or VERSION is still there"; return 1; }
}
