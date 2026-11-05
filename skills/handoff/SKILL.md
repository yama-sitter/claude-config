---
name: handoff
description: |
  Write a self-contained prompt for handing a task to another Claude session, show it in chat, and copy it to the clipboard.
  Use when: the user types `/handoff [task]`, or asks for a prompt/instructions to give to another session.
  Do not use when: the user wants the task run now by a subagent (-> sub).
user-invocable: true
args: "[task]"
---

# Handoff — Prompt for Another Session

Task: $ARGUMENTS

If a task is given, build the prompt from it, adding conversation context only where the task depends on it. If not, build it from the preceding conversation. If neither yields a task, ask what to hand off.

## Prompt

The new session cannot see this conversation, but it can ask the user. Write the prompt in English, terse — every line must change what the new session does.

Always include:

- **Goal**: what to do and why.
- **Deliverable**: what counts as done.
- **Premises**: decisions made and options rejected in this conversation. Include only what the new session cannot learn from the repo; omit the section if none.
- **Environment**: repo root, current branch, and whether there are uncommitted changes (get them with `git rev-parse --show-toplevel`, `git branch --show-current`, `git status --short`). Omit if not in a git repo.
- One line allowing the new session to ask the user when something is unclear.

Include only when applicable:

- **Paths**: only files the new session cannot find by searching (outside the repo, or named only in the conversation).
- **Scope boundary**: only when the task writes or executes. State what must not be touched.

Rules:

- Expand every ID or symbol (e.g. U1, S-3, RQ3) into its body text. Never write "as discussed above".

## Output

1. Show the prompt in one fenced code block (use a longer fence if the prompt itself contains triple backticks).
2. Copy the same text to the clipboard with Bash: `pbcopy <<'HANDOFF_EOF'` … `HANDOFF_EOF`.
3. Add one line saying it was copied. If `pbcopy` fails, say so and leave the code block as the fallback.
