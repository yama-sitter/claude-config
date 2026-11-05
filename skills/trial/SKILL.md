---
name: trial
description: |
  Test a proposal whose effect is uncertain by having fresh subagents run an example task under it, judge the actual outputs against criteria fixed beforehand, and adjust the proposal until it converges.
  Use when: the user types `/trial [proposal]`, or doubts a proposal (instruction wording, config, implementation) and wants it tried on an example and tuned from the results.
  Do not use when: the user wants an independent review of finished work, or wants a task simply delegated (-> sub).
user-invocable: true
args: "[proposal]"
---

# Trial — Test a Proposal with Subagents

Proposal: $ARGUMENTS

If a proposal is given, test it. If not, take the most recent proposal in the conversation. If neither yields one, ask what to test.

A proposal is testable only if a subagent can run a task under it. If it cannot (e.g. it changes this session's harness settings), say so and stop.

## Plan

Before any launch, write the plan in chat in Japanese:

- **Proposal**: the exact text or change under test.
- **Example task**: realistic, taken from the conversation or repo, one the proposal could plausibly make succeed or fail.
- **Criteria**: observable conditions on the actual output or file state. Fixed now; never change them in later rounds. Add a no-proposal control run only if a criterion needs the comparison.

Then launch without asking for confirmation (the worktree questions in Isolation are the only exception).

## Isolation

- Real files: read only. Never edit, create or delete them.
- Keep the working copy of the proposal in a temp directory outside the repo (`mktemp -d`). All adjustments go there.
- A trial that must write inside the repo runs in an `isolation: "worktree"` agent.
  - Before the first such launch, ask with AskUserQuestion (options: run it in a worktree / skip this trial). Launch only if they choose to run it.
  - When the loop ends, ask with AskUserQuestion (options: delete / keep) about the worktrees left behind. Only if they choose delete, run `git worktree remove --force <path>` and `git branch -D <branch>` for each. Otherwise leave them.
- Forbidden in every trial: git commit/push, `gh`, network writes, memory saves. If a trial needs one, report that trial as untestable.

## Trial brief

Launch a fresh `general-purpose` subagent each round via the Agent tool. Write the brief in English, terse.

Give:

- The proposal applied as the real thing (e.g. the instruction text itself as its brief, or the working copy with the change applied).
- The example task.
- Report format: result, then assumptions made, points where it was stuck, and information it lacked.
- Scope boundary: write only inside the given directory; no forbidden actions above.

Always give the report format and scope boundary, even when the proposal is itself a brief.

Do not give: the hypothesis, expected result, criteria, the fact that this is a test, or earlier rounds.

After launching, end the turn. Do not poll. Continue when the completion notification arrives.

## Judge

Judge each criterion yourself from the actual output and file state: read the files, run read-only commands. The subagent's self-report is a hint only, never evidence for a verdict. Record pass/fail per criterion with the evidence (excerpt or file state).

## Loop

- All criteria pass: converged.
- Otherwise: adjust the working copy of the proposal only (add missing information, remove what did not matter), then run the next round with a new subagent. Do not touch the criteria.
- Stop and return to the user when 3 rounds are done, or the same criterion failed 2 rounds in a row.

## Report

In Japanese:

- Converged, or stopped and why.
- Per round: criteria with pass/fail and evidence.
- Final proposal as a diff against the original, and the reason for each adjustment (shortage or excess).
- Worktrees kept, with path and branch, if any.

Do not apply anything to real files. The user decides whether to adopt the result.
