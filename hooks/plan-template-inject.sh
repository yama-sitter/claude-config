#!/bin/bash
# PreToolUse (EnterPlanMode) hook: plan-template.md を additionalContext として注入
#
# rules/plan-template.md は常時ロードされる rules/ から外し、Plan Mode に
# 入った瞬間にだけ全文を注入する。手動（Shift+Tab 等）で Plan Mode に入った
# 場合はこの hook が発火しないため、圧縮版の要点は rules/ 側にも残してある
# （この hook はあくまで補完）。
#
# stdin: PreToolUse の JSON（未使用）
# stdout: JSON（hookSpecificOutput.additionalContext に全文を埋め込む）
# exit 0

TEMPLATE_FILE="$HOME/.claude/rules/plan-template.md"

[ -f "$TEMPLATE_FILE" ] || exit 0

jq -n --rawfile template "$TEMPLATE_FILE" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $template}}'

exit 0
