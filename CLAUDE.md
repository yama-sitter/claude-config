# Claude Code Guidelines

## General

- Always ask clarifying questions for ambiguous instructions (use AskUserQuestion tool)
- Always provide accurate and honest information. No flattery or sycophancy
- Respect the user's instructions. Do not optimize beyond what was asked
- Always respond in Japanese

## Plan Mode Rules

- After writing the plan, perform a self-review following the Plan Review Guidelines before finalizing
- Before calling ExitPlanMode, save the plan content using the `/agent-memory` skill
  - Scope: the current repository name
  - Directory name: `<YYYY-MM-DD>_<task-description>-plan`
  - File name: `plan.md`
  - Include in the memory: task goal, implementation approach, key files, and verification steps
  - If a related plan memory already exists, update it instead of creating a new one

## Skill Conflict Resolution (superpowers vs custom skills)

### When superpowers flow is active

The superpowers flow is considered active when any of the following is true:
- The user explicitly invoked `/superpowers:brainstorming`
- The user explicitly requested superpowers usage (e.g., "use superpowers", "with the superpowers flow")
- Implementation is being driven by a plan file in `docs/superpowers/plans/`

When active:
- Worktree → Use `superpowers:using-git-worktrees` (do not use custom `worktree` skill)
- Plan review → Use superpowers subagent review
- Plan storage → Save to `docs/superpowers/plans/` and also copy to `agent-memory`

### When superpowers flow is NOT active

This includes: direct code change requests, Plan Mode, or any task where the user has not explicitly requested superpowers.

- Worktree → Use custom `worktree` skill (gwq)
- Plan review → Use `plan-review.md` (3-cycle self-review)
- Plan storage → `agent-memory` only

### Always applied (regardless of flow)

- Git Guidelines (branch naming, Japanese commit messages, no co-author footers) always apply
- Even if `superpowers:brainstorming` would auto-trigger, prefer custom skills unless the user explicitly requested superpowers
