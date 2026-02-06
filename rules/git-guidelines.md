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
