#!/bin/bash
# WorktreeCreate hook (Step 1b: ブランチ名カスタマイズ + 依存インストール)
#
# stdin: JSON {"name": "<slug>", ...}
# stdout: worktreeの絶対パスのみ

set -euo pipefail

INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r '.name // empty')
[ -z "$NAME" ] && exit 1

REPO_ROOT="${CLAUDE_PROJECT_DIR:-.}"
WORKTREE_PATH="$REPO_ROOT/.claude/worktrees/$NAME"

mkdir -p "$(dirname "$WORKTREE_PATH")"

if [ -d "$WORKTREE_PATH" ]; then
  echo "$WORKTREE_PATH"
  exit 0
fi

# ブランチ名: nameそのまま（worktree- プレフィックスなし）
if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$NAME" 2>/dev/null; then
  git -C "$REPO_ROOT" worktree add "$WORKTREE_PATH" "$NAME" >/dev/null 2>&1
else
  git -C "$REPO_ROOT" worktree add -b "$NAME" "$WORKTREE_PATH" HEAD >/dev/null 2>&1
fi

# --- 依存インストール ---
cd "$WORKTREE_PATH" || true
if [ -f pnpm-lock.yaml ]; then
  pnpm install --frozen-lockfile >&2 || true
elif [ -f package-lock.json ]; then
  npm ci >&2 || true
elif [ -f yarn.lock ]; then
  yarn install --frozen-lockfile >&2 || true
fi

# --- gitignore済み.envファイルをソースリポジトリからコピー ---
for f in "$REPO_ROOT"/.env*; do
  [ -f "$f" ] || continue
  base=$(basename "$f")
  [ ! -f "$WORKTREE_PATH/$base" ] && cp "$f" "$WORKTREE_PATH/$base"
done

echo "$WORKTREE_PATH"
