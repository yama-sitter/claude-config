#!/bin/bash
# PreToolUse (Bash) hook: git rebase をブロックする
#
# サンドボックスは .git/rebase-merge/ 等のドットファイル作成をブロックするため、
# git rebase / rebase --continue / rebase --abort を実行すると rebase state が
# 壊れる。ユーザーに「! git rebase <args>」で実行してもらう。
#
# stdin: PreToolUse の JSON（.tool_input.command にコマンド文字列が入る）
# exit 2 + stderr: ブロックし、理由を Claude に伝える
# exit 0: 素通り

CMD=$(jq -r '.tool_input.command // empty')

if echo "$CMD" | grep -qE '\bgit\s+rebase\b'; then
  echo 'BLOCKED: git rebase はサンドボックスでドットファイル作成がブロックされ、rebase state が壊れます。git rebase / rebase --continue / rebase --abort はすべて「! git rebase <args>」でユーザーに実行を依頼してください。' >&2
  exit 2
fi

exit 0
