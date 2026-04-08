---
name: git
description: |
  Git operations with guideline enforcement.
  Subcommands: branch, commit, push, pr, prune.
  Use for "commit", "push", "create PR", "create branch", "clean up branches", etc.
  Do not use for worktree operations — use the tree skill instead.
user-invocable: true
args: "[subcommand] [args]"
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git push:*), Bash(git rev-parse:*), Bash(git fetch:*), Bash(git worktree:*), Bash(gh pr create:*), Read, AskUserQuestion
---

# Git Skill

Git operations with automatic guideline enforcement.

Follow the [Git Guidelines](@../../rules/git-guidelines.md).

## Subcommands

| Command | Description |
| --- | --- |
| `/git branch [description]` | Create a new branch from a description |
| `/git commit` | Stage changes and create a commit |
| `/git push` | Push the current branch to remote |
| `/git pr` | Create a pull request |
| `/git prune` | Remove local branches deleted on remote |
| `/git` (no args) | Show this subcommand list |

## Prerequisites

- The current directory is within a Git repository

---

## Subcommand: `/git` (no args)

Display the subcommand table above and stop.

---

## Subcommand: `/git branch [description]`

Create a new branch following Git Guidelines naming conventions.

> **Note**: If you want to create a worktree, use the tree skill (`/tree`).
> This command creates a branch within the current repository using `git checkout -b`.

### 1. Get description

- If `description` argument is provided → use it directly
- If no argument → AskUserQuestion: "どのような作業を行いますか？作業内容を教えてください"

### 2. Generate branch name

Analyze the description and generate a branch name following Git Guidelines (`<type>/<summary>` format):

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

### 3. User approval

Use AskUserQuestion to present the recommended branch name + 1-2 alternatives:

- Option 1: Recommended name (with `(Recommended)` label)
- Option 2-3: Alternative names (different type or summary wording)
- Users can also select "Other" for free input

### 4. Create branch

```bash
git checkout -b <approved-branch-name>
```

---

## Subcommand: `/git commit`

Stage changes and create a commit following Git Guidelines.

### 1. Gather context

Run these commands in parallel:

```bash
git status
git diff HEAD
git branch --show-current
git log --oneline -10
```

### 2. Guard: secret files

Scan the changed files for secrets (`.env`, `.env.*`, `credentials.json`, `*.pem`, `*.key`, etc.).

- If found → warn the user and exclude them from staging
- If the user explicitly requests to include them → warn again but respect the decision

### 3. Analyze and group changes

Review the diff content and group changed files by purpose (one logical intent per group).

- If all changes are already staged and nothing is unstaged → use staged changes as-is, skip to Step 4
- If all changes share a single purpose → select all files for this commit
- If changes span multiple unrelated purposes:
  1. Identify each purpose and the files belonging to it
  2. Present the grouping to the user via AskUserQuestion:
     - Show each group with its purpose and file list
     - Ask which group to commit now (the rest remain unstaged for subsequent commits)
     - Example: "変更が複数の目的に分かれています。どのグループをコミットしますか？"
       - Option 1: "機能A: file1.ts, file2.ts"
       - Option 2: "リファクタリング: file3.ts"
       - Option 3: "すべて一括でコミット"
  3. If the user selects a group → proceed with only those files
  4. If a single file contains changes for multiple purposes → note this and suggest `! git add -p` for that file

### 4. Stage and commit

- Stage only the selected files with `git add <file>...` (never `git add -A` or `git add .`)
- Draft a commit message following Git Guidelines:
  - Format: `<type>: <summary>` (first line) + blank line + detailed description (body)
  - Language: Japanese
  - Do **NOT** add `Co-Authored-By` footer
  - The message must reflect only the staged changes, not all changes in the working tree
- Create the commit using a HEREDOC:

```bash
git commit -m "$(cat <<'EOF'
<type>: <summary>

<detailed description>
EOF
)"
```

---

## Subcommand: `/git push`

Push the current branch to the remote repository.

### 1. Gather context

Run these commands in parallel:

```bash
git branch --show-current
git status --short
```

### 2. Guard: uncommitted changes

If `git status --short` shows uncommitted changes (lines not starting with `??`):

- Warn: "未コミットの変更があります。先にコミットしてください"
- Stop

### 4. Check remote tracking

This command may fail — run it separately, not in parallel with other commands.

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "NO_UPSTREAM"
```

- Output is a remote ref → use `git push`
- Output is `NO_UPSTREAM` → use `git push -u origin <branch>`

### 5. Push

Execute the appropriate push command. Never use `--force` or `-f`.

---

## Subcommand: `/git pr`

Create a pull request with automatic template detection.

### 1. Get current branch

```bash
git branch --show-current
```

### 2. Guard: push status

Check whether an upstream tracking branch exists. This command may fail — do **not** run it in parallel with other commands.

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "NO_UPSTREAM"
```

- Output is `NO_UPSTREAM` → AskUserQuestion: "リモートにプッシュされていません。先にプッシュしますか？"
  - Yes → execute `/git push` flow, then continue
  - No → stop
- Output is a remote ref → check if local is ahead:
  ```bash
  git log @{u}..HEAD --oneline
  ```
  If unpushed commits exist → warn and ask to push first.

### 3. Detect base branch

```bash
git log --oneline --merges --first-parent -1 origin/main 2>/dev/null
```

Determine the base branch (typically `main` or `master`).

### 4. Analyze all commits

```bash
git log --oneline <base>...HEAD
git diff <base>...HEAD
```

Analyze **all** commits in the branch (not just the latest) to understand the full scope of changes.

### 5. Detect PR template

Search for a PR template in order:

1. `<repo-root>/.github/pull_request_template.md`
2. `<repo-root>/.github/PULL_REQUEST_TEMPLATE.md`
3. `<repo-root>/pull_request_template.md`
4. `<repo-root>/PULL_REQUEST_TEMPLATE.md`

Use the Read tool to check each path. If found, read the template content and use it as the PR body structure.

### 6. Draft PR

- **Title**: Follow Git Guidelines — `<type>: <short description>`
- **Body**:
  - If template found → fill in the template sections based on the commit analysis
  - If no template → create a body with:
    - `## Summary` — 1-3 bullet points
    - `## Test plan` — checklist of verification steps

### 7. Create PR

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<body content>
EOF
)"
```

Report the PR URL when complete.

---

## Subcommand: `/git prune`

Remove local branches that have been deleted on the remote.

### 1. Fetch and detect

```bash
git fetch --prune
git branch -vv
```

Parse the output to find branches marked as `[gone]`.

### 2. Handle no results

If no [gone] branches found → report "クリーンアップが必要なブランチはありません" and stop.

### 3. Detect associated worktrees

```bash
git worktree list
```

Check if any [gone] branch has an associated worktree.

### 4. Confirm with user

Present the list of branches to be deleted using AskUserQuestion:

- Show branch names and whether they have associated worktrees
- "以下のブランチを削除します。よろしいですか？"

### 5. Remove

For each confirmed branch:

1. If worktree exists → `git worktree remove --force <path>`
2. Delete branch → `git branch -D <branch>`

Report the results.

---

## Notes

- **Guideline enforcement**: This skill always loads Git Guidelines via the `@` reference. Every subcommand operates under these rules.
- **No force operations**: This skill never uses `--force` on push or destructive git operations.
- **Worktree operations**: Use the `/tree` skill for worktree management. `/git branch` only creates branches in the current repository.
