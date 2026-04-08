# Git Guidelines

## Prohibited Actions

- Do not add Claude co-author footers (`Co-Authored-By: Claude`, `Generated with Claude Code`)
- Do not include unstaged changes in commits

## Branch Naming

`<type>/<summary>`

- `<type>`: feature, fix, docs, style, refactor, test, chore
- `<summary>`: Concise description of the change in snake_case

Examples: `feature/user_profile_edit`, `fix/login_bug`

> **Worktree**: EnterWorktree does not accept `/` in names, so the worktree directory uses hyphen form (e.g., `feature-user_profile_edit`).
> The git branch name preserves the original slash form (`feature/user_profile_edit`) via an override file passed to the WorktreeCreate hook.

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
