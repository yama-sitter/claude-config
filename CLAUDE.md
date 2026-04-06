# Claude Code Guidelines

## General

- Ask clarifying questions ONLY when the user's intent is genuinely ambiguous — NEVER re-ask about requirements the user has already explicitly stated, even if a subagent or plan recommends a different approach
- Always provide accurate and honest information. No flattery or sycophancy
- Respect the user's instructions. Do not optimize beyond what was asked
- Always respond in Japanese — applies to conversation text only, not to file edits
- ALWAYS match the existing language of a file when editing — do not let conversation language override file language

## Plan Mode Rules

- Follow the plan structure defined in plan-template.md when writing plans (unless superpowers flow is active)
- After the user approves the plan (ExitPlanMode approved), save the plan following Memory Guidelines

## Skill Conflict Resolution (superpowers vs custom skills)

### When superpowers flow is active

The superpowers flow is considered active when any of the following is true:

- The user explicitly invoked `/superpowers:brainstorming`
- The user explicitly requested superpowers usage (e.g., "use superpowers", "with the superpowers flow")
- Implementation is being driven by a plan file in `docs/superpowers/plans/`

When active:

- Plan template → Use `superpowers:writing-plans` (do not use `plan-template.md`)
- Plan review → Use superpowers subagent review
- Plan storage → Save to `docs/superpowers/plans/` → Execution Handoff の前に Memory Guidelines の手順で `agent-memory` にも保存

### When superpowers flow is NOT active

This includes: direct code change requests, Plan Mode, or any task where the user has not explicitly requested superpowers.

- Worktree → Use custom `worktree` skill (EnterWorktree/ExitWorktree)
- Brainstorming/design → Use custom `brainstorm` skill
- Plan template → Use `plan-template.md`
- Plan storage → `agent-memory` only

### Always applied (regardless of flow)

- All rules/ guidelines apply regardless of which flow is active
- Even if `superpowers:brainstorming` would auto-trigger, prefer custom skills unless the user explicitly requested superpowers
- Worktree operations always use the custom `worktree` skill (EnterWorktree/ExitWorktree), regardless of flow
- Brainstorming/design always uses the custom `brainstorm` skill, unless the user explicitly requested superpowers

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
