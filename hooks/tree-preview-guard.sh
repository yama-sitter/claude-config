#!/bin/bash
# PreToolUse(ExitWorktree) hook: preview中の別プロセスからのworktree退出をブロック
#
# /tree preview のフローでは ExitWorktree(keep) が呼ばれる。
# メインリポジトリに既にactive previewがある場合、ExitWorktreeをブロックして
# ユーザーにpreviewの解消を促す。
#
# /tree exit のフローでは、Handle preview stateで先にstateを解消してから
# ExitWorktreeを呼ぶため、このhookには引っかからない。

set -euo pipefail

# メインリポジトリのルートを取得（worktree内からはgit-common-dirで辿れる）
GIT_COMMON=$(git rev-parse --git-common-dir 2>/dev/null || echo "")
[ -n "$GIT_COMMON" ] || exit 0
MAIN_ROOT=$(cd "$GIT_COMMON/.." && pwd)

# stateファイル確認
STATE_FILE="$MAIN_ROOT/.claude/tree-preview-state.json"
[ -f "$STATE_FILE" ] || exit 0
grep -q '"active": true' "$STATE_FILE" || exit 0

# preview中 → ブロック
BRANCH=$(jq -r '.worktreeBranch // "不明"' "$STATE_FILE" 2>/dev/null || echo "不明")
echo "BLOCKED: 既にプレビューモード中です（ブランチ: $BRANCH）。先に別のプロセスで /tree restore または /tree exit を実行してください。"
exit 2
