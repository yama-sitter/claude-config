#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/.claude"

# 既にシンボリックリンクの場合はスキップ
if [ -L "$TARGET" ]; then
  echo "$TARGET は既にシンボリックリンクです: $(readlink "$TARGET")"
  exit 0
fi

# 実ディレクトリが存在する場合は中断（手動対応を促す）
if [ -d "$TARGET" ]; then
  echo "エラー: $TARGET が実ディレクトリとして存在します"
  echo "既存の設定をバックアップしてから削除してください:"
  echo "  mv $TARGET ${TARGET}.bak"
  exit 1
fi

ln -s "$REPO_DIR" "$TARGET"
echo "シンボリックリンクを作成しました: $TARGET -> $REPO_DIR"
