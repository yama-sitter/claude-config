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

This skill **prepares a work-ready worktree** (creation + dependency installation).
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
Do NOT skip this step even if a branch name was discussed earlier in the conversation. Always confirm with AskUserQuestion.

---

### 3. Verify .gitignore

Before creating any worktree, verify `.worktrees/` is ignored:

```bash
git check-ignore -q .worktrees
```

> **Important**:
> - You MUST use `git check-ignore`, not Grep on `.gitignore`. `git check-ignore` checks all ignore sources including global gitignore (`~/.gitignore_global`).
> - Run the command **exactly as written**. Do not append `; echo ...`, `2>/dev/null`, or any other suffix — it will cause a permission error.

If NOT ignored (exit code is non-zero):
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

Derive the worktree directory name from the branch name by replacing `/` with `_`:
- `feature/add_mcp_auth` → `feature_add_mcp_auth`
- `fix/login_bug` → `fix_login_bug`
- `test/worktree_check` → `test_worktree_check`

Use `--no-checkout` with pathspec negation to exclude `.claude/` from the working tree.
The sandbox blocks creation of the `.claude/` directory. Other dotfiles (`.gitignore`, `.env*`, `.prettierrc`, etc.) are **not** blocked and will be checked out normally.

> **Why not sparse-checkout?** The sandbox blocks both `.git/config` writes and `.git/worktrees/` writes. Pathspec negation is the only approach that avoids all `.git/` writes.

**Step 5a: Create worktree without checkout**

Run from the **project root** directory (not from inside a worktree or subdirectory):

```bash
git worktree add --no-checkout .worktrees/<worktree-name> -b <branch-name>

# Worktree Only (existing branch)
git worktree add --no-checkout .worktrees/<worktree-name> <branch-name>
```

**Step 5b: Checkout excluding `.claude/`**

```bash
cd .worktrees/<worktree-name> && git checkout HEAD -- . ':(exclude).claude' && git reset HEAD -- .
```

> **Known limitations**:
> - `.claude/` is excluded from checkout. It may appear in `git status` as missing from the working tree, but it will NOT be staged — so it cannot be accidentally committed.
> - All other dotfiles (`.gitignore`, `.env*`, `.prettierrc`, `.vscode/`, etc.) are checked out normally.
> - Branch deletion (`git branch -d` or `git worktree remove`) may show `could not write config file .git/config: Operation not permitted`. The branch IS deleted — this warning is harmless and can be ignored.

If the command fails:
- Branch already exists unexpectedly → drop the `-b` flag and retry from 5a (the failed `git worktree add -b` creates the branch even though the worktree creation failed)
- Worktree path conflicts → (1) `git worktree remove --force .worktrees/<worktree-name>`, then retry from 5a. (2) If fails with "not a working tree" (orphaned directory), ask the user to run `! rm -rf .worktrees/<worktree-name>`, then run `git worktree prune`. **NEVER delete `.git/worktrees/` entries directly — this corrupts git and breaks all commands.**
- Otherwise → report the error to the user

---

### 6. Setup & Completion

After the worktree is created, set up the development environment before reporting.

**Step 6a: Install dependencies**

Detect the package manager from lock files in the worktree root and install:

```bash
# Detect and install (run from worktree root)
if [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile
elif [ -f package-lock.json ]; then npm ci
elif [ -f yarn.lock ]; then yarn install --frozen-lockfile
elif [ -f go.sum ]; then go mod download
elif [ -f Gemfile.lock ]; then bundle install
fi
```

- If no lock file is found at the root, search one level deep: `find . -maxdepth 2 -name 'pnpm-lock.yaml' -o -name 'package-lock.json' -o -name 'yarn.lock'` (monorepo support)
- If no lock file is found at all, skip this step
- If installation fails, **report the error to the user and stop** — do not skip silently

**Step 6b: Check for untracked .env files in the source repo**

Some `.env` files (e.g., `.env`, `.env.local`) are gitignored and therefore not checked out with the worktree. Check if the source repo has any:

```bash
find <repo-root> -maxdepth 1 -name '.env*' -type f | while read f; do
  basename "$f"
done
```

Compare against the worktree. If any `.env*` files exist in the source repo but not in the worktree, generate a copy command and present it to the user:

```
以下の .env ファイルは git 管理外のため worktree にコピーされていません:
  .env, .env.local

コピーするには以下を実行してください:
  ! cp <repo-root>/.env <repo-root>/.env.local <worktree-path>/
```

> Note: `.env*` files are in the deny list (Read/Write/Edit) for security. Claude cannot read or copy them directly. The user must run the copy command themselves via `!`.

**Step 6c: Report**

- Branch name
- Worktree path (absolute)
- Dependency installation result (success / skipped / failed)
- Missing `.env` files and copy command (if applicable)

After reporting, **stop execution**. Do not:
- Modify files
- Run tests
- Automatically start implementation
