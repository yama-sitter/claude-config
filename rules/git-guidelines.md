# Git Guidelines

## Prohibited Actions

- Do not add Claude co-author footers (`Co-Authored-By: Claude`, `Generated with Claude Code`)
- Avoid committing directly to `master`/`main` branches
- Do not include unstaged changes in commits

## Branch Naming

`<type>/<summary>`

- `<type>`: feature, fix, docs, style, refactor, test, chore
- `<summary>`: Concise description of the change in snake_case

Examples: `feature/user_profile_edit`, `fix/login_bug`

> **Worktree用**: EnterWorktree の name には `/` を使えないため、worktree名（ディレクトリ名）はハイフン形式 `feature-user_profile_edit` となる。
> ただし git ブランチ名はスラッシュ形式 `feature/user_profile_edit` が維持される（WorktreeCreate フックが一時ファイル経由で元のブランチ名を受け取る）。

## Commit Messages

```
<type>: <summary>

<detailed description>
```

- Write commit messages in Japanese
- One commit, one purpose
- If a commit has multiple intents, split using `git add -p`

## PR Title

`<type>: <short description>`

- Follow the project's `.github/PULL_REQUEST_TEMPLATE.md` if one exists

## Sandbox Restrictions

- NEVER execute `git rebase`, `git rebase --continue`, `git rebase --abort` via the Bash tool
  - Sandbox blocks dotfile creation, corrupting rebase state irrecoverably
  - ALWAYS ask the user to run with `!` prefix: `! git rebase <args>`
