# Tree Guidelines

## When

Apply these rules when working inside a worktree (created by EnterWorktree, `/tree`, or `claude -w`).

## Pre-Work Checklist

Before starting any work inside a worktree, verify:

1. **Dependencies are installed** — `node_modules/`, `vendor/`, or equivalent must exist if the project has a lock file
2. **Required config files exist** — `.env*` files needed for tests must be present

If either check fails, **do not proceed with the task**. Report the issue and suggest setup commands.

## Prohibited Behaviors

- **Do not skip tests** due to missing dependencies or config files — this is a setup problem, not an expected state
- **Do not report "tests cannot run but OK"** — treat test failures from missing setup as blockers
- **Do not checkout worktree branches in the main repository** — always use EnterWorktree to work in a worktree
