# Jobs Workflow

## Prerequisites

Both the context and forces subcommands must be completed: `{{STEP3_COMMON_PATTERNS}}`, `{{STEP4_CROSS_FORCES}}`, and `{{STEP4_COMMON_NARRATIVE}}` are all replaced in the report file.

## Owned Placeholders

`{{STEP5_SUMMARY_INTRO}}`, `{{STEP5_JOB_HYPOTHESES}}`, `{{STEP5_RQ_CONTRAST}}`

## Workflow

Synthesize the common context (context subcommand) and Forces analysis (forces subcommand) into Job Statements. These are **hypotheses** — they require validation before acting on them. This step synthesizes only cross-case abstractions (P*-S*/P*-St* and CF-\*) into Job Statements. Different demand structures (e.g., different phases) may yield multiple Jobs.

**Input from report**:

- Section 2 (common patterns): Per-phase Situations (P*-S*) and Stances (P*-St*)
- Section 3 (cross-case Forces): Common Forces (CF-\*) + 共通ナラティブ
- Appendix Fact Tables (for hypothesis verification in 5d only — NOT for 根拠 column)

### Pre-enumeration: RQ Assumptions Audit

BEFORE enumerating candidates, read and record:

1. The Frame Awareness section (RQ's explicit assumptions about demand structure)
2. The "RQの前提との比較" table from facts Step 3's phase definitions

Write down the RQ's assumptions about phase structure, purpose, and dominant forces. Keep this list visible throughout 5a-5e. The goal: ensure candidates that DON'T match the RQ's assumptions receive equal consideration. Candidates that contradict the RQ are often the most valuable discoveries.

### 5a. Job candidate enumeration

List candidate Jobs using the following axes (in priority order):

1. **Phase split**: If cross-case Forces show different Dominant Forces for different phases, treat them as separate Job candidates by default
2. **Stance signals**: If Stance (P*-St*) patterns suggest an independent motivation structure not captured by Dominant Forces, add as a candidate
3. **Causal chain divergence**: If the causal chain shows that a common pattern within the same phase diverges at the case level into different Progress (desired outcomes), list each divergent path as a sub-slot. Example: If ROI evaluation leads some cases to "limited use as backup" and others to "structural integration into operations," these represent different Jobs despite sharing the same phase and Dominant Force

Output: numbered list of Job candidates with the source evidence (CF-_ Dominant Force, P_-S*/P*-St\* items).

List candidates from each axis independently. Do NOT merge candidates across axes at this stage — 5b handles consolidation. A single phase may yield multiple candidates if Axis 2 or Axis 3 identifies distinct motivation structures within it.

### 5b. Consolidation / separation decision

For each candidate pair, apply these criteria:

- **Separate** if Dominant Forces differ (even when the When clause overlaps — different motivation structures = different Jobs)
- **Merge** only when ALL three conditions hold: (1) same Dominant Force, (2) same motivation direction, AND (3) same Progress pathway (the desired outcome follows the same causal route). State the merge rationale AND explicitly note what analytical nuance is lost by merging.
- Even if (1) and (2) hold, if candidates were listed under different axes in 5a (e.g., one from Phase split, another from Stance signals), default to keeping them separate unless Progress is demonstrably identical.
- **Emerging label**: Jobs where the CF-\* cited in the 根拠 column is observed in fewer than half of the total cases receive the `[Emerging]` label and must include evidence strength (e.g., "2 of 5 cases")

If only one Job remains after consolidation, state why consolidation is justified.

Output: final Job list with separation/merge rationale.

Note: Job hypotheses are discussion material, not final answers. The goal of 5b is to preserve meaningful analytical distinctions, not to minimize candidate count. When in doubt, keep candidates separate — 5d (quality filter) will remove genuine redundancies.

### 5c. Multi-lens Job Statement generation

For each Job from 5b, generate candidate Job Statements through 3 analytical lenses (Belief Chain, Synthesis Model, Emotional/Social Job) to produce diverse hypotheses as discussion material.

See [step5-lenses.md](step5-lenses.md) for lens details and traceability rules.

### 5d. Quality filter

Test each candidate from 5c against Step 1 Fact Tables and apply the following filters. Drop or revise candidates that fail:

| Filter                   | Criterion                                                                                                                                                                         | Action              |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| **Facts contradiction**  | Contradicted by 2+ cases                                                                                                                                                          | Drop                |
| **Tautology**            | I want to / So that merely restates the When condition. Test: "Would someone unfamiliar with this data say 'I see, so THAT's the structure' upon hearing this?" If No → tautology | Drop                |
| **Redundancy**           | Central premise is identical to another candidate (wording differs only)                                                                                                          | Drop the weaker one |
| **Granularity mismatch** | When / I want to / So that mix JTBD-level (life transformation) with Micro-Job-level (operational task)                                                                           | Revise or Drop      |

Target: 2-3 candidates per Job slot after filtering.

### 5e. Candidate presentation

Present surviving candidates in the following format:

> ### ジョブ仮説候補
>
> #### 候補N: [短いラベル]
>
> Apply Anchor formatting from report-template.md: all identifier references use `[ID](#ID)`.
>
> | 句               | 内容                | 根拠          | 出典      |
> | ---------------- | ------------------- | ------------- | --------- |
> | **どんな時に**   | [situation]         | [P1-S1](#P1-S1), ...    | [A1](#A1), ... |
> | **何をしたいか** | [motivation]        | [CF-Push1](#CF-Push1), ... | [A2](#A2), ... |
> | **そうすれば**   | [expected progress] | [CF-Pull1](#CF-Pull1), ... | [B3](#B3), ... |
>
> **このモデルが説明できること**: [What this candidate explains that others don't] > **このモデルが説明できないこと**: [Blind spots / limitations] > **代表的な顧客の言葉**: [Verbatim quote that best embodies this candidate]
>
> この仮説の限界・前提: [Conditions, verification needs]
>
> _(Repeat for each surviving candidate.)_

### 5f. RQ Contrast Comparison

Compare what the RQ assumed about demand structure against what the analysis revealed.

**Input from report**: Frame Awareness section (from brief) + Phase definition's RQ comparison (from facts Step 3) + all Section 1-3 findings.

Output format:

> ### RQコントラスト
>
> | 観点         | RQが前提としていたこと | データが示したこと | 差分  |
> | ------------ | ---------------------- | ------------------ | ----- |
> | フェーズ構造 | [...]                  | [...]              | [...] |
> | 需要の構造   | [...]                  | [...]              | [...] |
> | 顧客の目的   | [...]                  | [...]              | [...] |
>
> **発見のハイライト**: [1-2 sentences summarizing the most significant delta — where the RQ's assumptions were most overturned by the data]

## Confirmation Gate

Present candidates and RQ contrast for user discussion. The user selects, combines, or modifies candidates to define the final Job Statement(s). After the user's decision, replace `{{STEP5_SUMMARY_INTRO}}` (1-2 sentence summary of results, e.g., number of job slots discovered, number of Emerging hypotheses), `{{STEP5_JOB_HYPOTHESES}}` (final Job Statements), and `{{STEP5_RQ_CONTRAST}}` (RQ contrast table) in the report file.

## Single-case Behavior

When CF-\* does not exist (single-case analysis), use per-case Forces (4a) as the basis for Job Statements. Traceability rules are relaxed: the 根拠 column may cite per-case Forces and single-case context patterns instead of CF-\* and P\*-S\*/P\*-St\*. Label all resulting Job Statements as `[Single-case — requires cross-case validation]`.
