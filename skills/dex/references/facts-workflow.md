# Facts Workflow

## Prerequisites

Header placeholders (`{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`) are all replaced in the main report file.

## Owned Placeholders

`{{FACT_TABLES}}`, `{{BACKGROUND_EVENTS}}`

## Resume Logic

On start, check the appendix file for owned placeholders:

- Both (`{{FACT_TABLES}}`, `{{BACKGROUND_EVENTS}}`) present → start from Step 1
- Only `{{BACKGROUND_EVENTS}}` present → resume from Step 2 (Step 1 already completed)
- None present → all steps already completed; inform the user

## Workflow

### Step 1: Extract Facts

**Input from report**: header (case list) + source material paths.

**RQ (分析の焦点) is NOT a filter for fact extraction.** Extract ALL observable behaviors and verbatim quotes from the source material, regardless of whether they appear relevant to the RQ. Omitting facts because they seem "off-topic" destroys the data foundation for discovering demand structures the RQ did not anticipate.

List observable behaviors and verbatim quotes. Separate what happened from why it happened.

Output as a table:

| #   | 誰が | 何をした・何を言った（逐語） | 状況（いつ、どこで） |
| --- | ---- | ---------------------------- | -------------------- |
| A1  | ...  | ...                          | ...                  |

Identifier format: `{Case}{Number}` (e.g., A1, B1, C1). Case letter = case identifier from the case table.

**For lengthy source material** (requiring multiple Read calls):

1. Launch an extraction subagent to read the source and produce the fact table
2. Launch a review subagent to independently re-read the source and identify missing facts
3. Merge the results and perform self-review against the source before presenting

**For short source material** (single Read call):

1. Extract facts directly
2. Perform self-review by re-reading the source before presenting

### Step 1 Confirmation Gate

**Encoding check**: Before presenting, scan the extracted fact table for `�` (U+FFFD, Unicode Replacement Character).

- `�` is NOT a valid Japanese character. It never appears in normal text. If you see it, it is always a corruption artifact from PDF or other source file reading
- Do not copy `�` from source material as-is. It is your responsibility to detect and repair it before presenting
- Repair method: infer the correct character from surrounding context
  - Example: `方が��かったん` → `方が早かったん` (the subsequent text mentions speed)
  - Example: `応募���ロ` → `応募ゼロ` (katakana ゼ was corrupted)
  - Example: `ホーム��初導入` → `ホームで初導入` (particle で was corrupted)
- If inference is not possible, highlight the affected rows with `[要確認]` and ask the user to verify against the original source
- If using extraction subagents: apply the same check to the merged result, as subagents can propagate the same issue

Self-review against the source material for completeness, then present the table for user approval. After approval, replace `{{FACT_TABLES}}` in the appendix file.

---

### Step 2: Organize Facts and Identify Background

**Input from appendix**: Fact Tables.

Arrange facts from Step 1 chronologically. Separate **Background** (ongoing structural conditions not tied to a specific moment) from **Events** (facts tied to specific time points).

**Temporal origin test** for each Background candidate: "Did this condition exist **before** the Hire decision?"

- Yes → Background (e.g., "Zero applicants from Hello Work for months" = pre-Hire structural condition)
- No → Events (e.g., "Qualified workers are reliable" = post-Hire recognition)
- Uncertain → Apply: "Could a third party observe this condition before the person used the product?" Yes = Background, No = Events

Output format:

> **前提条件**（サービス利用を決める前から存在していた構造的条件）
> ファクト: A1, A3, ...
> 要約: [構造的条件 — 事業環境、継続的な制約、リソースの限界]
>
> **時系列の出来事**
>
> | 時期         | #   | 出来事                                   |
> | ------------ | --- | ---------------------------------------- |
> | [時期ラベル] | A1  | [ファクトテーブルの該当行から簡潔に要約] |
> |              | A2  | [要約]                                   |
> | [次の時期]   | A5  | [要約]                                   |
>
> - 1行に1ファクト（または連続するファクト範囲）を記載
> - 時期列は同一グループの先頭行のみ記載し、後続行は空欄とする
> - 出来事列はファクトテーブル（Step 1）の「何をした・何を言った」から簡潔に要約

For large fact sets (30+ facts): Launch a subagent, then self-review for completeness.

### Step 2 Confirmation Gate

**Encoding check**: Scan the organized Background/Events output for `�` (U+FFFD). This character is always a corruption artifact — never valid text. Fix any found using the same repair approach as Step 1.

Self-review two things, then present for user approval. After approval, replace `{{BACKGROUND_EVENTS}}` in the appendix file:

1. **Completeness**: Every Fact from Step 1 is placed in either Background or Events — none are missing
2. **Data sufficiency**: Sufficient data exists for the analysis focus (defined in brief). Report any areas where data is thin or missing relative to the focus direction

If data sufficiency issues are found, present the user with options: (a) return to data collection, (b) continue with the constraint noted, or (c) stop.
