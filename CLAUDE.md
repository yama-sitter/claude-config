# Claude Code Guidelines

## General

- Ask clarifying questions ONLY when the user's intent is genuinely ambiguous — NEVER re-ask about requirements the user has already explicitly stated, even if a subagent or plan recommends a different approach
- Always provide accurate and honest information. No flattery or sycophancy
- YAGNI: Do not build what is not needed now
- When in doubt, choose the simpler option — fewer lines, fewer moving parts
- Follow existing codebase patterns. If a similar implementation exists, match it
- Do not introduce new abstractions, layers, or utilities without stating the reason in the plan and getting user approval first
- Keep changes within the requested scope. No surrounding improvements or refactoring
- Keep responses concise — state results and decisions directly, without restating what was already established or narrating routine actions
- Brief each subagent precisely once and do not re-derive its findings after it reports back. Cap parallel subagents at roughly 5-8 unless the task genuinely requires more
- Always respond in Japanese — applies to conversation text only, not to file edits
- ALWAYS match the existing language of a file when editing — do not let conversation language override file language
- Use the custom `worktree` skill for worktree operations, and the custom `brainstorm` skill for brainstorming/design

## Bilingual Document Management

See `rules/skill-bilingual.md` for the policy on bilingual document management (English primary + Japanese mirror).

## Plan Mode Rules

- When writing a plan in Plan Mode, ALWAYS load the `plan-template` skill first and follow its structure
- After the user approves the plan (ExitPlanMode approved), save the plan to `agent-memory` following Memory Guidelines

## Context Pressure

- NEVER write code without having read the relevant source files in THIS conversation — do not fill in file contents from memory
- If you notice degradation (losing earlier decisions, repeating completed work, vague answers where specifics are needed), declare it to the user and stop rather than producing low-quality output
- For exploratory investigation across many files or large log/test output, delegate to a subagent and receive only the summary

## Session Management

- One task per session. Use `/clear` to start the next task after completing the current one
- Before switching tasks, save important decisions to memory (`/agent-memory`)
- When planning and implementation happen in the same session, run `/compact` between phases
- Prefer separate sessions for Plan Mode (planning) and implementation (plan file bridges the gap)

## Compact Instructions

When compacting, preserve:

- The user's request and intent
- File paths modified and a summary of changes
- Incomplete tasks and their current state
- Key technical decisions and their rationale
- Errors encountered and how they were resolved
