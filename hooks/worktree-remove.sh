#!/bin/bash
# WorktreeRemove hook: force-remove worktree and delete branch
#
# stdin: JSON {"worktree_path": "<absolute path>", "hook_event_name": "WorktreeRemove", ...}

set -euo pipefail

INPUT=$(cat)
WORKTREE_PATH=$(echo "$INPUT" | jq -r '.worktree_path // empty')
[ -z "$WORKTREE_PATH" ] && exit 0

REPO_ROOT="${CLAUDE_PROJECT_DIR:-.}"

# --- Resolve branch name from worktree ---
BRANCH=""
if [ -d "$WORKTREE_PATH" ]; then
  BRANCH=$(git -C "$WORKTREE_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
fi

# Fallback: extract from git worktree list
if [ -z "$BRANCH" ]; then
  BRANCH=$(git -C "$REPO_ROOT" worktree list --porcelain \
    | awk -v wp="$WORKTREE_PATH" '/^worktree /{wt=$2} /^branch /{if(wt==wp){sub(/^refs\/heads\//,"",$2); print $2}}')
fi

# --- Remove worktree (force to handle untracked files like node_modules) ---
if git -C "$REPO_ROOT" worktree list --porcelain | grep -q "worktree $WORKTREE_PATH"; then
  git -C "$REPO_ROOT" worktree remove --force "$WORKTREE_PATH" 2>&1 || true
fi

# Clean up directory if still present
if [ -d "$WORKTREE_PATH" ]; then
  rm -rf "$WORKTREE_PATH" 2>&1 || true
fi

# Always prune stale worktree metadata
git -C "$REPO_ROOT" worktree prune 2>&1 || true

# --- Delete branch ---
if [ -n "$BRANCH" ] && [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
  git -C "$REPO_ROOT" branch -D "$BRANCH" 2>&1 || true
fi

exit 0
