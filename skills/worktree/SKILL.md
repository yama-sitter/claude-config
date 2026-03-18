---
name: worktree
description: |
  Create and switch Git worktrees using gwq.
  Use for "create worktree", "switch to branch", "review this PR", etc.
  Use this skill whenever the user mentions "worktree" in their request,
  even if they also mention development work — this skill handles the worktree setup part.
  Do not use for investigations or answering questions that don't involve worktree operations.
user-invocable: true
---

# gwq-worktree Skill

A skill for creating and managing Git worktrees using `gwq`, based on the user's task intent.

## Purpose

- Prepare worktrees for non-development tasks such as code reviews and PR checks
- Create or select the appropriate worktree using `gwq`
- Follow the project's Git branch naming conventions

This skill **only prepares the worktree**.
The actual review or investigation is done afterward.

---

## Prerequisites

- `gwq` is installed and available in PATH
- The current directory is within a Git repository managed by `gwq`
- `gwq list --json` is the source of truth for existing worktrees
- Follow the branch naming conventions defined in the [Git Guidelines](@../rules/git-guidelines.md)

---

## Workflow

### 1. Understand the Task

Determine the following from the user's request:

- The intent of the task (what they want to do)
- The appropriate branch type
- The branch summary

If any of these are unclear, confirm with AskUserQuestion.

---

### 2. Check Existing Worktrees

Run:

```bash
gwq list --json
```

If a worktree for the same branch already exists:

- Notify the user
- Explicitly confirm whether to reuse it
- Do not proceed without confirmation

---

### 3. Create the Worktree

If creating a new one is confirmed:

```bash
gwq add <branch-name>
```

Do not run git commands directly.

---

### 4. Completion

After the worktree is created or selected:

- Notify the user of the branch name
- Notify the user of the worktree path
- Stop execution

Do **not** do any of the following:

- Modify files
- Run tests
- Automatically start implementation
