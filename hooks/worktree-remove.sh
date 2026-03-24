#!/bin/bash
# WorktreeRemove hook: claude -w セッション終了時にworktreeをクリーンアップ
# サンドボックス外（ユーザーのシェル環境）で実行される
#
# stdin: JSON {"worktree_path": "<path>", "session_id": "...", "cwd": "...", "hook_event_name": "WorktreeRemove"}
# stdout: なし

set -euo pipefail

log() { echo "[worktree-remove] $*" > /dev/tty 2>/dev/null || true; }

# --- stdin読み取り ---
INPUT=$(cat)
WORKTREE_PATH=$(echo "$INPUT" | jq -r '.worktree_path // empty')
[ -z "$WORKTREE_PATH" ] && exit 0
[ ! -d "$WORKTREE_PATH" ] && exit 0

# --- ブランチ名を取得 ---
BRANCH=$(git -C "$WORKTREE_PATH" branch --show-current 2>/dev/null || echo "")

log "削除: $WORKTREE_PATH (branch: $BRANCH)"

# --- worktree削除 ---
# CLAUDE_PROJECT_DIR からworktreeを削除
REPO_ROOT="${CLAUDE_PROJECT_DIR:-.}"
git -C "$REPO_ROOT" worktree remove --force "$WORKTREE_PATH" 2>/dev/null || {
  log "git worktree remove 失敗、ディレクトリを直接削除"
  rm -rf "$WORKTREE_PATH" 2>/dev/null || true
  git -C "$REPO_ROOT" worktree prune 2>/dev/null || true
}

# --- ブランチ削除（main/master/develop以外） ---
if [ -n "$BRANCH" ] && [[ "$BRANCH" != "main" && "$BRANCH" != "master" && "$BRANCH" != "develop" ]]; then
  git -C "$REPO_ROOT" branch -D "$BRANCH" 2>/dev/null && log "ブランチ削除: $BRANCH" || true
fi

log "完了"
