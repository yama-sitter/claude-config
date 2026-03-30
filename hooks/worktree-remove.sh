#!/bin/bash
# WorktreeRemove hook: force-remove worktree and delete branch
#
# stdin: JSON {"name": "<slug>", ...}
# Handles worktrees at external paths (~/Sources/<host>/<owner>/<repo>=<name>)
# and fallback paths (.claude/worktrees/<name>).

set -euo pipefail

INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r '.name // empty')
[ -z "$NAME" ] && exit 0

REPO_ROOT="${CLAUDE_PROJECT_DIR:-.}"

# --- Determine worktree path (same logic as worktree-create.sh) ---
REMOTE_URL=$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || echo "")
WORKTREE_PATH=""

if [ -n "$REMOTE_URL" ]; then
  URL="${REMOTE_URL%.git}"

  if [[ "$URL" =~ ^git@([^:]+):(.+)/([^/]+)$ ]]; then
    HOST="${BASH_REMATCH[1]}"
    OWNER="${BASH_REMATCH[2]}"
    REPO="${BASH_REMATCH[3]}"
  elif [[ "$URL" =~ ^(ssh|https?)://[^@]*@?([^/]+)/([^/]+)/([^/]+)$ ]]; then
    HOST="${BASH_REMATCH[2]}"
    OWNER="${BASH_REMATCH[3]}"
    REPO="${BASH_REMATCH[4]}"
  fi
fi

if [ -n "${HOST:-}" ] && [ -n "${OWNER:-}" ] && [ -n "${REPO:-}" ]; then
  WORKTREE_PATH="$HOME/Sources/${HOST}/${OWNER}/${REPO}=${NAME}"
else
  WORKTREE_PATH="$REPO_ROOT/.claude/worktrees/$NAME"
fi

# --- Resolve branch name from worktree ---
BRANCH=""
if [ -d "$WORKTREE_PATH" ]; then
  BRANCH=$(git -C "$WORKTREE_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
fi

# Fallback: use NAME with hyphens converted back to slashes (feature-foo → feature/foo)
if [ -z "$BRANCH" ]; then
  BRANCH=$(echo "$NAME" | sed 's/-/\//')
fi

# --- Remove worktree (force to handle untracked files like node_modules) ---
if git -C "$REPO_ROOT" worktree list --porcelain | grep -q "worktree $WORKTREE_PATH"; then
  if ! git -C "$REPO_ROOT" worktree remove --force "$WORKTREE_PATH" 2>&1; then
    echo "WARNING: git worktree remove --force failed for $WORKTREE_PATH" >&2
  fi
fi

# Clean up directory if still present
if [ -d "$WORKTREE_PATH" ]; then
  if ! rm -rf "$WORKTREE_PATH" 2>&1; then
    echo "WARNING: rm -rf failed for $WORKTREE_PATH" >&2
  fi
fi

# Always prune stale worktree metadata (directory may already be removed by ExitWorktree)
git -C "$REPO_ROOT" worktree prune 2>&1 || true

# --- Delete branch ---
if [ -n "$BRANCH" ] && [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
  if ! git -C "$REPO_ROOT" branch -D "$BRANCH" 2>&1; then
    echo "WARNING: branch -D failed for $BRANCH" >&2
  fi
fi

exit 0
