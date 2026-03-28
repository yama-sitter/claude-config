#!/bin/bash
# WorktreeCreate hook: ブランチ名カスタマイズ + 外部配置 + セットアップ
#
# stdin: JSON {"name": "<slug>", ...}
# stdout: worktreeの絶対パスのみ

set -euo pipefail

INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r '.name // empty')
[ -z "$NAME" ] && exit 1

# 一時ファイルから元のブランチ名を取得（スキルが書き出す）
BRANCH_OVERRIDE_FILE="/private/tmp/claude/claude-501/.claude-worktree-branch-override"
if [ -f "$BRANCH_OVERRIDE_FILE" ]; then
  BRANCH=$(cat "$BRANCH_OVERRIDE_FILE")
  rm -f "$BRANCH_OVERRIDE_FILE"
else
  BRANCH="$NAME"
fi

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

# ブランチ名: BRANCH を使用（スラッシュ付きブランチ名に対応）
if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$BRANCH" 2>/dev/null; then
  git -C "$REPO_ROOT" worktree add "$WORKTREE_PATH" "$BRANCH" >/dev/null 2>&1
else
  git -C "$REPO_ROOT" worktree add -b "$BRANCH" "$WORKTREE_PATH" HEAD >/dev/null 2>&1
fi

# --- 依存インストール（モノレポ対応） ---
install_deps() {
  local dir="$1"
  cd "$dir" || return
  if [ -f pnpm-lock.yaml ]; then
    echo "Installing dependencies in $dir ..." >&2
    pnpm install --frozen-lockfile >&2 || true
  elif [ -f package-lock.json ]; then
    echo "Installing dependencies in $dir ..." >&2
    npm ci >&2 || true
  elif [ -f yarn.lock ]; then
    echo "Installing dependencies in $dir ..." >&2
    yarn install --frozen-lockfile >&2 || true
  elif [ -f bun.lockb ] || [ -f bun.lock ]; then
    echo "Installing dependencies in $dir ..." >&2
    bun install --frozen-lockfile >&2 || true
  fi
}

# ルートを先にインストール（hoistedモノレポで重要）
install_deps "$WORKTREE_PATH"

# サブディレクトリのロックファイルを検出してインストール
find "$WORKTREE_PATH" -mindepth 2 \
  -name node_modules -prune -o \
  -name .git -prune -o \
  \( -name pnpm-lock.yaml -o -name package-lock.json -o -name yarn.lock -o -name bun.lockb -o -name bun.lock \) \
  -print | while read -r lockfile; do
  install_deps "$(dirname "$lockfile")"
done

# --- .envファイルをソースリポジトリからコピー（サブディレクトリ対応） ---
find "$REPO_ROOT" \
  -name node_modules -prune -o \
  -name .git -prune -o \
  \( -name '.env*' ! -name '*.sample' ! -name '*.example' -type f \) \
  -print | while read -r src; do
  rel="${src#$REPO_ROOT/}"
  dest="$WORKTREE_PATH/$rel"
  if [ ! -f "$dest" ]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
  fi
done

# --- .envサンプル/exampleファイルをリネームしてコピー ---
find "$REPO_ROOT" \
  -name node_modules -prune -o \
  -name .git -prune -o \
  \( -name '.env*.sample' -o -name '.env*.example' \) -type f \
  -print | while read -r src; do
  rel="${src#$REPO_ROOT/}"
  dest_rel="${rel%.sample}"
  dest_rel="${dest_rel%.example}"
  dest="$WORKTREE_PATH/$dest_rel"
  if [ ! -f "$dest" ]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
  fi
done

echo "$WORKTREE_PATH"
