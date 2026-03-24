#!/bin/bash
# PostToolUse hook: worktree作成・削除の自動セットアップ/クリーンアップ
# サンドボックス外で実行されるため、dotfile作成・依存インストールが可能

# --- 早期リターン（全Bashコマンドで発火するため軽量に） ---
input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
echo "$cmd" | grep -qE 'git\s+worktree\s+(add|remove)' || exit 0

# === worktree add の処理 ===
if echo "$cmd" | grep -qE 'git\s+worktree\s+add'; then

  # --- worktreeパスの抽出 ---
  # git worktree add [--no-checkout] <path> [-b] <branch>
  worktree_path=$(echo "$cmd" | sed -E 's/.*git worktree add\s+(--no-checkout\s+)?//' | awk '{print $1}')
  [ -z "$worktree_path" ] && exit 0

  # 相対パスを絶対パスに
  if [[ "$worktree_path" != /* ]]; then
    cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null)
    worktree_path="${cwd:-.}/$worktree_path"
  fi
  [ ! -d "$worktree_path" ] && exit 0

  # --- ソースリポジトリのルートを取得 ---
  # git worktree list の最初の行がメインworktree（＝ソースリポジトリ）
  repo_root=$(git -C "$worktree_path" worktree list --porcelain | head -1 | sed 's/^worktree //')
  [ -z "$repo_root" ] && exit 0

  # --- セットアップ ---
  cd "$worktree_path" || exit 0
  results=()

  # 1. フルチェックアウト（dotfile含む）
  # --no-checkout で作成された場合のみチェックアウトが必要
  file_count=$(ls -A 2>/dev/null | grep -v '^\.git$' | wc -l)
  if [ "$file_count" -le 1 ]; then
    if git checkout HEAD -- . 2>&1; then
      git reset HEAD -- . 2>/dev/null
      results+=("checkout: OK（dotfile含む）")
    else
      results+=("checkout: 失敗")
    fi
  else
    results+=("checkout: 既にチェックアウト済み")
  fi

  # 2. 依存インストール
  if [ -f pnpm-lock.yaml ]; then
    if pnpm install --frozen-lockfile 2>&1; then
      results+=("依存: pnpm install OK")
    else
      results+=("依存: pnpm install 失敗。! cd $worktree_path && pnpm install --frozen-lockfile を実行してください")
    fi
  elif [ -f package-lock.json ]; then
    if npm ci 2>&1; then
      results+=("依存: npm ci OK")
    else
      results+=("依存: npm ci 失敗。! cd $worktree_path && npm ci を実行してください")
    fi
  elif [ -f yarn.lock ]; then
    if yarn install --frozen-lockfile 2>&1; then
      results+=("依存: yarn install OK")
    else
      results+=("依存: yarn install 失敗。! cd $worktree_path && yarn install --frozen-lockfile を実行してください")
    fi
  elif [ -f go.sum ]; then
    go mod download 2>&1 && results+=("依存: go mod download OK") || results+=("依存: go mod download 失敗")
  else
    results+=("依存: ロックファイルなし、スキップ")
  fi

  # 3. gitignore済み.envファイルをソースリポジトリからコピー
  # hookはユーザーのシェル環境で実行されるため、Claudeのdenyルールとは無関係。
  copied_envs=()
  for f in "$repo_root"/.env*; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    if [ ! -f "$worktree_path/$base" ]; then
      cp "$f" "$worktree_path/$base" && copied_envs+=("$base")
    fi
  done
  if [ ${#copied_envs[@]} -gt 0 ]; then
    env_list=$(IFS=', '; echo "${copied_envs[*]}")
    results+=(".env コピー済み: $env_list")
  fi

  # --- 結果出力 ---
  msg=$(printf '%s\n' "${results[@]}" | paste -sd '、' -)
  echo "{\"additionalContext\": \"[worktree-setup] $msg\"}"

# === worktree remove の処理 ===
elif echo "$cmd" | grep -qE 'git\s+worktree\s+remove'; then

  # サンドボックスが worktree remove をブロックする場合がある。
  # tool_response にエラーがあれば、hookがサンドボックス外で削除を実行。
  tool_stderr=$(echo "$input" | jq -r '.tool_response.stderr // empty' 2>/dev/null)

  if echo "$tool_stderr" | grep -q 'Operation not permitted'; then
    # worktreeパスを抽出して削除を再実行
    wt_path=$(echo "$cmd" | sed -E 's/.*git worktree remove\s+(--force\s+)?//' | awk '{print $1}')
    if [ -n "$wt_path" ]; then
      cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null)
      [[ "$wt_path" != /* ]] && wt_path="${cwd:-.}/$wt_path"
      if git -C "$cwd" worktree remove --force "$wt_path" 2>&1; then
        echo "{\"additionalContext\": \"[worktree-setup] worktree削除: hookで再実行して成功\"}"
      else
        echo "{\"additionalContext\": \"[worktree-setup] worktree削除: 失敗。! git worktree remove --force $wt_path を実行してください\"}"
      fi
    fi
  fi
fi
