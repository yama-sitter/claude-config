---
name: kaizen
description: |
  Analyze Claude Code failures and design/implement structural, systemic improvements.
  Use when: The user notices unintended Claude Code behavior.
  Invoke with `/kaizen`. Identifies failures from conversation context and embeds preventive measures into the harness.
  Do not use when: Simple bug fixes or implementation tasks.
  Subcommands:
    - (default): Run the full process (analyze → ideas → confirm → implement → record)
    - `diagnose`: Analyze and present improvement ideas only. Does not implement
    - `apply`: Implement an improvement idea agreed upon in the conversation
    - `commit`: Commit kaizen changes to claude-config repository
user-invocable: true
---

# Kaizen — Derive Structural Improvements from Failures

Invoked when a failure is detected. A subagent performs analysis → idea generation → implementation end-to-end.

## Strict Rules

- NEVER output improvement ideas that depend on willpower, human attention, or effort (e.g., "be more careful", "check before executing", "read more carefully")
- NEVER skip the confirmation gate — user approval is required before implementation
- NEVER break the intent of existing settings, rules, or skills (additions, extensions, and deduplication merges only)
- ALWAYS show the before-state when editing settings.json
- ALWAYS save improvement records to agent-memory after implementation
- ALWAYS deduplicate: merge into existing rules instead of adding redundant new ones
- NEVER propose improvement ideas with ICE score below 700 — they are noise, not signal

## Argument Routing

| Args | Action |
|------|--------|
| (empty) | Full process: Phase 1 → Phase 2 → Confirmation Gate → Phase 3 → Record |
| `diagnose` | Analysis only: Phase 1 → Phase 2 → Confirmation Gate (stop. Guide user to `/kaizen apply`) |
| `apply` | Implementation only: Identify approved idea from conversation → Phase 3 → Record |
| `commit` | Commit to claude-config: Detect changes → Generate commit message → Commit (auto or manual fallback) |

## Workflow

### Phase 1: Failure Context Extraction (main agent) `(default, diagnose)`

Trace back the conversation context and extract a structured failure context.
Subagents cannot access parent conversation history, so this phase serves as a bridge.

Extract and display the following in the conversation:

```
[Failure Context]
Incident: [What happened — gap between expectation and reality]
Sequence: [How it unfolded]
User reaction: [What the user was dissatisfied with]
Related files: [File paths involved]
```

### Phase 2: Analysis + Idea Generation (subagent) `(default, diagnose)`

Launch a `general-purpose` subagent via the Agent tool.
Embed the Phase 1 context into the `{failure_context}` placeholder of the prompt template below.

**Subagent prompt:**

```
You are an agent that analyzes Claude Code failures and designs structural improvement ideas.

## Failure Context
{failure_context}

## Prerequisites (must complete before analysis)

1. Read `~/.claude/skills/kaizen/references/harness-catalog.md` to understand improvement target criteria, priorities, and templates
2. Read the current state of the following to verify consistency with existing settings:
   - `~/.claude/settings.json`
   - `~/.claude/CLAUDE.md`
   - Files under `~/.claude/rules/`
   - The project's CLAUDE.md (if it exists)

## Analysis Steps

### Step 1: Root Cause Analysis

Dig into the root cause from these 5 perspectives:
- Knowledge gap (required information was missing from the prompt)
- Process gap (workflow lacked checkpoints)
- Permission gap (dangerous operations were not blocked)
- Context loss (important information was lost between sessions)
- Implicit assumption (relied on unstated assumptions)

### Step 2: Target Selection Flow

Follow the flowchart in harness-catalog.md to determine the optimal improvement target:
1. Can this failure be deterministically blocked/verified? → Yes → hooks
2. Should the operation be physically prohibited? → Yes → permissions
3. Is process structuring (multi-step workflow) needed? → Yes → skills
4. Should it apply globally? → Yes → rules/ / Project-specific → CLAUDE.md

### Step 3: Generate Improvement Ideas

Generate at least 5 candidate ideas, then apply filters below. Present only surviving ideas.

Score each idea with ICE (Impact × Confidence × Ease, 1-10 each).

Filter conditions — exclude ideas that match:
- "Be more careful next time" (willpower-dependent)
- "Check before executing" (human attention-dependent)
- "Read more carefully" (effort-dependent)
- Score threshold — exclude ideas with ICE score < 700 (low-scoring ideas waste decision effort)

If no ideas survive filtering, skip Step 4 and output "No actionable improvement found" in the Recommendation section.

### Step 4: Recommend the Best Idea

Recommend the highest ICE-scored idea with rationale and concrete implementation plan.

## Output Format (return results in this format)

## Root Cause
[Summary of cause]
Category: [Knowledge gap / Process gap / Permission gap / Context loss / Implicit assumption]
Structural factor: [Why this failure is structurally likely to occur]

## Target Selection
[Results of each flowchart decision step]

## Improvement Ideas
| # | Idea | Target | I | C | E | Score | Pros | Cons |
|---|------|--------|---|---|---|-------|------|------|
※ ICE < 700 のアイデアは除外済み

## Recommendation
Recommended: #N [Idea name]
Rationale: ...
Implementation plan: ...
Side-effect risk: ...
```

### Confirmation Gate (main agent) `(default, diagnose)`

Present the subagent's analysis results to the user and obtain approval.

If the subagent reported "No actionable improvement found", display: **「有効な改善案が見つかりませんでした」** and stop (do not proceed to Phase 3).

Options to present:
- Implement the recommended idea as-is
- Choose a different idea (specify by number)
- Modify the approach

**For default:**
**→ Shall I implement this improvement? Specify a number if you'd like a different idea.**

**For diagnose:**
**→ Analysis complete. Run `/kaizen apply` to implement. Specify which idea (e.g., "#3") before running if you prefer a different one.**
(Stop here. Do not proceed to Phase 3)

### Approved Idea Identification (main agent) `(apply)`

When `/kaizen apply` is invoked, identify the approved improvement idea from conversation context:

1. User specified an idea number after `/kaizen diagnose` (e.g., "#2", "number 3") → adopt that idea
2. No number specified but explicit agreement with the recommendation → adopt the recommendation
3. No kaizen analysis in conversation (e.g., different session) → ask the user to specify the improvement directly

Embed the identified idea's details (target, implementation plan, side-effect risk) into the Phase 3 subagent prompt `{approved_plan}`.

### Phase 3: Implementation + Recording (subagent) `(default, apply)`

Launch a new `general-purpose` subagent to implement the approved idea.
Embed the approved idea details into the `{approved_plan}` placeholder of the prompt template below.

**Subagent prompt:**

```
You are an agent that implements improvements to the Claude Code harness.

## Approved Improvement
{approved_plan}

## Required Steps Before Implementation

1. Read the implementation template section of `~/.claude/skills/kaizen/references/harness-catalog.md` to understand the target-specific format
2. Read the current contents of the target file(s)
3. Include the before-state in your output (to make diffs clear)

## Implementation Rules by Target

### hooks (settings.json)
- Add entries to the `hooks` section of `~/.claude/settings.json`
- Use exit 2 for blocking (exit 1 is warning-only — the operation still executes)
- Include the entire before-state of the hooks section in output

### CLAUDE.md
- Add rules to global `~/.claude/CLAUDE.md` or project `CLAUDE.md`
- 5-principle checklist: ✓ Start with NEVER/ALWAYS ✓ Reason first ✓ Include examples ✓ One point per block ✓ Bullet points

### rules/
- Create/update rule files under `~/.claude/rules/`
- Follow the 5-principle checklist
- One topic per file

### skills
- Create/update `~/.claude/skills/<name>/SKILL.md`
- Frontmatter + workflow structure

### permissions (settings.json)
- Update `permissions.allow/deny/ask` in `settings.json`

## Bloat Prevention

- Check existing rules before implementation; merge instead of adding duplicates
- 1 rule = 1-2 sentences. Avoid verbose explanations

## Post-Implementation Record

After implementation, include the following in your output (main agent will save to agent-memory):

Improvement record:
- Incident: [Phase 1 incident]
- Root cause: [Phase 2 root cause]
- Applied improvement: [Summary of implemented improvement]
- Changed files: [List of changed file paths]
- Verification: [How to confirm this improvement is working]
```

### Record (main agent) `(default, apply)`

Save the improvement record output by Phase 3 subagent using the agent-memory skill.

- Scope: repository name (or `general` for global improvements)
- Directory: `<YYYY-MM-DD>_kaizen-<failure-summary>/`
- File: `improvement.md`

After saving, display: **`/kaizen commit` で claude-config にコミットできます**

### Commit to claude-config (main agent) `(commit)`

Commit kaizen changes to the claude-config repository.

**claude-config path**: `~/Sources/github.com/yama-sitter/claude-config`

**Steps:**

1. Detect changed files in claude-config:
   - Modified/deleted: `git -C <path> diff --name-only`
   - Untracked (new files): `git -C <path> ls-files --others --exclude-standard`
2. If no changes detected, display "コミット対象の変更がありません" and stop
3. Generate commit message:
   - If Phase 3 improvement record exists in conversation → generate from it
   - If no record in conversation → generate from diff output
   - Follow `rules/git-guidelines.md` conventions
4. Attempt automatic commit:
   - `git -C <path> add <changed files>`
   - `git -C <path> commit -m "<message>"`
5. If sandbox blocks the operation, present a `!` command for the user to execute:
   ```
   ! cd ~/Sources/github.com/yama-sitter/claude-config && git add <files> && git commit -m "$(cat <<'EOF'
   <message>
   EOF
   )"
   ```

## Completion

### default (full process)
- Failure identified and root cause structurally analyzed
- Improvement ideas presented (filtered by ICE ≥ 700)
- User approved one idea
- Approved improvement implemented
- Improvement record saved to agent-memory
- `/kaizen commit` の案内を表示済み

### diagnose
- Failure identified and root cause structurally analyzed
- Improvement ideas presented (filtered by ICE ≥ 700)
- `/kaizen apply` guidance displayed

### apply
- Approved improvement implemented
- Improvement record saved to agent-memory
- `/kaizen commit` の案内を表示済み

### commit
- Kaizen changes committed to claude-config (or `!` command presented for manual execution)
