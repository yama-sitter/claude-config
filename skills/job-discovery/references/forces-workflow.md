# Forces Workflow

## Prerequisites

`{{STEP1_FACT_TABLES}}` and `{{STEP2_BACKGROUND_EVENTS}}` are replaced in the report file. Completion of the context subcommand is NOT required.

## Owned Placeholders

`{{STEP4_PERCASE_FORCES}}`, `{{STEP4_CROSS_FORCES}}`, `{{STEP4_COMMON_NARRATIVE}}`

## Workflow

Analyze the Switch dynamics for each case individually, then compare across cases. This is the first step where **interpretation** (fact-grounded inference) is permitted.

Forces are about an individual person's decision dynamics — analyze each person's Switch story before looking for patterns.

### 4a. Per-case Forces diagrams

**Input from report**: appendix Fact Tables + Background/Events only. **Do NOT read Section 2 (common patterns)** to preserve case independence for per-case analysis.

Launch one subagent per case in parallel. Each subagent receives only its own case's Fact Table + Background, ensuring no cross-case anchoring. The subagent produces a Forces diagram + narrative.

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

**Section 2 reference**: If the context subcommand has been completed (Section 2 exists in report), read it and note how Purpose divergence identified there manifests as different Force dynamics in the common narrative. If Section 2 is not yet available, proceed without it.

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

## Confirmation Gate

Present for user approval. After approval, replace `{{STEP4_CROSS_FORCES}}` and `{{STEP4_COMMON_NARRATIVE}}` in the report file.

## Single-case Behavior

When only one case exists, skip 4b (cross-case comparison). Produce the per-case Forces diagram (4a) and narrative only. Common Forces (CF-\*) are not generated. Replace `{{STEP4_CROSS_FORCES}}` and `{{STEP4_COMMON_NARRATIVE}}` with a note indicating single-case analysis (e.g., "単一ケース分析のため、クロスケース比較は省略"). Proceed to the jobs subcommand with per-case Forces as the input.
