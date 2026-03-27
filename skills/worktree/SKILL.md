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

### Verify state detection

On every `/worktree` invocation, check if `~/.claude/.worktree-verify-state` exists.
If it does, read the file and warn:

> ⚠️ 確認モードが残っています（ブランチ: `<worktreeBranch>`）。
> `/worktree resume` で開発に戻るか、状態をクリーンアップしてください。

Then stop processing. Do NOT proceed with the requested subcommand (except `resume` and `exit`, which handle verify state).

---

## Subcommand: `/worktree <branch>`

### 0. Verify state guard

Check if `~/.claude/.worktree-verify-state` exists.
If it does, report "確認モード中です。先に `/worktree resume` または `/worktree exit` を実行してください" and stop.

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

After entering, verify setup:

1. Check dependencies: Run bash to find all lock files and check each has a sibling `node_modules/` directory
   ```bash
   find <worktree-root> -name node_modules -prune -o \( -name pnpm-lock.yaml -o -name package-lock.json -o -name yarn.lock -o -name bun.lockb -o -name bun.lock \) -print | while read f; do dir=$(dirname "$f"); [ -d "$dir/node_modules" ] || echo "MISSING: $dir/node_modules"; done
   ```
2. Check .env files: `Glob(pattern: "**/.env*", path: "<worktree-root>")` — check .env files present at all levels

If any directory is missing dependencies or .env files, report to the user.

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

### 0. Handle verify state

Check if `~/.claude/.worktree-verify-state` exists.

If it does:
1. Read the state file
2. Restore main branch: `git symbolic-ref HEAD 2>/dev/null` — if fails (detached HEAD), run `git checkout <mainBranch>`
3. Restore stash: if `stashed` is `true`, check `git stash list` first entry for `worktree-verify-auto-stash` — if match, `git stash pop`
4. Delete the state file
5. Continue to the normal exit flow (step 1 onward) — user will be asked keep/remove for the worktree

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

- Output is non-empty → run `git stash push -m "worktree-verify-auto-stash"` and set `stashed = true`
- Output is empty → set `stashed = false`

Note: untracked files are NOT stashed (default behavior). They don't affect checkout.

### 7. Checkout detached HEAD

```bash
git checkout <commitHash>
```

This puts the main working directory at the exact commit from the worktree branch, in detached HEAD state.

### 8. Save state file

Write to `~/.claude/.worktree-verify-state`:

```json
{
  "worktreePath": "<worktreePath>",
  "worktreeBranch": "<worktreeBranch>",
  "mainBranch": "<mainBranch>",
  "stashed": <true|false>,
  "commitHash": "<commitHash>"
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

Read `~/.claude/.worktree-verify-state`.
If the file does not exist, report "確認モードではありません" and stop.

### 2. Restore main branch

Check current HEAD state:

```bash
git symbolic-ref HEAD 2>/dev/null
```

- Command fails (detached HEAD) → run `git checkout <mainBranch>` to restore
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

### 4. Delete state file

Delete `~/.claude/.worktree-verify-state`.

### 5. Re-enter worktree

Use the `/worktree <branch>` flow with `worktreeBranch` from the state file.

The branch name is in slash format (e.g., `feature/foo`). The existing worktree detection logic matches both hyphen-form paths and slash-form branch refs, so the existing worktree will be found and entered.

### 6. Notify

Report:

> 開発モードに戻りました。worktree `<worktreeBranch>` で作業を再開できます。

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
