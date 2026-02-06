---
allowed-tools: Bash(git checkout -b:*), Bash(git checkout:*), Bash(git switch:*), Bash(git status:*), Bash(git diff:*), Bash(git branch:*), Bash(git log:*), Read
description: "Create a new branch based on the changes."
---

# /branch

Create a new branch based on the changes.

> **Note**: If you want to create a worktree with `gwq`, use the worktree skill (automatically or by explicit request).
> This command creates a branch within the current repository using `git checkout -b`.

## Usage

- `/branch` - Create a new branch based on the current changes
- `/branch <description>` - Create a new branch based on the specified description
  - Example: `/branch Add user profile editing feature`

## Rules

Follow the [Git Guidelines](@../rules/git-guidelines.md).
