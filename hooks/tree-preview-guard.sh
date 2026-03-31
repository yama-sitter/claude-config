#!/bin/bash
# PreToolUse(Write) hook: 二重previewをブロック
# tree-preview-state.json に active:true を書き込もうとした時、
# 既に active:true のstateファイルが存在すればブロックする

set -euo pipefail

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty')

# 対象ファイル以外はスキップ
[[ "$(basename "$FILE_PATH")" == "tree-preview-state.json" ]] || exit 0

# 書き込み内容が active:true でなければスキップ（restore等）
CONTENT=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.content // empty')
echo "$CONTENT" | grep -q '"active":\s*true' || exit 0

# 既存stateファイルを確認
ROOT="${CLAUDE_PROJECT_DIR:-.}"
STATE_FILE="$ROOT/.claude/tree-preview-state.json"
[ -f "$STATE_FILE" ] || exit 0
grep -q '"active":\s*true' "$STATE_FILE" || exit 0

# 二重preview → ブロック
BRANCH=$(jq -r '.worktreeBranch // "不明"' "$STATE_FILE" 2>/dev/null || echo "不明")
echo "BLOCKED: 既にプレビューモード中です（ブランチ: $BRANCH）。先に別のプロセスで /tree restore または /tree exit を実行してください。"
exit 2
