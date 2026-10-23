#!/bin/bash
# PreToolUse (Bash) hook: コマンド置換またはシェル演算子を含む git commit をブロックする
#
# $() やバッククォート、パイプ・リダイレクト・連結（| ; & < > 改行）を含むと
# sandbox.excludedCommands の "git commit *" にマッチせずサンドボックス内で実行され、
# ~/.ssh が読めず SSH 署名が失敗する。
#
# stdin: PreToolUse の JSON（.tool_input.command にコマンド文字列が入る）
# exit 2 + stderr: ブロックし、理由を Claude に伝える
# exit 0: 素通り

CMD=$(jq -r '.tool_input.command // empty')

if echo "$CMD" | grep -qE '\bgit\s+(-C\s+\S+\s+)?commit\b' && echo "$CMD" | grep -qE '\$\(|`'; then
  echo 'BLOCKED: コマンド置換（$() / バッククォート）を含む git commit は sandbox.excludedCommands にマッチせず、サンドボックス内で SSH 署名が失敗します。(1) git commit -m "<title>" -m "<body>"（本文に $ やバッククォートを含めない）か、(2) Write ツールでメッセージを /private/tmp/claude/commit-msg.txt に書き git commit -F /private/tmp/claude/commit-msg.txt を使ってください。' >&2
  exit 2
fi

# 演算子チェック: 改行は ; に変換し、クォート内の文字列を除去してから判定する
# （-m "fix: a; b" のような引用符内の記号を誤検知しないため）
STRIPPED=$(printf '%s' "$CMD" | tr '\n' ';' | sed -E "s/\"[^\"]*\"//g; s/'[^']*'//g")

if printf '%s' "$STRIPPED" | grep -qE '\bgit[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?commit\b' && printf '%s' "$STRIPPED" | grep -qE '[|;&<>]'; then
  echo 'BLOCKED: パイプ・リダイレクト・連結（| ; && || > 2>&1、cd 前置、改行連結）を含む git commit は sandbox.excludedCommands にマッチせず、サンドボックス内で実行されて SSH 署名が失敗します。"Couldn'"'"'t load public key" は ~/.ssh が読めないことが原因ではなく、このマッチ失敗が原因です。git commit -F /private/tmp/claude/commit-msg.txt を単独で実行し、git log / git status は別の Bash 呼び出しで実行してください。ノイズ出力を隠そうとしないでください。ユーザーに手動実行を依頼する必要はありません。' >&2
  exit 2
fi

exit 0
