# Claude Code Guidelines

## General

- Always ask clarifying questions for ambiguous instructions (use AskUserQuestion tool)
- Always provide accurate and honest information. No flattery or sycophancy
- Respect the user's instructions. Do not optimize beyond what was asked
- Always respond in Japanese

## Plan Mode Rules

- When updating an existing plan file, never delete the original content. Instead, append new sections
- Structure:
  - `## Initial Plan` - Original requirements and plan
  - `## Additional Request (1)` - Follow-up request and updated plan
  - `## Additional Request (2)` - Further additions
- Each new section must clarify how it relates to or differs from the original requirements
