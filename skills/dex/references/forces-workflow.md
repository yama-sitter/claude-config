# Forces Workflow

## Prerequisites

`{{FACT_TABLES}}` and `{{BACKGROUND_EVENTS}}` are replaced in the appendix file. Completion of the context subcommand is NOT required.

## Owned Placeholders

`{{PERCASE_FORCES}}`, `{{CROSS_FORCES_HIRE}}`, `{{CROSS_FORCES_REHIRE}}`

## Workflow

Analyze the Switch dynamics for each case individually, then compare across cases. This is the first step where **interpretation** (fact-grounded inference) is permitted.

Forces are about an individual person's decision dynamics — analyze each person's Switch story before looking for patterns.

### 4a. Per-case Forces diagrams

**Input from appendix**: Fact Tables + Background/Events only. **Do NOT read Section 1 (common situations)** to preserve case independence for per-case analysis.

Launch one subagent per case in parallel. Each subagent receives only its own case's Fact Table + Background from the appendix file, ensuring no cross-case anchoring. The subagent produces a Forces diagram + narrative.

**RQ Isolation Rule**: Per-case Forces subagents analyze Switch dynamics from Fact Tables and Background/Events. The main report header contains ANALYSIS_FOCUS and FRAME_AWARENESS — these define the research question, NOT the expected force structure. Subagents must derive Forces from observed behaviors, not from the RQ's assumed demand drivers.

**Output containment**: Subagent output must NOT include file paths, plan references, or any external file references. All output will be embedded directly into the appendix and must be self-contained.

**File-first output rule**: Each subagent writes its result to `_forces_tmp_<case-id>.md` (e.g., `_forces_tmp_A.md`) in the same directory as the report and returns only the file path to the parent. This keeps per-case output out of the main conversation context.

Per-case output:

> **Case [X] Hire時の力学**
> | 力 | 強さ | 内容 | 根拠 |
> Push（現状への不満・圧力）/ Pull（新しい選択肢の魅力）/ Anxiety（新しい選択肢への不安）/ Habit（現状維持の慣性） rows
> 根拠列はプレーンテキスト: `A2-A5`, `B7`
> **ナラティブ**: [How Forces interacted for this person]
>
> **Case [X] Re-hire時の力学**
> | 力 | 強さ | 内容 | 根拠 |
> Push / Pull / Anxiety / Habit rows
> **ナラティブ**: [How Forces shifted from Hire to Re-hire. Note data constraints if thin.]

### 4a Review (main conversation)

Read per-case outputs from temporary files (`_forces_tmp_<case-id>.md`). Before proceeding to cross-case comparison, verify the per-case Forces:

1. **Category consistency**: Check whether the same Fact (F-XX) has been assigned to different Force categories across cases (e.g., F-A5 as Push in Case A, but a similar fact F-B3 as Pull in Case B). If found, resolve the categorization
2. **Strength justification**: Confirm that each strength rating (強/中/弱) is grounded in the three axes — scale of action, urgency of expression, and behavioral magnitude — not just impressionistic judgment
3. **Push/Pull separation**: Verify that Push items describe dissatisfaction with the _current state_, and Pull items describe attraction to _the new solution's promise_. Mixed items should be split or reclassified

If inconsistencies are found, revise the 4a outputs before proceeding.

**→ After review, replace `{{PERCASE_FORCES}}` in the appendix file.**

### 4b. Cross-case comparison (main conversation, dialogue with user)

Compare 4a's per-case Forces across cases to identify common dynamics:

1. For each Force type (Push/Pull/Anxiety/Habit), place each case's Forces side by side
2. Identify Forces with the same direction observed in 2 or more cases → assign as Common Force with identifier (CF-Push1, CF-Pull1, etc.)
3. Record case-specific differences within each Common Force (same direction but different intensity or manifestation)
4. Forces observed in only 1 case → retain in 4a only; do not include in 4b Common dynamics

**Section 1 reference (use as reference, not ground truth)**: If Section 1 (共通の状況) exists, read it and note how H-S*/R-S* situations manifest in Force dynamics. However:

- Section 1 patterns were derived from observations that may reflect RQ assumptions. Do NOT let Section 1's categorization override your independent reading of Forces from the Fact Tables
- If you observe Force patterns that suggest different dynamics than Section 1 presents, note them explicitly as "Section 1との乖離"
- If Section 1 is not yet available, proceed without it — this does not diminish the validity of your Forces analysis

Judge relative strength using three axes:

- Scale of action (immediate response vs. deliberation period)
- Urgency of expression (verbatim quotes indicating urgency or calm)
- Behavioral magnitude (how much the person changed their operations)

Output format:

> #### Hire時
>
> | CF-# | 力 | 共通の力学 | Case A の特徴 | Case B の特徴 |
> | CF-Push1 | Push・強 | ... | ...(A2-A5) | ...(B4, B7) |
> **最も強い力**: [Per case and overall]
>
> #### Re-hire時
>
> | CF-# | 力 | 共通の力学 | Case A の特徴 | Case B の特徴 |
> [Note data constraints.]

## Confirmation Gate

Present for user approval. After approval:

1. Replace `{{CROSS_FORCES_HIRE}}` in the main report file with the Hire cross-case comparison (including the "最も強い力" summary)
2. Replace `{{CROSS_FORCES_REHIRE}}` in the main report file with the Re-hire cross-case comparison
3. Delete temporary files (`_forces_tmp_*.md`)

## Single-case Behavior

When only one case exists, skip 4b (cross-case comparison). Produce the per-case Forces diagram (4a) and narrative only. Common Forces (CF-\*) are not generated. Replace `{{CROSS_FORCES_HIRE}}` and `{{CROSS_FORCES_REHIRE}}` with a note indicating single-case analysis (e.g., "単一ケース分析のため、クロスケース比較は省略").
