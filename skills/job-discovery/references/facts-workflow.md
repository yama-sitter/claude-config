# Facts Workflow

## Prerequisites

Header placeholders (`{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`) are all replaced in the report file.

## Owned Placeholders

`{{STEP1_FACT_TABLES}}`, `{{STEP2_BACKGROUND_EVENTS}}`, `{{STEP2B_PHASE_DEFINITIONS}}`

## Resume Logic

On start, check the report file for owned placeholders:

- All three (`{{STEP1_FACT_TABLES}}`, `{{STEP2_BACKGROUND_EVENTS}}`, `{{STEP2B_PHASE_DEFINITIONS}}`) present → start from Step 1
- `{{STEP2_BACKGROUND_EVENTS}}` and `{{STEP2B_PHASE_DEFINITIONS}}` present → resume from Step 2 (Step 1 already completed)
- Only `{{STEP2B_PHASE_DEFINITIONS}}` present → resume from Step 3 (Steps 1-2 already completed)
- None present → all steps already completed; inform the user

## Workflow

### Step 1: Extract Facts

**Input from report**: header (case list) + source material paths.

**RQ (分析の焦点) is NOT a filter for fact extraction.** Extract ALL observable behaviors and verbatim quotes from the source material, regardless of whether they appear relevant to the RQ. Omitting facts because they seem "off-topic" destroys the data foundation for discovering demand structures the RQ did not anticipate.

List observable behaviors and verbatim quotes. Separate what happened from why it happened.

Output as a table:

| #   | 誰が | 何をした・何を言った（逐語） | 状況（いつ、どこで） |
| --- | ---- | ---------------------------- | -------------------- |

Identifier format: `F-{Case}{Number}` (e.g., F-A1, F-B1, F-C1). F = Fact, A/B/C = case identifier.

**For lengthy source material** (requiring multiple Read calls):

1. Launch an extraction subagent to read the source and produce the fact table
2. Launch a review subagent to independently re-read the source and identify missing facts
3. Merge the results and perform self-review against the source before presenting

**For short source material** (single Read call):

1. Extract facts directly
2. Perform self-review by re-reading the source before presenting

### Step 1 Confirmation Gate

Self-review against the source material for completeness, then present the table for user approval. After approval, replace `{{STEP1_FACT_TABLES}}` in the report file.

---

### Step 2: Organize Facts and Identify Background

**Input from report**: header + appendix Fact Tables.

Arrange facts from Step 1 chronologically. Separate **Background** (ongoing structural conditions not tied to a specific moment) from **Events** (facts tied to specific time points).

**Temporal origin test** for each Background candidate: "Did this condition exist **before** the Hire decision?"

- Yes → Background (e.g., "Zero applicants from Hello Work for months" = pre-Hire structural condition)
- No → Events (e.g., "Qualified workers are reliable" = post-Hire recognition)
- Uncertain → Apply: "Could a third party observe this condition before the person used the product?" Yes = Background, No = Events

Output format:

> **前提条件**（サービス利用を決める前から存在していた構造的条件）
> ファクト: [F-XX, ...]
> 要約: [構造的条件 — 事業環境、継続的な制約、リソースの限界]
>
> **時系列の出来事** > [F-XX in time order with brief period labels]

For large fact sets (30+ facts): Launch a subagent, then self-review for completeness.

### Step 2 Confirmation Gate

Self-review two things, then present for user approval. After approval, replace `{{STEP2_BACKGROUND_EVENTS}}` in the report file:

1. **Completeness**: Every Fact from Step 1 is placed in either Background or Events — none are missing
2. **Data sufficiency**: Sufficient data exists for the analysis focus (defined in scope). Report any areas where data is thin or missing relative to the focus direction

If data sufficiency issues are found, present the user with options: (a) return to data collection, (b) continue with the constraint noted, or (c) stop.

---

### Step 3: Define Phases from Data

**Input from report**: Step 2 output (Background + chronological Events) + Frame Awareness (from brief).

Using the chronologically organized facts from Step 2, identify natural phase boundaries in the customer journey. Phases are derived from the data, not assumed from the RQ.

Process:

1. Identify phase boundary signals across cases. Look for:
   - **Situational shifts**: Points where the customer's business environment structurally changed (e.g., adopted a new tool, staffing structure changed)
   - **Stance transitions**: Points where the customer's attitude or decision criteria shifted (e.g., skeptical → trusting, experimental → committed)
   - **Trigger events**: Specific events that prompted behavioral change (e.g., an existing approach definitively broke down)
2. Confirm that identified signals are observable across multiple cases, then define 2-4 phases (each representing a distinct situation-stance configuration)
3. For each phase, note whether it contains a Switch decision (Hire or Re-hire) — this maps to the forces subcommand's analysis units
4. Compare against Frame Awareness notes from brief: How does the RQ's assumed phase structure compare to the data-derived phase structure? Record the delta

**Data insufficiency fallback**: If timeline information is too sparse to identify clear phase boundaries (e.g., single case, shallow interviews), set provisional phases as "利用前 / 利用後" (2 phases) with the `[暫定]` label. Revise after context/forces analysis when more structure emerges.

**Phase revision**: If later analysis (context Narrator out-of-phase signals, Analyst-Critic phase boundary check) reveals that phase boundaries are incorrect, this step can be re-run. The `<!-- BEGIN/END -->` markers in the report support re-replacement.

Output format:

> **フェーズ定義**
>
> | # | フェーズ名 | 開始の目印（データ上の観察可能なシグナル） | 該当ファクト | Switch決定 |
>
> **RQの前提との比較**:
> - RQが暗黙に想定していたフェーズ構造: [...]
> - データから導出されたフェーズ構造: [...]
> - 差分: [...]

This determines the Narrator's narrative structure in the context subcommand (one narrative per phase).

### Step 3 Confirmation Gate

Present phase definitions for user approval. After approval, replace `{{STEP2B_PHASE_DEFINITIONS}}` in the report file.
