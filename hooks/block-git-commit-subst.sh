#!/bin/bash
# PreToolUse (Bash) hook: コマンド置換を含む git commit をブロックする
#
# $() やバッククォートを含むと sandbox.excludedCommands の "git commit *" に
# マッチせずサンドボックス内で実行され、~/.ssh が読めず SSH 署名が失敗する。
#
# stdin: PreToolUse の JSON（.tool_input.command にコマンド文字列が入る）
# exit 2 + stderr: ブロックし、理由を Claude に伝える
# exit 0: 素通り

CMD=$(jq -r '.tool_input.command // empty')

if echo "$CMD" | grep -qE '\bgit\s+(-C\s+\S+\s+)?commit\b' && echo "$CMD" | grep -qE '\$\(|`'; then
  echo 'BLOCKED: コマンド置換（$() / バッククォート）を含む git commit は sandbox.excludedCommands にマッチせず、サンドボックス内で SSH 署名が失敗します。(1) git commit -m "<title>" -m "<body>"（本文に $ やバッククォートを含めない）か、(2) Write ツールでメッセージを /private/tmp/claude/commit-msg.txt に書き git commit -F /private/tmp/claude/commit-msg.txt を使ってください。' >&2
  exit 2
fi

exit 0
