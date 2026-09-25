#!/bin/bash
# PreToolUse (EnterPlanMode) hook: plan-template skill の本文を additionalContext として注入
#
# plan-template は常時ロードされる rules/ には置かず、skill に一本化している。
# Plan Mode に入った瞬間にだけ本文（frontmatter を除く）を注入する。
# 手動（Shift+Tab 等）で Plan Mode に入った場合はこの hook が発火しないため、
# CLAUDE.md の「Plan Mode では plan-template skill を読み込む」指示で補う。
#
# stdin: PreToolUse の JSON（未使用）
# stdout: JSON（hookSpecificOutput.additionalContext に本文を埋め込む）
# exit 0

TEMPLATE_FILE="$HOME/.claude/skills/plan-template/SKILL.md"

[ -f "$TEMPLATE_FILE" ] || exit 0

awk 'NR==1 && /^---$/ {fm=1; next} fm && /^---$/ {fm=0; next} !fm' "$TEMPLATE_FILE" |
  jq -Rs '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: .}}'

exit 0
