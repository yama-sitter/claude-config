# Facts Workflow

## Prerequisites

Header placeholders (`{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`) are all replaced in the report file.

## Owned Placeholders

`{{STEP1_FACT_TABLES}}`, `{{STEP2_BACKGROUND_EVENTS}}`

## Resume Logic

On start, check the report file for owned placeholders:

- Both `{{STEP1_FACT_TABLES}}` and `{{STEP2_BACKGROUND_EVENTS}}` present → start from Step 1
- Only `{{STEP2_BACKGROUND_EVENTS}}` present → resume from Step 2 (Step 1 already completed)
- Neither present → both steps already completed; inform the user

## Workflow

### Step 1: Extract Facts

**Input from report**: header (case list) + source material paths.

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

1. **網羅性**: Step 1の全ファクトが「前提条件」または「時系列の出来事」のいずれかに配置されていること
2. **データの充足性**: 分析の焦点（scope で定義）に対して十分なデータがあること。焦点の方向に対してデータが薄い・欠けている領域があれば報告する

If data sufficiency issues are found, present the user with options: (a) return to data collection, (b) continue with the constraint noted, or (c) stop.
