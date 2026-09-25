#!/bin/bash
# PreToolUse (Bash) hook: シェル演算子付き / run 省略の pnpm test:unit をブロックする
#
# パイプ・リダイレクト・連結や run 省略があると sandbox.excludedCommands の
# "pnpm run test:unit*" にマッチせずサンドボックス内で実行され、.env.local が読めず
# [setupEnv] エラーで失敗すると推定される（excludedCommands の複合コマンド判定は未文書化）。
#
# stdin: PreToolUse の JSON（.tool_input.command にコマンド文字列が入る）
# exit 2 + stderr: ブロックし、理由を Claude に伝える
# exit 0: 素通り

CMD=$(jq -r '.tool_input.command // empty')

# コマンド位置（先頭 or 演算子直後）の pnpm のみ対象。引数内の文字列（commit メッセージ等）は除外
CMD_POS='(^|[;&|(`]|\$\()[[:space:]]*pnpm[[:space:]]+'

if ! echo "$CMD" | grep -qE "${CMD_POS}(run[[:space:]]+)?test:unit"; then
  exit 0
fi

if echo "$CMD" | grep -qE '[|;&<>`]|\$\(' || echo "$CMD" | grep -qE "${CMD_POS}test:unit"; then
  echo 'BLOCKED: test:unit はパイプ/リダイレクト/連結（| > 2>&1 && ; など）や run 省略があると sandbox.excludedCommands に一致せずサンドボックス内で実行され、.env.local を読めず [setupEnv] エラーで失敗します。演算子を付けずに pnpm run test:unit <path> 単体で再実行してください（cd も付けない）。出力が長くてもそのまま実行してください。.env.local の存在確認やユーザーへの手動実行依頼は不要です。' >&2
  exit 2
fi

exit 0
