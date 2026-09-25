#!/bin/bash
# PreToolUse (Bash) hook: git commit メッセージに Co-Authored-By が
# 混入していたらブロックする。
#
# skills/git/SKILL.md は「Do NOT add Co-Authored-By footer」と明示しているが、
# プロンプト指示だけでは system-reminder との衝突時に守られない場合があるため、
# ハーネスレベルで確実に強制する。
#
# stdin: PreToolUse の JSON（.tool_input.command にコマンド文字列が入る）
# exit 2 + stderr: ブロックし、理由を Claude に伝える
# exit 0: 素通り

CMD=$(jq -r '.tool_input.command // empty')

if ! echo "$CMD" | grep -qE '\bgit\s+(-C\s+\S+\s+)?commit\b'; then
  exit 0
fi

# コマンド文字列自体（-m 引数など）に含まれていないか
if echo "$CMD" | grep -qi 'co-authored-by'; then
  echo 'BLOCKED: git commit のコマンドに Co-Authored-By が含まれています。skills/git/SKILL.md の指示により付与禁止です。該当行を削除してから再実行してください。' >&2
  exit 2
fi

# -F <file> で指定されたファイルの中身も確認する
FILE=$(echo "$CMD" | grep -oE '(-F|--file)[[:space:]]+\S+' | awk '{print $2}' | head -n1)

if [ -n "$FILE" ]; then
  FILE=${FILE/#\~/$HOME}
  if [ -f "$FILE" ] && grep -qi 'co-authored-by' "$FILE"; then
    echo "BLOCKED: git commit -F で指定されたファイル ($FILE) に Co-Authored-By が含まれています。skills/git/SKILL.md の指示により付与禁止です。該当行を削除してから再実行してください。" >&2
    exit 2
  fi
fi

exit 0
