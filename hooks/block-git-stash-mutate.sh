#!/bin/bash
# PreToolUse (Bash) hook: git stash の破壊的サブコマンドをブロックする
#
# git stash はリポジトリ全体で共有される単一の LIFO スタックであり、
# 現在のタスク/セッションにスコープされていない。pop/apply/drop/clear を
# 実行すると、このセッション開始前から存在していた無関係な stash を
# 誤って適用・破棄し、他の作業と静かに衝突・消失させる恐れがある。
# list/show/push/save は安全な操作のためブロックしない。
#
# stdin: PreToolUse の JSON（.tool_input.command にコマンド文字列が入る）
# exit 2 + stderr: ブロックし、理由を Claude に伝える
# exit 0: 素通り

CMD=$(jq -r '.tool_input.command // empty')

if echo "$CMD" | grep -qE '\bgit\s+stash\s+(--\S+\s+)*(pop|apply|drop|clear)\b'; then
  echo 'BLOCKED: git stash は全タスク共通の単一スタックです。pop/apply/drop/clear はセッション開始前からの無関係な stash を誤って適用・破棄する恐れがあるため、「! git stash <args>」でユーザーに実行を依頼してください。' >&2
  exit 2
fi

exit 0
