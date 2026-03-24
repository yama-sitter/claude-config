# Worktree Guidelines

## When

Apply these rules when working inside a git worktree (detected by `git rev-parse --is-inside-work-tree` returning true AND the working directory containing `.git` as a **file**, not a directory).

## Pre-Work Checklist

Before starting any work (code changes, tests, builds) inside a worktree, verify:

1. **Dependencies are installed** — `node_modules/`, `vendor/`, or equivalent must exist if the project has a lock file
2. **Required config files exist** — if the source repo has `.env*` files that are gitignored, they may be missing from the worktree

If either check fails, **do not proceed with the task**. Instead:
- For missing dependencies: run the appropriate install command (`npm ci`, `pnpm install --frozen-lockfile`, etc.)
- For missing `.env*` files: inform the user and provide a copy command with `!` prefix

## Prohibited Behaviors

- **Do not skip tests** due to missing dependencies or config files — this is a setup problem, not an expected state
- **Do not report "tests cannot run but OK"** — treat test failures from missing setup as blockers
- **Do not silently skip dependency installation** if it fails — report the error and stop
