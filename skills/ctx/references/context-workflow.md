# Context Workflow

## Prerequisites

`{{FACT_TABLES}}` and `{{BACKGROUND_EVENTS}}` are replaced in the appendix file. `{{PHASE_DEFINITIONS}}` is replaced in the main report file.

## Owned Placeholders

`{{COMMON_PATTERNS}}` (main report), `{{CASE_NARRATIVES}}` (appendix)

## Workflow

Extract common behavioral patterns across cases for each defined phase. This step uses two stages of subagents: Narrators (one per case, in parallel) and an Analyst-Critic (cross-case comparison + validation in a single pass).

**"Situation"** means the conditions in the person's business/life — NOT the product experience. A situation describes _what conditions existed_, not _what happened after using the product_ (unless that experience becomes observable context for a subsequent phase).

**Input from appendix**: Fact Tables + Background/Events. Subagents read from the appendix file (not from conversation context).
**Input from report**: Phase Definitions + Frame Awareness. Subagents read from the main report file.

### Step 3a: Narrator (launch one per case, in parallel)

**Input**: The case's Fact Table + Background/Events from the appendix file. Phase Definitions from the main report.

**Data source**: Pass the appendix file path and main report path to the subagent. The subagent reads its own case's data from the appendix and Phase Definitions from the report.

**RQ Isolation Rule**: The Narrator's task is to describe situations from raw data, not to validate the RQ. When instructing the Narrator subagent, emphasize that ANALYSIS_FOCUS and FRAME_AWARENESS in the main report header define the research question — they are NOT the expected findings. The Narrator must derive narratives from Fact Tables and Background/Events, not from the RQ's framing.

See [narrator-prompt.md](narrator-prompt.md) for the full Narrator prompt.

**Load control**: When the number of phases is 4 or more, use the pairing strategy described in the Narrator prompt (adjacent phases processed together per subagent call).

**Output**: One narrative per phase per case, with Fact citations. Output is written to a temporary file (`_narrator_tmp.md`) in the same directory as the report — NOT to the report or appendix.

**→ After all Narrators complete:**

1. Save per-case phase narratives to `_narrator_tmp.md` (consumed by Analyst-Critic)
2. **DO NOT write to the report or appendix yet.**

### Step 3b: Analyst-Critic (launch one)

**Input**: All Narrator outputs (from `_narrator_tmp.md`) + all Fact Tables + Background/Events (from appendix file). Also read the main report header for ANALYSIS_FOCUS, FRAME_AWARENESS, and PHASE_DEFINITIONS.

See [analyst-critic-prompt.md](analyst-critic-prompt.md) for the full Analyst-Critic prompt.

**Output**: Per-phase comparison tables + Purpose divergence summary + Validation report + Completeness gap report + Additional proposals. Output is written to a temporary file (`_analyst_tmp.md`) — NOT to the report or appendix.

**→ After the Analyst-Critic completes, DO NOT write to the report or appendix. The temporary file is consumed by the Integration step.**

### Step 3c: Integration (main conversation)

Integration output must be written to a temporary file (`_integration_tmp.md`) — NOT to the conversation.

#### 3c-i. Construction

Using the Analyst-Critic output (`_analyst_tmp.md`), construct the common pattern tables for each phase. Write the result to `_integration_tmp.md` in the same directory as the report.

For each validated common pattern from the Analyst-Critic:

1. Classify as **Situation** (objective condition observable by a third party) or **Stance** (the person's attitude/approach arising from a Situation)
2. Assign to the appropriate **Phase** (P1, P2, ...)
3. Assign an identifier: P{n}-S# (Situation) or P{n}-St# (Stance), where {n} is the phase number

Output format (repeat for each phase):

**フェーズ P{n}: {名称}**

| P{n}-S# | パターン | N社での現れ方          | 出典   |
| ------- | -------- | ---------------------- | ------ |
| P1-S1   | ...      | A: ..., B: ..., C: ... | A3, B7 |

| P{n}-St# | 構え | 由来する状況 | 出典   |
| -------- | ---- | ------------ | ------ |
| P1-St1   | ...  | P1-S1        | A6, B4 |

**Purpose テーブル** (at the end of each phase):

| ケース | Purpose | 出典 | 種別   |
| ------ | ------- | ---- | ------ |
| A      | ...     | A5   | 逐語   |
| B      | ...     | B3   | [推定] |

**Purpose divergence note** (if applicable): Describe how purposes diverge between cases at this phase.

**[Emerging] tag**: Patterns observed in fewer than 40% of total cases are tagged `[Emerging]` in the パターン column.

#### 3c-ii. Summary

Display only a count summary + representative pattern names in the conversation. Example:

```
P1: 状況 4件（P1-S1〜P1-S4）、構え 2件（P1-St1〜P1-St2）
P2: 状況 5件（P2-S1〜P2-S5）、構え 3件（P2-St1〜P2-St3）
P3: 状況 3件（P3-S1〜P3-S3）、構え 2件（P3-St1〜P3-St2）
→ ファイルで詳細を確認してください: <path>
```

## Confirmation Gate

Present the summary (from 3c-ii) for user approval. The user reviews full details in `_integration_tmp.md`.

Confirm: Are the Situation/Stance classifications appropriate? Is the Phase assignment correct? Is the abstraction level right? Are any common patterns missing?

After approval:

1. Replace `{{COMMON_PATTERNS}}` in the main report file with all phase pattern tables (from `_integration_tmp.md`)
2. Replace `{{CASE_NARRATIVES}}` in the appendix file with per-case phase narratives (from `_narrator_tmp.md`)
3. Delete temporary files (`_narrator_tmp.md`, `_analyst_tmp.md`, `_integration_tmp.md`)

## Single-case Behavior

When only one case exists, run Narrator + Analyst-Critic (validation only — skip cross-case comparison). Output a single-case pattern description per phase. Cross-case synthesis happens when additional cases are added.
