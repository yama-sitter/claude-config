# Context Workflow

## Prerequisites

`{{FACT_TABLES}}` and `{{BACKGROUND_EVENTS}}` are replaced in the appendix file.

## Owned Placeholders

`{{COMMON_CONTEXT_HIRE}}`, `{{COMMON_CONTEXT_REHIRE}}`

## Workflow

Extract common situations across cases for two timepoints: **Hire** (demand activation + solution selection) and **Re-hire** (conditions for continued use). This step uses two stages of subagents: Narrators (one per case, in parallel) and an Analyst-Critic (cross-case comparison + validation in a single pass).

**"Situation" in JTBD** means the conditions in the person's business/life — NOT the product experience. A situation describes _why demand arose_, not _what happened after using the product_.

**Input from appendix**: Fact Tables + Background/Events. Subagents read from the appendix file (not from conversation context).

### 3a. Narrator (launch one per case, in parallel)

**Input**: The case's Fact Table + Background/Events from the appendix file. **Data source**: Pass the appendix file path to the subagent. The subagent reads its own case's Fact Table and Background/Events from the appendix file.

**RQ Isolation Rule**: The Narrator's task is to describe situations from raw data, not to validate the RQ. When instructing the Narrator subagent, emphasize that ANALYSIS_FOCUS and FRAME_AWARENESS in the main report header define the research question — they are NOT the expected findings. The Narrator must derive narratives from Fact Tables and Background/Events, not from the RQ's framing.

See [narrator-prompt.md](narrator-prompt.md) for the full Narrator prompt.

**Output**: Two narratives per case (Hire / Re-hire), with Fact citations. Output is written to a temporary file (`_narrator_tmp.md`) in the same directory as the report — NOT to the report or appendix.

**→ After all Narrators complete, DO NOT write to the report or appendix. The temporary file is consumed by the Analyst-Critic.**

### 3b. Analyst-Critic (launch one)

**Input**: All Narrator outputs (from `_narrator_tmp.md`) + all Fact Tables + Background/Events (from appendix file). Also read the main report header for ANALYSIS_FOCUS and FRAME_AWARENESS.

See [analyst-critic-prompt.md](analyst-critic-prompt.md) for the full Analyst-Critic prompt.

**Output**: Comparison tables + Validation report + Completeness gap report + Additional proposals. Output is written to a temporary file (`_analyst_tmp.md`) — NOT to the report or appendix.

**→ After the Analyst-Critic completes, DO NOT write to the report or appendix. The temporary file is consumed by the Integration step.**

### 3c. Integration (main conversation)

Using the Analyst-Critic output (`_analyst_tmp.md`), construct the common situation tables for Hire and Re-hire.

For each validated common pattern from the Analyst-Critic:

1. Classify as **Situation** (objective condition observable by a third party) or **Stance** (the person's attitude/approach arising from a Situation)
2. Assign to **Hire** or **Re-hire**
3. Assign an identifier: H-S# / H-St# (Hire) or R-S# / R-St# (Re-hire)

Output format:

**Hire の状況:**

| H-S# | パターン | N社での現れ方          | 出典   |
| ---- | -------- | ---------------------- | ------ |
| H-S1 | ...      | A: ..., B: ..., C: ... | A3, B7 |

| H-St# | 構え | 由来する状況 | 出典   |
| ----- | ---- | ------------ | ------ |
| H-St1 | ...  | H-S1         | A6, B4 |

**Re-hire の状況:**

| R-S# | パターン | N社での現れ方          | 出典     |
| ---- | -------- | ---------------------- | -------- |
| R-S1 | ...      | A: ..., B: ..., C: ... | A12, B15 |

| R-St# | 構え | 由来する状況 | 出典     |
| ----- | ---- | ------------ | -------- |
| R-St1 | ...  | R-S1         | A14, B18 |

## Confirmation Gate

Present the Hire and Re-hire situation tables for user approval.

Confirm: Are the Situation/Stance classifications appropriate? Is the Hire/Re-hire assignment correct? Is the abstraction level right? Are any common situations missing?

After approval:

1. Replace `{{COMMON_CONTEXT_HIRE}}` in the main report file with the Hire situation tables
2. Replace `{{COMMON_CONTEXT_REHIRE}}` in the main report file with the Re-hire situation tables
3. Delete temporary files (`_narrator_tmp.md`, `_analyst_tmp.md`)

## Single-case Behavior

When only one case exists, run Narrator + Analyst-Critic (validation only — skip cross-case comparison). Output a single-case situation description for Hire and Re-hire. Cross-case synthesis happens when additional cases are added.
