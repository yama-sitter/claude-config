#!/bin/bash
# PreToolUse (Bash) hook: PR 本文がリポジトリの PR テンプレートに従っているか検証する
#
# リポジトリに .github/PULL_REQUEST_TEMPLATE.md がある場合、gh pr create /
# gh pr edit を独自フォーマットの本文で実行してしまう事故が起きる。テキスト
# ベースのルールやスキル一覧は compaction で失われるが、hook は失われない。
# テンプレート内の「記入必須」マーカー付き見出しを動的に抽出し、--body に
# その見出しが含まれていなければブロックする。
#
# 対象外（意図的に検査しない）:
#   - --body-file: ファイル内容は検査しない
#   - gh stack submit --auto: --body を持たず本文を自動生成するためブロックしない
#
# stdin: PreToolUse の JSON（.tool_input.command にコマンド文字列が入る）
# exit 2 + stderr: ブロックし、理由を Claude に伝える
# exit 0: 素通り

PAYLOAD=$(cat)
CMD=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.command // empty')

# gh pr create / gh pr edit 以外は即座に素通り（全 Bash 呼び出しで発火するため）
echo "$CMD" | grep -qE '\bgh\s+pr\s+(create|edit)\b' || exit 0

# インラインの --body 指定がない場合は素通り（--body-file は対象外）
echo "$CMD" | grep -qE '(^|[[:space:]])--body([[:space:]=]|$)' || exit 0

REPO_DIR=$(printf '%s' "$PAYLOAD" | jq -r '.cwd // empty')
[ -n "$REPO_DIR" ] || REPO_DIR=$PWD
TEMPLATE="$REPO_DIR/.github/PULL_REQUEST_TEMPLATE.md"

# テンプレートがないリポジトリでは何も言わない
[ -f "$TEMPLATE" ] || exit 0

# 「記入必須」マーカー付きの ## 見出しを必須セクションとして動的に抽出し、
# マーカーと括弧を落とした見出しテキストに正規化する
strip_marker() {
  sed -e 's/^##[[:space:]]*//' \
      -e 's/(記入必須)//g' \
      -e 's/（記入必須）//g' \
      -e 's/記入必須//g' \
      -e 's/[[:space:]]*$//'
}

REQUIRED=$(grep '^## ' "$TEMPLATE" | grep '記入必須' | strip_marker)

# マーカーが一つもないテンプレートでは先頭の ## 見出しのみを必須とする
if [ -z "$REQUIRED" ]; then
  REQUIRED=$(grep '^## ' "$TEMPLATE" | head -n 1 | strip_marker)
fi
[ -n "$REQUIRED" ] || exit 0

MISSING=""
while IFS= read -r HEADING; do
  [ -n "$HEADING" ] || continue
  printf '%s' "$CMD" | grep -qF -- "$HEADING" && continue
  MISSING="${MISSING}  - ## ${HEADING}
"
done <<EOF
$REQUIRED
EOF

[ -n "$MISSING" ] || exit 0

{
  echo 'BLOCKED: このリポジトリには PR テンプレート（.github/PULL_REQUEST_TEMPLATE.md）があり、--body の本文に必須セクションの見出しが含まれていません。'
  echo '不足している必須見出し:'
  printf '%s' "$MISSING"
  echo 'テンプレートを読んで（cat .github/PULL_REQUEST_TEMPLATE.md）その構造に従って本文を組み立て直してください。'
  [ -d "$REPO_DIR/.claude/skills/pr-create" ] && echo 'このリポジトリには .claude/skills/pr-create/ があります。PR 作成はこのスキルの手順に従ってください。'
  [ -d "$REPO_DIR/.claude/skills/gh-stack" ] && echo 'このリポジトリには .claude/skills/gh-stack/ があります。単一 PR で作るか Stacked PR で作るかをユーザーに確認してから PR を作成してください。'
} >&2

exit 2
