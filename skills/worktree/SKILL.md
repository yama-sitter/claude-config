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
| `/worktree verify`         | Enter verify mode: checkout worktree HEAD as detached HEAD on main          |
| `/worktree resume`         | Exit verify mode: return to worktree for development                        |
| `/worktree search <query>` | Search worktrees by natural language query                                  |
| `/worktree search`         | List all worktrees and select interactively                                 |
| `/worktree` (no args)      | Same as `/worktree search`                                                  |

---

## Prerequisites

- The current directory is within a Git repository
- Not already inside a worktree (for enter commands)

---

## Subcommand: `/worktree <branch>`

### 0. Verify state guard

Read `$TMPDIR/.claude-worktree-verify-state`. If the file exists, parse as JSON and check `active` field.

- `active: true` (or field missing for backward compatibility) → report "確認モード中です。先に `/worktree resume` または `/worktree exit` を実行してください" and stop.
- `active: false`, empty file, or file does not exist → proceed.

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

1. If `branch` contains `/`, always write override file (regardless of exists/not-exists):
   `Bash: printf '%s\n' '<branch>' > "/private/tmp/claude/claude-501/.claude-worktree-branch-override"`
2. **Exists** → `EnterWorktree(name: "<name>")`
3. **Not exists** → `EnterWorktree(name: "<name>")`

### 4. Verify setup

After entering, verify setup:

1. Check dependencies: Use Glob to find lock files, then verify each has a sibling `node_modules/` directory
   - Step A: Search for lock files (5 patterns, can be called in parallel)
     - `Glob(pattern: "**/pnpm-lock.yaml", path: "<worktree-root>")`
     - `Glob(pattern: "**/package-lock.json", path: "<worktree-root>")`
     - `Glob(pattern: "**/yarn.lock", path: "<worktree-root>")`
     - `Glob(pattern: "**/bun.lockb", path: "<worktree-root>")`
     - `Glob(pattern: "**/bun.lock", path: "<worktree-root>")`
   - Step B: Collect parent directories of found lock files and deduplicate
   - Step C: For each parent directory, run `Glob(pattern: "<parent-dir>/node_modules/*")` (empty result = dependencies not installed)
   - Step D: Report `MISSING: <dir>/node_modules` for any directory without node_modules
2. Check .env files: `Glob(pattern: "**/.env*", path: "<worktree-root>")` — check .env files present at all levels

If any directory is missing dependencies or .env files, report to the user.

---

## Subcommand: `/worktree current`

### 0. Verify state guard

Read `$TMPDIR/.claude-worktree-verify-state`. If the file exists, parse as JSON and check `active` field.

- `active: true` (or field missing for backward compatibility) → report "確認モード中です。`/worktree resume` または `/worktree exit` を実行してください" and stop.
- `active: false`, empty file, or file does not exist → proceed.

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

### 0. Handle verify state

Read `$TMPDIR/.claude-worktree-verify-state`. If the file exists, parse as JSON and check `active` field.

If `active: true` (or field missing for backward compatibility):

1. Read the state file
2. Restore main branch: `git symbolic-ref HEAD 2>/dev/null` — if fails (detached HEAD), run `git checkout <mainBranch>`. If checkout fails due to sandbox permission errors on `.claude/` files, use `git checkout -f <mainBranch>`. Permission errors on `.claude/` files can be ignored if `Switched to branch` is confirmed in output.
3. Restore stash: if `stashed` is `true`, check `git stash list` first entry for `worktree-verify-auto-stash` — if match, `git stash pop`
4. Deactivate the state file: use Write tool to update JSON with `"active": false` (preserve other fields)
5. Re-enter worktree: Derive `worktreeName` by replacing `/` with `-` in `worktreeBranch`, then call `EnterWorktree(name: "<worktreeName>")`. This re-entry is needed because you are in the main working directory during verify mode, and Step 1's "inside a worktree" check requires it.
6. Continue to the normal exit flow (step 1 onward) — user will be asked keep/remove for the worktree

If `active: false`, empty file, or file does not exist → skip (no verify state to handle).

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

## Subcommand: `/worktree verify`

Switch to verify mode: checkout the worktree branch HEAD as detached HEAD on the main working directory, so you can run services and test changes without worktree environment setup.

### 0. Verify state guard

Read `$TMPDIR/.claude-worktree-verify-state`. If the file exists, parse as JSON and check `active` field.

- `active: true` (or field missing for backward compatibility) → report "既に確認モード中です。`/worktree resume` で開発に戻るか、`/worktree exit` で終了してください" and stop.
- `active: false`, empty file, or file does not exist → proceed.

### 1. Verify in worktree

Check if currently inside a worktree (`.git` is a file, not a directory).
If not in a worktree, report "worktree内でのみ実行できます" and stop.

### 2. Check for uncommitted changes

```bash
git status --porcelain
```

- Output is empty → proceed
- Output contains lines NOT starting with `??` (staged/modified changes exist) → report "未コミットの変更があります。先にコミットしてから `/worktree verify` を実行してください" and stop
- Output contains only `??` lines (untracked files only) → warn "untracked filesがあります。verify中は反映されませんが続行します" and proceed

### 3. Collect worktree info

Run these commands and save the results:

```bash
# commit hash
git rev-parse HEAD

# branch name
git rev-parse --abbrev-ref HEAD

# worktree absolute path
git rev-parse --show-toplevel
```

Save these as variables: `commitHash`, `worktreeBranch`, `worktreePath`.

### 4. Exit worktree (keep)

```
ExitWorktree(action: "keep")
```

This exits the worktree session but preserves the worktree git registration. `git worktree remove` is NOT called.

### 5. Get main branch name

Now in the main working directory:

```bash
git rev-parse --abbrev-ref HEAD
```

Save as `mainBranch`.

### 6. Stash main changes (if any)

```bash
git status --porcelain
```

- Output contains lines NOT starting with `??` (staged/modified changes exist) → run `git stash push -m "worktree-verify-auto-stash"` and set `stashed = true`
- Output is empty, or contains only `??` lines (untracked files only) → set `stashed = false`

Note: untracked files don't affect checkout, so stash は不要。

### 7. Checkout detached HEAD

```bash
git checkout <commitHash>
```

This puts the main working directory at the exact commit from the worktree branch, in detached HEAD state.

**Sandbox note**: Permission errors on `.claude/` or `.vscode/` files (e.g., "unable to unlink") can be safely ignored if `HEAD is now at` is confirmed in the output. These errors are caused by sandbox filesystem restrictions and do not affect the checkout result.

### 8. Save state file

Write to `$TMPDIR/.claude-worktree-verify-state`:

```json
{
  "worktreePath": "<worktreePath>",
  "worktreeBranch": "<worktreeBranch>",
  "mainBranch": "<mainBranch>",
  "stashed": <true|false>,
  "commitHash": "<commitHash>",
  "active": true
}
```

**Important**: This file is written AFTER ExitWorktree and git checkout succeed, to avoid leaving orphaned state on failure.

### 9. Notify

Report:

> 確認モードに移行しました。メインの作業ディレクトリが `<worktreeBranch>` のコミット `<commitHash short>` を指しています。
> サービスを起動して動作確認してください。
> 完了後、`/worktree resume` で開発に戻れます。

---

## Subcommand: `/worktree resume`

Exit verify mode: restore the main working directory and re-enter the worktree.

### 1. Check state file

Read `$TMPDIR/.claude-worktree-verify-state`. If the file does not exist, is empty, or parses as JSON with `active: false`, report "確認モードではありません" and stop.
If `active: true` (or field missing for backward compatibility), proceed with the state data.

### 2. Restore main branch

Check current HEAD state:

```bash
git symbolic-ref HEAD 2>/dev/null
```

- Command fails (detached HEAD) → run `git checkout <mainBranch>` to restore. If checkout fails due to sandbox permission errors on `.claude/` files, use `git checkout -f <mainBranch>`. Permission errors on `.claude/` files can be ignored if `Switched to branch` is confirmed in output.
- Command succeeds (already on a branch) → user switched manually, skip this step

### 3. Restore stashed changes

If `stashed` is `true` in the state file:

```bash
git stash list
```

Check if the first entry message contains `worktree-verify-auto-stash`.

- Match → `git stash pop`
  - If pop fails with conflict → warn "stash popでコンフリクトが発生しました。手動で解決してください: `git stash pop`" and continue (do NOT stop — still need to clean up state and re-enter worktree)
- No match → notify "自動stashが見つかりません。`git stash list` を確認してください" and continue

If `stashed` is `false`, skip this step.

### 4. Deactivate state file

Use the Write tool to update `$TMPDIR/.claude-worktree-verify-state` with `"active": false` (preserve all other fields).

### 5. Re-enter worktree

Derive `worktreeName` by replacing `/` with `-` in `worktreeBranch`. Call `EnterWorktree(name: "<worktreeName>")` directly. (No need to recurse into the `/worktree <branch>` flow — the state file was set to `active: false` in Step 4, so the Step 0 guard will pass.)

### 6. Notify

Report:

> 開発モードに戻りました。worktree `<worktreeBranch>` で作業を再開できます。

---

## Subcommand: `/worktree search <query>`

### 0. Verify state guard

Read `$TMPDIR/.claude-worktree-verify-state`. If the file exists, parse as JSON and check `active` field.

- `active: true` (or field missing for backward compatibility) → report "確認モード中です。`/worktree resume` または `/worktree exit` を実行してください" and stop.
- `active: false`, empty file, or file does not exist → proceed.

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

### 0. Verify state guard

Read `$TMPDIR/.claude-worktree-verify-state`. If the file exists, parse as JSON and check `active` field.

- `active: true` (or field missing for backward compatibility) → report "確認モード中です。`/worktree resume` または `/worktree exit` を実行してください" and stop.
- `active: false`, empty file, or file does not exist → proceed.

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
