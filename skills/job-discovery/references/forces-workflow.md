# Forces Workflow

## Prerequisites

`{{STEP1_FACT_TABLES}}` and `{{STEP2_BACKGROUND_EVENTS}}` are replaced in the report file. Completion of the context subcommand is NOT required.

Forces analysis units (Hire/Re-hire) are independent of the phase definitions from facts Step 3. Refer to the phase definitions' Switch decision annotations to see which phases contain the Hire/Re-hire decisions.

## Owned Placeholders

`{{STEP4_PERCASE_FORCES}}`, `{{STEP4_CROSS_FORCES}}`, `{{STEP4_COMMON_NARRATIVE}}`

## Workflow

Analyze the Switch dynamics for each case individually, then compare across cases. This is the first step where **interpretation** (fact-grounded inference) is permitted.

Forces are about an individual person's decision dynamics — analyze each person's Switch story before looking for patterns.

### 4a. Per-case Forces diagrams

**Input from report**: appendix Fact Tables + Background/Events only. **Do NOT read Section 2 (common patterns)** to preserve case independence for per-case analysis.

Launch one subagent per case in parallel. Each subagent receives only its own case's Fact Table + Background, ensuring no cross-case anchoring. The subagent produces a Forces diagram + narrative.

**RQ Isolation Rule**: Per-case Forces subagents analyze Switch dynamics from Fact Tables and Background/Events. The report header contains ANALYSIS_FOCUS and FRAME_AWARENESS — these define the research question, NOT the expected force structure. Subagents must derive Forces from observed behaviors, not from the RQ's assumed demand drivers.

Per-case output:

> **Case [X] Hire時の力学**
> | 力 | 強さ | 内容 | 根拠 (F-XX) |
> Push（現状への不満・圧力）/ Pull（新しい選択肢の魅力）/ Anxiety（新しい選択肢への不安）/ Habit（現状維持の慣性） rows
> **ナラティブ**: [How Forces interacted for this person]
>
> **Case [X] Re-hire時の力学**
> | 力 | 強さ | 内容 | 根拠 (F-XX) |
> Push / Pull / Anxiety / Habit rows
> **ナラティブ**: [How Forces shifted from Hire to Re-hire. Note data constraints if thin.]

### 4a Review (main conversation)

Before proceeding to cross-case comparison, verify the per-case Forces:

1. **Category consistency**: Check whether the same Fact (F-XX) has been assigned to different Force categories across cases (e.g., F-A5 as Push in Case A, but a similar fact F-B3 as Pull in Case B). If found, resolve the categorization
2. **Strength justification**: Confirm that each strength rating (強/中/弱) is grounded in the three axes — scale of action, urgency of expression, and behavioral magnitude — not just impressionistic judgment
3. **Push/Pull separation**: Verify that Push items describe dissatisfaction with the _current state_, and Pull items describe attraction to _the new solution's promise_. Mixed items should be split or reclassified

If inconsistencies are found, revise the 4a outputs before proceeding.

**→ After review, replace `{{STEP4_PERCASE_FORCES}}` in the report file.**

### 4b. Cross-case comparison (main conversation, dialogue with user)

Compare 4a's per-case Forces across cases to identify common dynamics:

1. For each Force type (Push/Pull/Anxiety/Habit), place each case's Forces side by side
2. Identify Forces with the same direction observed in 2 or more cases → assign as Common Force with identifier (CF-Push1, CF-Pull1, etc.)
3. Record case-specific differences within each Common Force (same direction but different intensity or manifestation)
4. Forces observed in only 1 case → retain in 4a only; do not include in 4b Common dynamics

**Section 2 reference (use as reference, not ground truth)**: If Section 2 exists, read it and note how Purpose divergence manifests in Force dynamics. However:

- Section 2 patterns were derived from phases that may reflect RQ assumptions. Do NOT let Section 2's categorization override your independent reading of Forces from the Fact Tables
- If you observe Force patterns that suggest different purposes or dynamics than Section 2 presents, note them explicitly as "Section 2との乖離"
- If Section 2 is not yet available, proceed without it — this does not diminish the validity of your Forces analysis

Judge relative strength using three axes:

- Scale of action (immediate response vs. deliberation period)
- Urgency of expression (verbatim quotes indicating urgency or calm)
- Behavioral magnitude (how much the person changed their operations)

Output format:

> ### ケース横断比較 (4b)
>
> #### Hire時
>
> | CF-# | 力 | 共通の力学 | Case A の特徴 | Case B の特徴 |
> **最も強い力**: [Per case and overall]
>
> #### Re-hire時
>
> | CF-# | 力 | 共通の力学 | Case A の特徴 | Case B の特徴 |
> [Note data constraints.]
>
> #### 共通ナラティブ
>
> **Hire時の共通因果フロー**: [3ケースに共通するForceの相互作用と因果の流れを1段落で記述。各ケースの個別事情ではなく、共通する構造的因果を表現する]
>
> **Re-hire時の共通因果フロー**: [同上。Hire時からの変化の共通構造を含む]

**Cross-case table cell rules** (applies to all per-case columns):

- ALWAYS base cell text on the 4a output's「内容」column. Shorten only if meaning is preserved
- ALWAYS include Fact references (F-XX) in each case's cell
- NEVER add evaluative or interpretive words not present in the source facts (e.g., "信頼喪失", "効果なし")
- ALWAYS preserve quantitative information (amounts, counts, periods) when present in the original
- ALWAYS preserve contextual preconditions (e.g., "知人から聞いた上で" as decision background) — do not omit them for brevity

## Confirmation Gate

Before presenting for approval, verify: (a) each per-case cell includes at least one F-XX reference, (b) no evaluative words absent from the source facts have been introduced, (c) any quantitative information from the original is preserved.

Present for user approval. After approval, replace `{{STEP4_CROSS_FORCES}}` and `{{STEP4_COMMON_NARRATIVE}}` in the report file.

## Single-case Behavior

When only one case exists, skip 4b (cross-case comparison). Produce the per-case Forces diagram (4a) and narrative only. Common Forces (CF-\*) are not generated. Replace `{{STEP4_CROSS_FORCES}}` and `{{STEP4_COMMON_NARRATIVE}}` with a note indicating single-case analysis (e.g., "単一ケース分析のため、クロスケース比較は省略"). Proceed to the jobs subcommand with per-case Forces as the input.
