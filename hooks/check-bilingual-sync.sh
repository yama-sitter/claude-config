#!/usr/bin/env bash
# PostToolUse hook: bilingual drift detection
# Warns when an English primary file is modified but its -ja.md mirror is not.

payload=$(cat)
file=$(echo "$payload" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null)

[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0

# Only apply within the claude-config repository
repo_root=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null)
expected_root=$(cd "$HOME/.claude" && pwd -P 2>/dev/null)
[ -n "$expected_root" ] || exit 0
[ "$repo_root" = "$expected_root" ] || exit 0

# Target files: SKILL.md / CLAUDE.md / rules/*.md (excluding -ja.md)
case "$file" in
  *-ja.md) exit 0 ;;
  */SKILL.md|*/CLAUDE.md|*/rules/*.md) ;;
  *) exit 0 ;;
esac

# Compute the adjacent -ja.md path
ja_file="${file%.md}-ja.md"
[ -f "$ja_file" ] || exit 0

# Warn if primary is modified but mirror is not
target_changed=$(git -C "$repo_root" status --porcelain -- "$file" 2>/dev/null | head -c1)
ja_changed=$(git -C "$repo_root" status --porcelain -- "$ja_file" 2>/dev/null | head -c1)

if [ -n "$target_changed" ] && [ -z "$ja_changed" ]; then
  echo "WARN: $(basename "$file") was modified but $(basename "$ja_file") is not. Update both to keep them in sync." >&2
fi

exit 0
