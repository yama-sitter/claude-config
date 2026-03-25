---
name: worktree
description: |
  Create and manage worktrees using EnterWorktree/ExitWorktree.
  Use for "create worktree", "worktreeを作って", "review this PR in worktree", etc.
  Use this skill whenever the user mentions "worktree" in their request,
  even if they also mention development work — this skill handles the worktree setup part.
  Do not use for investigations or answering questions that don't involve worktree operations.
  Do not use when the user has explicitly requested superpowers workflow (e.g., "/superpowers:brainstorming")
  or when executing a plan from docs/superpowers/plans/.
user-invocable: true
---

# Worktree Skill

Create and manage worktrees using Claude Code's built-in EnterWorktree/ExitWorktree tools.
WorktreeCreate hook automatically handles dependency installation and .env copying.

## Purpose

- Create isolated worktrees for code reviews, PR checks, and feature work
- Automatic setup via WorktreeCreate hook (dependencies, .env files)
- Stay in the same session (no separate process needed)

This skill **prepares a work-ready worktree**.
The actual review, investigation, or implementation is done afterward.

---

## Prerequisites

- The current directory is within a Git repository
- Not already inside a worktree (EnterWorktree cannot be nested)

---

## Workflow

### 1. Understand the Task and Propose Branch Name

Analyze the user's request and propose a branch name.

**Naming rules:**
- Flat format: `<type>-<summary>` (no `/` — EnterWorktree hangs with `/` in the name)
- Types: feature, fix, docs, style, refactor, test, chore
- Use snake_case for the summary part
- Examples: `feature-login_bug`, `fix-api_timeout`, `refactor-auth_middleware`

**Present the proposed name to the user and get approval with AskUserQuestion.**
Do NOT skip this step.

---

### 2. Execute EnterWorktree

Call the EnterWorktree tool with the approved name:

```
EnterWorktree(name: "<branch-name>")
```

The WorktreeCreate hook automatically:
- Creates the worktree at `.claude/worktrees/<name>/`
- Creates a branch named `<name>` (no `worktree-` prefix)
- Installs dependencies (detects pnpm-lock.yaml / package-lock.json / yarn.lock)
- Copies gitignored `.env*` files from the source repository

---

### 3. Verify Setup

After entering the worktree, confirm:
- Dependencies are installed (`node_modules/` or equivalent exists)
- Required `.env*` files exist (if the source repo has them)

If anything is missing, report to the user. Do not proceed with work until setup is complete.

---

### 4. Work (outside this skill's scope)

The worktree is ready. Proceed with the requested task (review, implementation, etc.).

---

## ExitWorktree

Use ExitWorktree **only when the user explicitly asks** to leave the worktree ("worktreeを出て", "exit worktree", "go back", etc.).

- `action: "keep"` — Leave worktree and branch on disk for later
- `action: "remove"` — Delete worktree and branch
  - If there are uncommitted changes, ExitWorktree will refuse. Confirm with the user, then re-invoke with `discard_changes: true`

**Do NOT call ExitWorktree proactively.**

---

## Fallback (hook not configured)

If the WorktreeCreate hook is not configured (e.g., in a different environment), EnterWorktree will still create the worktree with default behavior (branch named `worktree-<name>`). In this case:

1. After entering the worktree, suggest the user run setup manually:
   ```
   ! pnpm install --frozen-lockfile && cp <repo-root>/.env* .
   ```
2. Or use `! npm ci` / `! yarn install --frozen-lockfile` depending on the lock file present.
