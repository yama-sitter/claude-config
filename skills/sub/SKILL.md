---
name: sub
description: |
  Delegate a task to a subagent: build a self-contained brief from the arguments (or the conversation so far) and launch it immediately.
  Use when: the user types `/sub [task]`, or asks to hand a task (investigation, large log/test output analysis, implementation) to a subagent.
  Do not use when: the task needs only a few tool calls, or the user wants to hand work to another session (-> handoff).
user-invocable: true
args: "[task]"
---

# Sub — Delegate to a Subagent

Task: $ARGUMENTS

If a task is given, build the brief from it, adding conversation context only where the task depends on it. If not, build it from the preceding conversation. If neither yields a task, ask what to delegate.

## Brief

The subagent cannot see this conversation and cannot ask the user. Write the brief in English, terse — every line must change what the subagent does.

Always include:

- **Goal**: what to do and why.
- **Deliverable**: what counts as done. Require a report of conclusion + evidence only, max 10 lines.
- **Premises**: decisions made and options rejected in this conversation. Include only what the subagent cannot learn from the repo; omit the section if none.

Include only when applicable:

- **Paths**: only files the subagent cannot find by searching (outside the repo, or named only in the conversation).
- **Scope boundary**: only when the task writes or executes. State what must not be touched.

Omit cwd/branch (inherited) and any restatement of what the repo already shows.

Rules:

- Expand every ID or symbol (e.g. U1, S-3, RQ3) into its body text. Never write "as discussed above".
- The subagent cannot ask about ambiguity: state the interpretation to use.

## Launch

Launch a `general-purpose` subagent via the Agent tool right away, without asking for confirmation. Reply with one line saying it was launched, then end the turn. Do not poll.

## Relay

When the completion notification arrives, relay the subagent's report to the user in Japanese as-is. Do not re-verify or re-derive its findings.
