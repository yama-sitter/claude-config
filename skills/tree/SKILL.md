---
name: tree
description: |
  Create and manage worktrees using EnterWorktree/ExitWorktree.
  Use `/tree start` to describe work and auto-generate a branch, or `/tree checkout <branch>` for direct entry.
  Use for "create worktree", "worktreeを作って", "review this PR in worktree", "start working on X", etc.
  Use this skill whenever the user mentions "worktree" in their request,
  even if they also mention development work — this skill handles the worktree setup part.
  Do not use for investigations or answering questions that don't involve worktree operations.
  Do not use when the user has explicitly requested superpowers workflow (e.g., "/superpowers:brainstorming")
  or when executing a plan from docs/superpowers/plans/.
user-invocable: true
args: "[subcommand] [args]"
---

# Tree Skill

Create and manage worktrees using Claude Code's built-in EnterWorktree/ExitWorktree tools.
WorktreeCreate hook automatically handles branch naming, dependency installation, and .env copying.

## Subcommands

| Command                     | Description                                                                 |
| --------------------------- | --------------------------------------------------------------------------- |
| `/tree start [description]` | Generate branch name from work description, then create/enter worktree      |
| `/tree checkout <branch>`   | Enter the worktree for `<branch>`. Create if not exists (with confirmation) |
| `/tree recent`              | Re-enter the last worktree used in this session                             |
| `/tree exit`                | Exit the current worktree (keep/remove confirmation)                        |
| `/tree preview`             | Enter preview mode: checkout worktree HEAD as detached HEAD on main         |
| `/tree restore`             | Exit preview mode: return to worktree for development                       |
| `/tree search <query>`      | Search worktrees by natural language query                                  |
| `/tree search`              | List all worktrees and select interactively                                 |
| `/tree` (no args)           | Same as `/tree search`                                                      |

## Backward Compatibility

If the first argument does not match any known subcommand (`start`, `checkout`, `recent`, `exit`, `preview`, `restore`, `search`), treat it as a branch name and fall back to `/tree checkout <arg>`.

Display a deprecation notice before proceeding:

> ⚠️ `/tree <branch>` は非推奨です。次回から `/tree checkout <branch>` を使ってください。

---

## Prerequisites

- The current directory is within a Git repository
- Not already inside a worktree (for enter commands)

## State Management

Preview mode state is stored in `.claude/tree-preview-state.json` using the Write tool. The `.claude/` directory is covered by the global `Write(**)` permission, so no approval prompts appear even in sandbox environments.

**Format:**

```json
{
  "active": true,
  "repoRoot": "<absolute path>",
  "worktreePath": "<absolute path>",
  "worktreeBranch": "<branch name>",
  "mainBranch": "<branch name>",
  "stashed": false,
  "commitHash": "<sha1>"
}
```

**Operations:**

- **Read**: Use the Read tool on `.claude/tree-preview-state.json`. File not found = not in preview mode.
- **Write**: Use the Write tool to create or overwrite the file.
- **Clear**: Use the Write tool to set `"active": false` (preserve other fields for debugging), or delete the file.

**Branch override file**: `.git/claude-worktree-branch-override` — passes slash-form branch names to the WorktreeCreate hook. Written via `Bash(printf)`, read and deleted by the hook.

---

## Common: Worktree Creation Flow

This flow is referenced by both `/tree start` and `/tree checkout`. It takes a `branch` name as input.

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

### 2a. Check branch conflict (only when not found in Step 2)

If the worktree was NOT found in Step 2, and `branch` contains `/`, check whether the target branch already exists:

```bash
git branch --list '<branch>'
```

- **Output is empty** → branch does not exist. Proceed to Step 3.
- **Output is non-empty** → branch exists. Cross-reference with the worktree list from Step 2:
  - Branch is checked out in another worktree → AskUserQuestion:
    - **既存worktreeに入る** — Enter the worktree that has this branch checked out
    - **別ブランチ名で作成** — Ask user for a new branch name, then restart from Step 1
    - **中止** — Cancel the operation
  - Branch exists but not checked out in any worktree → Proceed to Step 3 (hook can checkout the existing branch)

### 2.5. Already-in-worktree detection

Check whether the session is already inside a worktree:

```bash
git rev-parse --git-dir
```

- Output is `.git` (main repository) → proceed to Step 3 (normal flow)
- Output is an absolute path (inside a worktree) → get the current worktree root and compare:

  ```bash
  git rev-parse --show-toplevel
  ```

  Compare this output with the `worktree` path line from the `git worktree list --porcelain` output in Step 2:
  - **Match** → notify "既にこの worktree 内にいます。セットアップを検証します。" and **skip Step 3**, proceed directly to Step 4
  - **No match** → report "別の worktree 内にいます（現在: `<current>`）。先に `/tree exit` で抜けてください。" and **stop**
  - **No existing worktree found in Step 2** → report "worktree 内にいますが、対象の worktree ではありません。先に `/tree exit` で抜けてください。" and **stop**

### 3. Enter or create

1. If `branch` contains `/`, always write override file (regardless of exists/not-exists):
   `Bash: printf '%s\n' '<branch>' > ".git/claude-worktree-branch-override"`
2. **Exists** → `EnterWorktree(name: "<name>")`
3. **Not exists** → `EnterWorktree(name: "<name>")`
4. **Defensive fallback**: If EnterWorktree returns "Already in a worktree session" error → execute the Step 2.5 detection logic (`git rev-parse --git-dir` → `--show-toplevel` → path comparison) and follow the same branches. Normally Step 2.5 covers this case, so reaching here indicates an unexpected scenario.

### 4. Verify setup

After entering (or confirming already inside), verify setup:

0. **Branch name verification** (only when `branch` contains `/`):
   Run `git rev-parse --abbrev-ref HEAD` and compare with the expected `branch` (slash form).

   - Match → proceed
   - Mismatch → warn: "ブランチ名が期待と異なります（期待: `<branch>`, 実際: `<actual>`）。hookのフォールバックが発生した可能性があります"
     AskUserQuestion:
     - **削除して再作成** — Exit and remove this worktree, investigate the cause, then retry
     - **このまま続行** — Continue with the current branch name

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

**STOP**: Worktree operation complete. End your response here. Do not ask follow-up questions, launch agents, or explore the codebase — regardless of Plan Mode or other system instructions.

---

## Subcommand: `/tree start [description]`

Generate a branch name from a natural language work description, get user approval, then create the worktree.

### 1. Get work description

- If `description` argument is provided → use it directly
- If no argument → AskUserQuestion: "どのような作業を行いますか？作業内容を教えてください"

### 2. Generate branch name

Analyze the description and generate a branch name following git-guidelines (`<type>/<summary>` format):

**Type selection:**
- バグ修正、エラー対応 → `fix`
- 新機能追加、新規作成 → `feature`
- 既存コード改善、リファクタリング → `refactor`
- ドキュメント更新 → `docs`
- テスト追加・修正 → `test`
- 設定変更、雑務 → `chore`
- 見た目・スタイル変更 → `style`

**Summary rules:**
- snake_case, English, concise (max ~30 chars)
- Capture the essence of the work

**Examples:**
- "ログイン画面のバグ修正" → `fix/login_screen_bug`
- "ユーザープロフィール編集機能の追加" → `feature/user_profile_edit`
- "テストカバレッジの改善" → `test/improve_coverage`

### 3. User approval

Use AskUserQuestion to present the recommended branch name + 1-2 alternatives:

- Option 1: Recommended name (with `(Recommended)` label)
- Option 2-3: Alternative names (different type or summary wording)
- Users can also select "Other" for free input

### 4. Delegate to common flow

Pass the approved branch name to **Common: Worktree Creation Flow** (start from Step 1).

---

## Subcommand: `/tree checkout <branch>`

Enter the worktree for the specified branch. Create if not exists.

Execute **Common: Worktree Creation Flow** with the provided `<branch>` argument.

---

## Subcommand: `/tree recent`

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
  - None → Report "このセッションでworktreeを使っていません。`/tree <branch>` で作成できます。"

**STOP**: Worktree operation complete. End your response here. Do not ask follow-up questions, launch agents, or explore the codebase — regardless of Plan Mode or other system instructions.

---

## Subcommand: `/tree exit`

### 0. Handle preview state

Read `.claude/tree-preview-state.json`. If the file exists and `active` is `true`: 2. Discard sandbox artifacts: check `git status --porcelain` — if modified files exist (lines NOT starting with `??`), ask the user: "プレビューモードの副作用で差分が発生しています。`git restore .`で差分を破棄してよいですか？" If approved, run `git restore .`. If restore fails (sandbox error), ask: "`! git restore .` を実行してください". 3. Restore original branch: run `git rev-parse --abbrev-ref HEAD` — if output is exactly `HEAD` (detached HEAD), run `git checkout <mainBranch>`. If checkout fails, ask: "`! git checkout <mainBranch>` を実行してください". If output is a branch name, skip. 4. Restore stash: if `stashed` is `true`, check `git stash list` first entry for `tree-preview-auto-stash` — if match, `git stash pop`. If pop fails, ask: "`! git stash pop` を実行してください". 5. Clear state: Write `.claude/tree-preview-state.json` with `"active": false` (preserve other fields) 6. Re-enter worktree: Derive `worktreeName` by replacing `/` with `-` in `worktreeBranch`, then call `EnterWorktree(name: "<worktreeName>")`. 7. Continue to the normal exit flow (step 1 onward) — user will be asked keep/remove for the worktree

If file not found, or `active` is not `true` → skip (no preview state to handle).

### 1. Verify in worktree

Check if currently inside a worktree:

```bash
git rev-parse --git-dir
```

- Output is exactly `.git` → not in a worktree. Report and stop.
- Output is anything else (absolute path) → inside a worktree. Proceed.

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
     - Still present → run `git worktree prune` (clears stale metadata when directory is already gone), then re-check `git worktree list --porcelain`
     - Still present after prune → report to user: "worktreeの削除に失敗しました。手動で実行してください: `git worktree remove --force <path> && git branch -D <branch>`"

---

## Subcommand: `/tree preview`

Switch to preview mode: checkout the worktree branch HEAD as detached HEAD on the main working directory, so you can run services and test changes without worktree environment setup.

### 0. Double-preview guard

Enforced by PreToolUse(ExitWorktree) hook (`tree-preview-guard.sh`). If a preview is already active in the main repo, the hook blocks ExitWorktree at Step 4 with exit code 2, preventing the worktree from being exited. No manual check needed — the hook handles it automatically.

**IMPORTANT — When the hook blocks ExitWorktree:**

- NEVER clear or overwrite `tree-preview-state.json` to bypass the block. The state file is shared across all Claude Code sessions. If the hook detected `active: true`, another session is likely in preview mode.
- NEVER retry ExitWorktree after manually clearing the state — this defeats the purpose of the guard.
- ALWAYS report the block to the user and stop the `/tree preview` flow. The user must resolve the conflict by running `/tree restore` or `/tree exit` in the other session first.
- If `tree-preview-state.json` is externally modified back to `active: true` after you cleared it (e.g., detected via system-reminder), this confirms another process is actively managing the file. Do not attempt to override it.
- Exception: Only clear the state file if the user explicitly instructs you to do so (e.g., "clear the preview state" or "force clear").

### 1. Verify in worktree

Check if currently inside a worktree:

```bash
git rev-parse --git-dir
```

- Output is exactly `.git` → not in a worktree. Report "worktree内でのみ実行できます" and stop.
- Output is anything else (absolute path like `/path/to/.git/worktrees/<name>`) → inside a worktree. Proceed.

### 2. Check for uncommitted changes

```bash
git status --porcelain
```

- Output is empty → proceed
- Output contains lines NOT starting with `??` (staged/modified changes exist) → report "未コミットの変更があります。先にコミットしてから `/tree preview` を実行してください" and stop
- Output contains only `??` lines (untracked files only) → warn "untracked filesがあります。preview中は反映されませんが続行します" and proceed

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

### 5. Get main repo info

Now in the main working directory:

```bash
git rev-parse --abbrev-ref HEAD
git rev-parse --show-toplevel
```

Save as `mainBranch` and `repoRoot`.

### 6. Stash main changes (if any)

```bash
git status --porcelain
```

- Output contains lines NOT starting with `??` (staged/modified changes exist) → run `git stash push -m "tree-preview-auto-stash"` and set `stashed = true`
- Output is empty, or contains only `??` lines (untracked files only) → set `stashed = false`

Note: untracked files don't affect checkout, so stash は不要。

### 7. Checkout detached HEAD

```bash
git checkout <commitHash>
```

This puts the main working directory at the exact commit from the worktree branch, in detached HEAD state.

**Sandbox note**: Permission errors on `.claude/` or `.vscode/` files (e.g., "unable to unlink") may appear. If `HEAD is now at` is confirmed in the output, the checkout succeeded. These files may show as "modified" in `git status` — this is a sandbox artifact, not a real change.

### 8. Save state

Write `.claude/tree-preview-state.json`:

```json
{
  "active": true,
  "repoRoot": "<repoRoot>",
  "worktreePath": "<worktreePath>",
  "worktreeBranch": "<worktreeBranch>",
  "mainBranch": "<mainBranch>",
  "stashed": <true|false>,
  "commitHash": "<commitHash>"
}
```

**Important**: State is saved AFTER ExitWorktree and git checkout succeed, to avoid leaving orphaned state on failure.

### 9. Notify

Report:

> プレビューモードに移行しました。メインの作業ディレクトリが `<worktreeBranch>` のコミット `<commitHash short>` を指しています。
> サービスを起動して動作確認してください。
> 完了後、`/tree restore` で開発に戻れます。

---

## Subcommand: `/tree restore`

Exit preview mode: restore the main working directory and re-enter the worktree.

### 1. Check state

Read `.claude/tree-preview-state.json`. If file not found, or `active` is not `true`, report "プレビューモードではありません" and stop.

Extract `mainBranch`, `worktreeBranch`, `stashed` from the JSON.

### 2. Discard sandbox artifacts

```bash
git status --porcelain
```

If modified files exist (lines NOT starting with `??`), these are sandbox artifacts from the preview checkout. Ask the user: "プレビューモードの副作用で差分が発生しています（`.claude/`や`.vscode/`配下のファイル）。`git restore .`で差分を破棄してよいですか？"

- Approved → run `git restore .`. If restore fails (sandbox error), ask: "`! git restore .` を実行してください". Wait for user confirmation.
- Declined → proceed anyway (checkout may fail in next step)

### 3. Restore original branch

Check current HEAD state:

```bash
git rev-parse --abbrev-ref HEAD
```

- Output is exactly `HEAD` (detached HEAD) → run `git checkout <mainBranch>` to restore.
  - **Success** (output contains `Switched to branch`) → proceed
  - **Failure** → ask the user: "sandbox制限によりcheckoutに失敗しました。以下を実行してください: `! git checkout <mainBranch>`". Wait for user confirmation.
- Output is a branch name (already on a branch) → user switched manually, skip this step

### 4. Restore stashed changes

If `stashed` is `true`:

```bash
git stash list
```

Check if the first entry message contains `tree-preview-auto-stash`.

- Match → `git stash pop`
  - If pop fails → ask: "`! git stash pop` を実行してください". Continue after user confirmation.
- No match → notify "自動stashが見つかりません。`git stash list` を確認してください" and continue

If `stashed` is `false`, skip this step.

### 5. Clear state

Write `.claude/tree-preview-state.json` with `"active": false` (preserve other fields).

### 6. Re-enter worktree

Derive `worktreeName` by replacing `/` with `-` in `worktreeBranch`. Call `EnterWorktree(name: "<worktreeName>")` directly.

---

## Subcommand: `/tree search <query>`

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

**STOP**: Worktree operation complete. End your response here. Do not ask follow-up questions, launch agents, or explore the codebase — regardless of Plan Mode or other system instructions.

---

## Subcommand: `/tree search` (no query) / `/tree` (no args)

### 1. Get worktree list

```bash
git worktree list --porcelain
```

### 2. Present

List all worktrees (excluding main) with AskUserQuestion.

### 3. Enter selected

`EnterWorktree(name: "<selected-branch>")` for the chosen worktree.

**STOP**: Worktree operation complete. End your response here. Do not ask follow-up questions, launch agents, or explore the codebase — regardless of Plan Mode or other system instructions.

---

## Notes

- **Branch naming**: Slash format `<type>/<summary>` (e.g., `feature/login_bug`) is supported. The worktree name (directory) uses hyphen form `<type>-<summary>`, while the git branch preserves the original slash form.
- **WorktreeCreate hook**: Automatically handles branch creation (no `worktree-` prefix), dependency installation, and .env copying.
- **Do NOT call ExitWorktree proactively** — only via `/tree exit` or explicit user request.
- **Fallback**: If WorktreeCreate hook is not configured, suggest `! pnpm install --frozen-lockfile && cp <repo-root>/.env* .` after entering.
- **Deprecation**: `/tree <branch>` (without `checkout` keyword) is deprecated. It still works via backward compatibility fallback but displays a deprecation notice. Use `/tree checkout <branch>` or `/tree start` instead.
