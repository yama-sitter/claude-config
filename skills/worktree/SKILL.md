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
args: "[subcommand] [args]"
---

# Worktree Skill

Create and manage worktrees using Claude Code's built-in EnterWorktree/ExitWorktree tools.
WorktreeCreate hook automatically handles branch naming, dependency installation, and .env copying.

## Subcommands

| Command | Description |
|---|---|
| `/worktree <branch>` | Enter the worktree for `<branch>`. Create if not exists (with confirmation) |
| `/worktree current` | Re-enter the last worktree used in this session |
| `/worktree exit` | Exit the current worktree (keep/remove confirmation) |
| `/worktree search <query>` | Search worktrees by natural language query |
| `/worktree search` | List all worktrees and select interactively |
| `/worktree` (no args) | Same as `/worktree search` |

---

## Prerequisites

- The current directory is within a Git repository
- Not already inside a worktree (for enter commands)

---

## Subcommand: `/worktree <branch>`

### 1. Sanitize branch name

If the name contains `/`, replace with `-` and notify the user:
> `feature/login_bug` → `feature-login_bug` に変換しました（EnterWorktreeは `/` を含む名前に対応していません）

### 2. Check existing worktrees

```bash
git worktree list --porcelain
```

Search for a worktree whose branch matches the specified name.
Skip the first entry (main worktree).

### 3. Enter or create

- **Exists** → `EnterWorktree(name: "<branch>")` to enter (hook returns existing path)
- **Not exists** → AskUserQuestion: "ブランチ `<branch>` のworktreeは存在しません。作成しますか？"
  - Approved → `EnterWorktree(name: "<branch>")`
  - Declined → Stop

### 4. Verify setup

After entering, confirm dependencies and .env files are present.
If missing, report to the user.

---

## Subcommand: `/worktree current`

### 1. Check session history

Look back in this session's conversation history for the most recent `EnterWorktree` call.

### 2. Re-enter

- **Found** → `EnterWorktree(name: "<name>")` with the same name
- **Not found** → Fall back to worktree list:
  ```bash
  git worktree list --porcelain
  ```
  - 1 worktree → Enter it
  - Multiple → AskUserQuestion to select
  - None → Report "このセッションでworktreeを使っていません。`/worktree <branch>` で作成できます。"

---

## Subcommand: `/worktree exit`

### 1. Verify in worktree

Check if currently inside a worktree (`.git` is a file, not a directory).
If not in a worktree, report and stop.

### 2. Confirm action

AskUserQuestion:
- **keep** — worktreeとブランチを残す（後で再開可能）
- **remove** — worktreeとブランチを削除

### 3. Execute

- keep → `ExitWorktree(action: "keep")`
- remove → `ExitWorktree(action: "remove")`
  - If refused due to uncommitted changes → confirm with user, then `ExitWorktree(action: "remove", discard_changes: true)`

---

## Subcommand: `/worktree search <query>`

### 1. Get worktree list

```bash
git worktree list --porcelain
```

### 2. Match

Compare branch names and paths against the natural language query.
Filter to matching candidates.

### 3. Select and enter

- 1 match → Confirm and enter
- Multiple matches → AskUserQuestion to select → Enter
- No matches → Report

---

## Subcommand: `/worktree search` (no query) / `/worktree` (no args)

### 1. Get worktree list

```bash
git worktree list --porcelain
```

### 2. Present

List all worktrees (excluding main) with AskUserQuestion.

### 3. Enter selected

`EnterWorktree(name: "<selected-branch>")` for the chosen worktree.

---

## Notes

- **Branch naming**: Use flat format `<type>-<summary>` (e.g., `feature-login_bug`). No `/` in names.
- **WorktreeCreate hook**: Automatically handles branch creation (no `worktree-` prefix), dependency installation, and .env copying.
- **Do NOT call ExitWorktree proactively** — only via `/worktree exit` or explicit user request.
- **Fallback**: If WorktreeCreate hook is not configured, suggest `! pnpm install --frozen-lockfile && cp <repo-root>/.env* .` after entering.
