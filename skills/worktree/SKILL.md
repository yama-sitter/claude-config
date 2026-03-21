---
name: worktree
description: |
  Create Git worktrees in .worktrees/ for isolated branch work.
  Use for "create worktree", "worktreeを作って", "review this PR in worktree", etc.
  Use this skill whenever the user mentions "worktree" in their request,
  even if they also mention development work — this skill handles the worktree setup part.
  Do not use for investigations or answering questions that don't involve worktree operations.
  Do not use when the user has explicitly requested superpowers workflow (e.g., "/superpowers:brainstorming")
  or when executing a plan from docs/superpowers/plans/.
user-invocable: true
---

# Worktree Skill

Create and manage Git worktrees within `.worktrees/` for isolated branch work.
Handles new branch creation + worktree setup in a single step, or worktree creation for an existing branch.

## Purpose

- Prepare worktrees for tasks such as code reviews, PR checks, and feature work
- Create worktrees in `.worktrees/` to avoid Claude Code permission prompts
- Create a new branch simultaneously when one doesn't exist yet
- Follow the project's Git branch naming conventions

This skill **only prepares the worktree**.
The actual review, investigation, or implementation is done afterward.

---

## Prerequisites

- The current directory is within a Git repository
- Follow the branch naming conventions defined in the [Git Guidelines](@../rules/git-guidelines.md)

---

## Workflow

### 1. Understand the Task and Determine Mode

Analyze the user's request to determine the mode:

| Condition | Mode | Action |
|-----------|------|--------|
| Task description only (no branch name) | **Branch + Worktree** | Propose branch name → approval → create both with `-b` |
| Existing branch name specified | **Worktree Only** | Create worktree for that branch |
| `/branch` was used earlier in conversation | **Worktree Only (fallback)** | Detect and handle checkout conflicts |

If anything is unclear, confirm with AskUserQuestion.

---

### 2. Propose Branch Name (Branch + Worktree mode only)

Based on the task description, propose a branch name following Git Guidelines:

- Format: `<type>/<summary>` (snake_case)
- Types: feature, fix, docs, style, refactor, test, chore

**Present the proposed branch name to the user and get approval before proceeding.**

---

### 3. Verify .gitignore

Before creating any worktree, verify `.worktrees/` is ignored:

```bash
git check-ignore -q .worktrees 2>/dev/null
```

If NOT ignored:
1. Add `.worktrees/` to `.gitignore`
2. Commit the change
3. Proceed with worktree creation

---

### 4. Check for Conflicts

Run the following to assess the current state:

```bash
git worktree list
git branch --list <branch-name>
current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
```

Handle each case:

**Branch does not exist:**
→ Proceed to Step 5 with `-b` flag (creates branch + worktree simultaneously).

**Branch exists, no worktree for it, NOT currently checked out:**
→ Proceed to Step 5 without `-b` flag.

**Branch exists, no worktree for it, IS currently checked out (e.g., after `/branch`):**
1. Check for uncommitted changes with `git status`.
2. If uncommitted changes exist: ask the user whether to stash or commit them first.
3. Run `git checkout main` (or the appropriate base branch).
4. Proceed to Step 5 without `-b` flag.

**Branch exists AND worktree exists:**
→ Notify the user and ask whether to reuse the existing worktree. Do not proceed without confirmation.

---

### 5. Create the Worktree

Derive the worktree directory name from the branch name by removing the `<type>/` prefix:
- `feature/add_mcp_auth` → `add_mcp_auth`
- `fix/login_bug` → `login_bug`
- `test/worktree_check` → `worktree_check`

Execute:

```bash
# Branch + Worktree (new branch)
git worktree add .worktrees/<worktree-name> -b <branch-name>

# Worktree Only (existing branch)
git worktree add .worktrees/<worktree-name> <branch-name>
```

If the command fails:
- Branch already exists unexpectedly → switch to Worktree Only mode and retry
- Worktree path conflicts → run `git worktree prune` and retry
- Otherwise → report the error to the user

---

### 6. Completion

After the worktree is created:

- Report the branch name
- Report the worktree path (absolute)
- Stop execution

Do **not** do any of the following:

- Modify files
- Run tests
- Install dependencies
- Automatically start implementation
