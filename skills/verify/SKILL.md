---
name: verify
description: |
  Verify implementation against plan acceptance criteria using an independent evaluator (subagent).
  Use when: Implementation is complete and you want to confirm all criteria pass.
  Invoke with `/verify` (searches for the plan automatically) or `/verify <path>` (explicit plan file).
  Do not use when: No plan exists, or implementation has not started.
user-invocable: true
args: "[plan-file-path]"
---

# Verify — Evaluate Implementation Against Plan Criteria

Run acceptance checks from the plan's Verification table. A subagent executes commands and evaluates
results, enforcing generator/evaluator separation (the evaluator has no knowledge of implementation context).

## Strict Rules

- NEVER modify source code, configuration, or plan files — this skill is read-only evaluation
- NEVER skip criteria — every row in the Verification table must be evaluated
- NEVER mark a criterion as PASS if the expected result does not match
- ALWAYS use a subagent for command execution and result evaluation (generator/evaluator separation)
- ALWAYS ask the user for Manual criteria — do not self-evaluate them

## Workflow

### Phase 1: Plan Discovery (main agent)

Locate the plan file and extract the Verification table.

**Search strategy:**

1. If a path argument was provided → use that path directly
2. If no argument → collect candidates from all sources:
   a. Conversation context (plan file path from Plan Mode or agent-memory save)
   b. `~/.claude/plans/` — scan recent `.md` files for a Verification table:
      ```bash
      ls -t ~/.claude/plans/*.md 2>/dev/null | head -10
      ```
   c. `~/.agent-memory/` — search for plan files with a Verification table:
      ```bash
      find ~/.agent-memory -name "plan.md" -newer ~/.agent-memory -mtime -30 | head -10
      ```
3. For each candidate, check if it contains a Verification table (look for `| # | Criterion` or `Criterion.*Command.*Expected` pattern)
4. If no candidates found → report 「検証対象のプランが見つかりません。`/verify <path>` でプランファイルを指定してください」 and stop
5. If exactly 1 candidate → present it for confirmation
6. If multiple candidates → present a numbered list with title + path for user selection

**→ Display the selected plan (title + file path) and extracted criteria. 「このプランの検証基準で確認を進めます。よろしいですか？」**

### Phase 2: Automated Checks (subagent)

Launch a `general-purpose` subagent via the Agent tool.
Embed the extracted criteria and working directory into the prompt template below.

**Subagent prompt:**

```
You are a verification agent. Evaluate implementation criteria independently and strictly.
Do not give the benefit of the doubt — judge based on observable evidence only.

## Working Directory
{cwd}

## Criteria to Verify
{criteria_table}

## Instructions

For each criterion in order:

### Automated criteria (Command is not "Manual")
1. Run the command exactly as specified
2. Capture stdout and stderr
3. Compare against Expected Result
4. Judge: PASS if output matches expected, FAIL if not
5. If command fails to execute (not found, permission denied), mark FAIL with the error

### Manual criteria (Command is "Manual")
Return with status "MANUAL" and note: "Requires user confirmation"

## Output Format

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | ... | PASS/FAIL/MANUAL | [output summary or note] |

## Details

For each criterion:
- Command: `[command]`
- Output: [full output or relevant excerpt]
- Expected: [expected result]
- Judgment: [PASS/FAIL reasoning]
```

### Phase 3: Manual Checks (main agent)

If no Manual criteria exist, skip this phase.

For each criterion the subagent returned as `MANUAL`:

1. Display the criterion and expected result to the user
2. **→ [Criterion]: [Expected result]. Pass or fail?**

### Phase 4: Verdict (main agent)

Combine subagent results and user manual judgments. Display the completed table and verdict.

**If any criteria failed:**

```
## Verification Report

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| ... | ... | ... | ... |

**Verdict: ❌ [N] of [total] criteria failed**

### Failed Criteria
- #[n]: [criterion] — [evidence summary]

### Next Steps
- [Specific guidance for each failed criterion]
```

**If all criteria passed:**

```
## Verification Report

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| ... | ... | ... | ... |

**Verdict: ✅ All [total] criteria passed**
```

## Completion

This skill is complete when:

- All automated criteria have been executed and judged by the subagent
- All manual criteria have been confirmed by the user (or none existed)
- The verdict has been displayed
