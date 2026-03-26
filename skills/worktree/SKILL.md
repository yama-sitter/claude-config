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

| Command                    | Description                                                                 |
| -------------------------- | --------------------------------------------------------------------------- |
| `/worktree <branch>`       | Enter the worktree for `<branch>`. Create if not exists (with confirmation) |
| `/worktree current`        | Re-enter the last worktree used in this session                             |
| `/worktree exit`           | Exit the current worktree (keep/remove confirmation)                        |
| `/worktree search <query>` | Search worktrees by natural language query                                  |
| `/worktree search`         | List all worktrees and select interactively                                 |
| `/worktree` (no args)      | Same as `/worktree search`                                                  |

---

## Prerequisites

- The current directory is within a Git repository
- Not already inside a worktree (for enter commands)

---

## Subcommand: `/worktree <branch>`

### 1. Process branch name

- If the name does **not** contain `/` → `name = branch = input` (no change needed)
- If the name contains `/`:
  - `branch` = original input (e.g., `feature/login_bug`)
  - `name` = replace `/` with `-` (e.g., `feature-login_bug`) — for EnterWorktree
  - Notify: `feature/login_bug` → worktree name `feature-login_bug` (branch name `feature/login_bug` is preserved)

### 2. Check existing worktrees

```bash
git worktree list --porcelain
```

Search for existing worktrees. Skip the first entry (main worktree).
Match by **either**:

1. `name` (hyphen form) in the worktree path
2. `branch` (slash form) in `branch refs/heads/` lines

### 3. Enter or create

- **Exists** → `EnterWorktree(name: "<name>")` to enter (hook returns existing path). No override file needed.
- **Not exists** →
    1. If `branch` contains `/`, write override file using the Write tool:
       `Write(file_path: "~/.claude/.worktree-branch-override", content: "<branch>\n")`
    2. `EnterWorktree(name: "<name>")`

### 4. Verify setup

After entering, use Glob to confirm setup:

- `Glob(pattern: "node_modules/.pnpm/lock.yaml", path: "<worktree-root>")` — check dependencies installed
- `Glob(pattern: ".env*", path: "<worktree-root>")` — check .env files copied

If either is missing, report to the user.

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
- remove → Pre-check worktree state before calling ExitWorktree:
  1. Run `git status --short` to check for uncommitted changes
  2. Run `git log --oneline @{u}..HEAD 2>/dev/null` to check for unpushed commits (if command fails, treat as unpushed)
  3. Decision:
     - Clean + pushed → `ExitWorktree(action: "remove", discard_changes: true)` (no confirmation needed)
     - Clean + unpushed → warn "未プッシュのコミットがあります" → confirm → `ExitWorktree(action: "remove", discard_changes: true)`
     - Dirty (uncommitted changes) → warn "未コミットの変更があります" → confirm → `ExitWorktree(action: "remove", discard_changes: true)`
  4. **Verify removal**: After ExitWorktree completes, run `git worktree list --porcelain` and check the worktree path is gone.
     - Still present → attempt `git worktree remove --force <path>` as automatic recovery, then `git worktree prune`
     - Recovery also fails → report to user: "worktreeの削除に失敗しました。手動で実行してください: `git worktree remove --force <path> && git branch -D <branch>`"

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

- **Branch naming**: Slash format `<type>/<summary>` (e.g., `feature/login_bug`) is supported. The worktree name (directory) uses hyphen form `<type>-<summary>`, while the git branch preserves the original slash form.
- **WorktreeCreate hook**: Automatically handles branch creation (no `worktree-` prefix), dependency installation, and .env copying.
- **Do NOT call ExitWorktree proactively** — only via `/worktree exit` or explicit user request.
- **Fallback**: If WorktreeCreate hook is not configured, suggest `! pnpm install --frozen-lockfile && cp <repo-root>/.env* .` after entering.
