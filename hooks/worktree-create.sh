#!/bin/bash
# WorktreeCreate hook: claude -w 実行時にgwq命名規則で外部worktreeを作成しセットアップする
# サンドボックス外（ユーザーのシェル環境）で実行される
#
# stdin: JSON {"name": "<slug>", "session_id": "...", "cwd": "...", "hook_event_name": "WorktreeCreate"}
# stdout: worktreeの絶対パスのみ（これ以外のstdout出力は禁止）
# 進捗: /dev/tty に出力

set -euo pipefail

log() { echo "[worktree-create] $*" > /dev/tty 2>/dev/null || true; }

# --- stdin読み取り（一度しか読めない） ---
INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r '.name // empty')
[ -z "$NAME" ] && { echo "Error: name is empty" >&2; exit 1; }

REPO_ROOT="${CLAUDE_PROJECT_DIR:-.}"

# --- remote URLからhost/owner/repoを抽出 ---
REMOTE_URL=$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || echo "")
if [ -z "$REMOTE_URL" ]; then
  echo "Error: no origin remote" >&2
  exit 1
fi

# git@github.com:owner/repo.git → github.com / owner / repo
# ssh://git@github.com/owner/repo.git → github.com / owner / repo
# https://github.com/owner/repo.git → github.com / owner / repo
parse_remote_url() {
  local url="$1"
  url="${url%.git}"

  if [[ "$url" =~ ^git@([^:]+):(.+)/([^/]+)$ ]]; then
    HOST="${BASH_REMATCH[1]}"
    OWNER="${BASH_REMATCH[2]}"
    REPO="${BASH_REMATCH[3]}"
  elif [[ "$url" =~ ^(ssh|https?)://[^@]*@?([^/]+)/([^/]+)/([^/]+)$ ]]; then
    HOST="${BASH_REMATCH[2]}"
    OWNER="${BASH_REMATCH[3]}"
    REPO="${BASH_REMATCH[4]}"
  else
    echo "Error: cannot parse remote URL: $url" >&2
    exit 1
  fi
}

parse_remote_url "$REMOTE_URL"

# --- worktreeパスを算出（gwq命名規則） ---
# template: {{.Host}}/{{.Owner}}/{{.Repository}}={{.Branch}}
# /をハイフンに変換（gwqと同じ挙動）
SAFE_NAME="${NAME//\//-}"
BASEDIR="$HOME/Sources"
WORKTREE_PATH="${BASEDIR}/${HOST}/${OWNER}/${REPO}=${SAFE_NAME}"

log "worktree: $WORKTREE_PATH (branch: $NAME)"

# --- 既存チェック ---
if [ -d "$WORKTREE_PATH" ]; then
  log "既存のworktreeを再利用: $WORKTREE_PATH"
  echo "$WORKTREE_PATH"
  exit 0
fi

# --- worktree作成 ---
# 既存ブランチがあれば再利用、なければ新規作成
if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$NAME" 2>/dev/null; then
  log "既存ブランチを使用: $NAME"
  git -C "$REPO_ROOT" worktree add "$WORKTREE_PATH" "$NAME" > /dev/null 2>&1
else
  log "新規ブランチ作成: $NAME"
  git -C "$REPO_ROOT" worktree add -b "$NAME" "$WORKTREE_PATH" HEAD > /dev/null 2>&1
fi

# --- Nodeバージョン切り替え（.node-version/.nvmrc対応） ---
activate_node_version() {
  local wt_path="$1"
  local version_file=""

  if [ -f "$wt_path/.node-version" ]; then
    version_file="$wt_path/.node-version"
  elif [ -f "$wt_path/.nvmrc" ]; then
    version_file="$wt_path/.nvmrc"
  fi

  if [ -n "$version_file" ]; then
    local version
    version=$(cat "$version_file" | tr -d '[:space:]')
    log "Node.js バージョン: $version ($version_file)"

    # fnm（推奨）
    if command -v fnm > /dev/null 2>&1; then
      eval "$(fnm env)" 2>/dev/null || true
      fnm use "$version" --install-if-missing > /dev/tty 2>&1 || true
    # nvm
    elif [ -s "$HOME/.nvm/nvm.sh" ]; then
      source "$HOME/.nvm/nvm.sh" 2>/dev/null || true
      nvm use "$version" > /dev/tty 2>&1 || nvm install "$version" > /dev/tty 2>&1 || true
    fi
  fi
}

cd "$WORKTREE_PATH" || { echo "Error: cannot cd to $WORKTREE_PATH" >&2; exit 1; }

# --- Nodeバージョン切り替え ---
activate_node_version "$WORKTREE_PATH"

# --- 依存インストール ---
if [ -f pnpm-lock.yaml ]; then
  log "pnpm install --frozen-lockfile ..."
  pnpm install --frozen-lockfile > /dev/tty 2>&1 || log "pnpm install 失敗（手動で実行してください）"
elif [ -f package-lock.json ]; then
  log "npm ci ..."
  npm ci > /dev/tty 2>&1 || log "npm ci 失敗（手動で実行してください）"
elif [ -f yarn.lock ]; then
  log "yarn install --frozen-lockfile ..."
  yarn install --frozen-lockfile > /dev/tty 2>&1 || log "yarn install 失敗（手動で実行してください）"
elif [ -f go.sum ]; then
  log "go mod download ..."
  go mod download > /dev/tty 2>&1 || log "go mod download 失敗"
else
  log "ロックファイルなし、依存インストールをスキップ"
fi

# --- gitignore済み.envファイルをソースリポジトリからコピー ---
copied=()
for f in "$REPO_ROOT"/.env*; do
  [ -f "$f" ] || continue
  base=$(basename "$f")
  if [ ! -f "$WORKTREE_PATH/$base" ]; then
    cp "$f" "$WORKTREE_PATH/$base" && copied+=("$base")
  fi
done
if [ ${#copied[@]} -gt 0 ]; then
  log ".env コピー済み: ${copied[*]}"
fi

# --- stdout: worktreeの絶対パスのみ ---
echo "$WORKTREE_PATH"
