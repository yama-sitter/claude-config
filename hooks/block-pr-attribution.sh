#!/bin/bash
# PreToolUse (Bash) hook: gh pr create/edit の本文に
# 「Generated with Claude Code」等の attribution 行が混入していたらブロックする。
#
# skills/git/SKILL.md は PR body に attribution footer を付けない前提だが、
# プロンプト指示だけでは system-reminder との衝突時に守られない場合があるため、
# ハーネスレベルで確実に強制する。
#
# stdin: PreToolUse の JSON（.tool_input.command にコマンド文字列が入る）
# exit 2 + stderr: ブロックし、理由を Claude に伝える
# exit 0: 素通り

CMD=$(jq -r '.tool_input.command // empty')

if ! echo "$CMD" | grep -qE '\bgh\s+pr\s+(create|edit)\b'; then
  exit 0
fi

# コマンド文字列自体（--body の中身はヒアドキュメントでコマンド文字列に
# インライン展開されているため、ここに含まれる）に含まれていないか
if echo "$CMD" | grep -qiE 'generated with \[?claude code|🤖'; then
  echo 'BLOCKED: gh pr create/edit の本文に Claude Code の attribution 行が含まれています。skills/git/SKILL.md の指示により付与禁止です。該当行を削除してから再実行してください。' >&2
  exit 2
fi

# --body-file <file> で指定されたファイルの中身も確認する
FILE=$(echo "$CMD" | grep -oE '(-F|--body-file)[[:space:]]+\S+' | awk '{print $2}' | head -n1)

if [ -n "$FILE" ]; then
  FILE=${FILE/#\~/$HOME}
  if [ -f "$FILE" ] && grep -qiE 'generated with \[?claude code|🤖' "$FILE"; then
    echo "BLOCKED: gh pr create/edit --body-file で指定されたファイル ($FILE) に Claude Code の attribution 行が含まれています。skills/git/SKILL.md の指示により付与禁止です。該当行を削除してから再実行してください。" >&2
    exit 2
  fi
fi

exit 0
