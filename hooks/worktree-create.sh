#!/bin/bash
# WorktreeCreate hook: ブランチ名カスタマイズ + 外部配置 + セットアップ
#
# stdin: JSON {"name": "<slug>", ...}
# stdout: worktreeの絶対パスのみ

set -euo pipefail

INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r '.name // empty')
[ -z "$NAME" ] && exit 1

REPO_ROOT="${CLAUDE_PROJECT_DIR:-.}"

# --- worktreeパスを算出（gwq命名規則: ~/Sources/<host>/<owner>/<repo>=<name>） ---
REMOTE_URL=$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || echo "")

if [ -n "$REMOTE_URL" ]; then
  # .git 拡張子を除去
  URL="${REMOTE_URL%.git}"

  # git@github.com:owner/repo → github.com / owner / repo
  if [[ "$URL" =~ ^git@([^:]+):(.+)/([^/]+)$ ]]; then
    HOST="${BASH_REMATCH[1]}"
    OWNER="${BASH_REMATCH[2]}"
    REPO="${BASH_REMATCH[3]}"
  # ssh://git@github.com/owner/repo or https://github.com/owner/repo
  elif [[ "$URL" =~ ^(ssh|https?)://[^@]*@?([^/]+)/([^/]+)/([^/]+)$ ]]; then
    HOST="${BASH_REMATCH[2]}"
    OWNER="${BASH_REMATCH[3]}"
    REPO="${BASH_REMATCH[4]}"
  fi
fi

if [ -n "${HOST:-}" ] && [ -n "${OWNER:-}" ] && [ -n "${REPO:-}" ]; then
  WORKTREE_PATH="$HOME/Sources/${HOST}/${OWNER}/${REPO}=${NAME}"
else
  # フォールバック: URL解析失敗時はデフォルトパス
  WORKTREE_PATH="$REPO_ROOT/.claude/worktrees/$NAME"
fi

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
