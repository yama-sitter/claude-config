---
name: insight-digestion
description: |
  Extract structural demand insights from customer behavior facts, interview logs, or feedback data.
  Use when the user provides raw customer data and wants to understand the underlying demand structure before designing solutions.
  Do not use when the user already has a clear hypothesis and wants to design experiments.
  Do not use when the user wants to brainstorm or evaluate solutions.
user-invocable: true
---

# Insight Digestion

Digest raw customer data into structural demand insights by climbing the Ladder of Inference one rung at a time.

## Prerequisites

- Customer interview logs, behavior data, or feedback are accessible
- This skill produces demand-side analysis only — output feeds into experiment design

## Workflow

### 0. Research Question Alignment

Clarify the research question and define the filter criteria for Step 3.

1. Confirm the user's research question (e.g., "Why do customers switch?", "What drives 2nd usage?")
2. Based on the question's nature, define:
   - **注目する瞬間**: Step 3で探すモーメントの種類
   - **探すべき行動シグナル**: Step 3で注目する具体的な行動の兆候
   - **RQの構成要素**: RQがデータを必要とする要素（例: 「初回利用前の状況」「期待と現実のギャップ」「2回目利用のトリガー状況」）

| 問いの種類           | 注目する瞬間         | 探すべき行動シグナル                                             |
| -------------------- | -------------------- | ---------------------------------------------------------------- |
| Switch / Acquisition | 行き詰まりの瞬間     | 回避策、諦め、乗り換え行動、満たされない期待                     |
| Retention / Loyalty  | 期待と現実のギャップ | ポジティブな驚き、習慣化した儀式、喜びの瞬間、高い期待の後の失望 |
| Churn / Cancellation | 離脱のきっかけ       | 蓄積する摩擦、裏切られた約束、競合への引力、最後の一押し         |

The table above is a reference. For questions that don't fit these types, define a custom moment label and detection signals collaboratively with the user.

**→ Self-review the alignment between research question and chosen signals, then present for user approval.**

### 1. Extract Facts

List observable behaviors and verbatim quotes. Separate what happened from why it happened.

Output as a table:

| #   | 誰が | 何をした・何を言った（逐語） | 状況（いつ、どこで） |
| --- | ---- | ---------------------------- | -------------------- |

**For lengthy source material** (requiring multiple Read calls):

1. Launch an extraction subagent to read the source and produce the fact table
2. Launch a review subagent to independently re-read the source and identify missing facts
3. Merge the results and perform self-review against the source before presenting

**For short source material** (single Read call):

1. Extract facts directly
2. Perform self-review by re-reading the source before presenting

**→ Self-review against the source material for completeness, then present the table for user approval.**

### 2. Organize Facts and Identify Background

Arrange facts from Step 1 chronologically. Separate **Background** (ongoing structural conditions not tied to a specific moment) from **Events** (facts tied to specific time points).

**Temporal origin test** for each Background candidate: "Did this condition exist **before** the Hire decision?"

- Yes → Background (e.g., "Zero applicants from Hello Work for months" = pre-Hire structural condition)
- No → Events (e.g., "Qualified workers are reliable" = post-Hire recognition)
- Uncertain → Apply: "Could a third party observe this condition before the person used the product?" Yes = Background, No = Events

Output format:

> **前提条件**（サービス利用を決める前から存在していた構造的条件）
> ファクト: [Fact numbers]
> 要約: [構造的条件 — 事業環境、継続的な制約、リソースの限界]
>
> **時系列の出来事** > [Fact numbers in time order with brief period labels]

For large fact sets (30+ facts): Launch a subagent, then self-review for completeness.

**→ Self-review two things, then present for user approval:**

1. **網羅性**: Step 1の全ファクトが「前提条件」または「時系列の出来事」のいずれかに配置されていること
2. **データの充足性**: RQの各構成要素（Step 0で定義）に具体的なデータがあること。データが薄い・欠けている構成要素があれば報告する

If data sufficiency issues are found, present the user with options: (a) return to data collection, (b) continue with the constraint noted, or (c) stop.

### 3. Extract Common Context

Extract the common **situation** across cases — the circumstances that created demand for the Hire decision. This step uses three specialized subagents.

**"Situation" in JTBD** means the conditions in the person's business/life — NOT the product experience. A situation describes _why demand arose_, not _what happened after using the product_.

#### 3a. Narrator (launch one per case, in parallel)

**Input**: The case's Fact Table (Step 1) + Background (Step 2)

**Prompt essence**:

> You are a JTBD researcher. From the Fact Table below, describe the **situation** this person was in when they decided to Hire a new solution.
>
> "Situation" means conditions in the person's business/life — NOT the product experience (what happened after using it).
>
> Write two narratives:
>
> 1. **Hire-time situation**: What situation was this person in when they first Hired?
> 2. **Re-hire situation**: What had changed by the time they used it again (or continued using it)?
>
> Each narrative must include:
>
> - **Background constraints**: Structural limitations of their business/environment
> - **Struggling moment**: When their current approach stopped working
> - **Why now**: Why they acted at this point (not earlier, not later)
>
> Rules:
>
> - Do NOT include product experience (what happened after using the product)
> - Cite Fact numbers for traceability
> - No inference of emotions or motivations not evidenced by quotes or observable behavior

**Output**: Two narratives per case (Hire-time + Re-hire), with Fact citations.

#### 3b. Comparator (launch one)

**Input**: All Narrator outputs + all Fact Tables

**Prompt essence**:

> You are a JTBD researcher. Compare the situation narratives across cases and extract common patterns.
>
> Steps:
>
> 1. Read all narratives. Discover **dimensions** for comparison (do NOT use a fixed list — derive dimensions from what the narratives contain)
> 2. For each dimension, describe each case's situation and write a tentative **common pattern**
> 3. Produce separate tables for Hire-time and Re-hire situations
>
> Common pattern rules:
>
> - Each pattern must be traceable to specific Facts in both cases
> - Do not over-abstract — "any business that needs staff" is too vague
> - Note where one case's fit is weaker than the other's
>
> **Second pass**: After completing the table, check for missed dimensions using these prompts:
>
> - Decision-making structure (who decided, with what authority?)
> - Information acquisition path (how did they learn about this solution?)
> - Task characteristics (what kind of work needs to be done?)
> - Geographic / physical constraints
> - Relationship with alternative / competing solutions
>
> Add any newly discovered dimensions to the table.

**Output**: Cross-case comparison table: `| Dimension | Case A | Case B | Common pattern (tentative) | Notes |`

#### 3c. Critic (launch one)

**Input**: Comparator output + original Fact Tables (NOT the Narrator outputs) + JTBD theoretical frame

**Prompt essence**:

> You are a critical reviewer with deep JTBD expertise. Validate the Comparator's common patterns.
>
> **IMPORTANT: Do NOT take the Comparator's output at face value.** Go back to the original Fact Tables independently and form your own view before reviewing.
>
> Apply three types of critique:
>
> 1. **Conceptual accuracy**: Is each pattern a description of a _situation_ (conditions the person was in), or is it actually a _fact/event_ (something that happened) or _product experience_ (what happened after using the product)?
>    - NG: "Filled in 5 minutes" → product experience, not a situation
>    - OK: "Traditional recruitment channels produced zero applicants for months" → situation
> 2. **Theoretical consistency**: Does each pattern describe a condition that _created demand_ for a new solution? Or is it merely a characteristic of the business that doesn't drive the Hire decision?
> 3. **Category assignment**: Classify each pattern as:
>    - **A (Situation)**: Objective conditions observable by a third party before the Hire decision
>    - **B (Stance)**: The person's attitude/approach arising FROM a situation in category A. Always note which A-item it derives from
>    - **C (Post-experience change)**: Recognition shifts that occurred AFTER using the product. Not a Hire-time situation
>    - Test: "Could a third party observe this before the Hire?" → Yes = A, No = B or C
> 4. **Redundancy**: Are any patterns listed independently that are actually sub-dimensions of another? Recommend merging or subordinating.
> 5. **Temporal placement**: Are any Hire-time patterns that were actually recognized only after using the product? Apply: "Did this condition exist before the Hire decision?"
> 6. **Evidence strength**: Is each case's evidence based on recorded behavior/quotes, or merely a stated attitude? Flag weak evidence in Discrepancies.
> 7. **Pattern nature**: Is each entry a "common pattern" (shared across cases) or a "difference description" (contrasting cases)? Differences belong in Discrepancies, not as standalone patterns.
>
> Additionally: identify any common patterns the Comparator missed, based on your independent reading of the Facts.
>
> Output: For each pattern → Approve / Revise (with suggestion) / Reject (with reason) + A/B/C classification.
> Do NOT write the final version yourself — provide critique and suggestions only.

**Output**: Validation report with verdicts, classification, and additional proposals.

#### 3d. Integration (main conversation)

1. Reflect the Critic's feedback: apply revisions, remove rejected patterns, add proposed patterns
2. Apply A/B/C classification
3. Compose the final table and present to the user

**Final output format**:

> ### A. 初回利用時の状況（「いつ」「どんな時に」の材料）
>
> | # | 共通コンテキスト | Case A 根拠 | Case B 根拠 | ケース間の差異 |
>
> ### B. 状況から生じた態度・構え（動機分析の材料）
>
> | # | 態度・構え | 由来する状況 (A#) | Case A 根拠 | Case B 根拠 |
>
> ### C. 利用後に起きた認識の変化（継続利用分析の材料）
>
> | # | 変化 | Case A | Case B |

**→ Present the final table for user approval. Confirm: Are the A/B/C classifications appropriate? Is the abstraction level right? Are any common contexts missing?**

**Single-case behavior**: When only one case exists, skip the Comparator. Run Narrator + Critic only, and output a single-case context description. Cross-case synthesis happens when additional cases are added.

<!-- Future consideration: Steps 3 and 4 follow different abstraction paths — Step 3 abstracts situations first (bottom-up → common), while Step 4 analyzes dynamics individually then compares (individual → compare). Theoretically, individual Forces analysis could reveal common situations (Step 4 → Step 3 order). Re-evaluate ordering as case count grows. -->

### 4. Analyze Demand Forces

Analyze the Switch dynamics for each case individually, then compare across cases. This is the first step where **interpretation** (fact-grounded inference) is permitted.

Forces are about an individual person's decision dynamics — analyze each person's Switch story before looking for patterns.

**Input**:

- Per case: Fact Table (Step 1) + Background (Step 2)
- For comparison: Step 3 common contexts (A/B/C) — used as comparison axes, not as the analysis target

**Steps**:

1. **Per-case Forces diagrams (4a)**: For each case, map the person's Hire decision onto Push/Pull/Anxiety/Habit using their Fact Table. Write a short narrative per case describing how the Forces interacted for this person's Switch.

   **Process**: Launch one subagent per case in parallel. Each subagent receives only its own case's Fact Table + Background, ensuring no cross-case anchoring. The subagent produces a Forces diagram + narrative.

   Per-case output:

   > **Case [X] 初回利用の力学**
   > | 力 | 内容 | 根拠 (Fact#) | 強さ |
   > Push（現状への不満・圧力）/ Pull（新しい選択肢の魅力）/ Anxiety（新しい選択肢への不安）/ Habit（現状維持の慣性） rows
   > **ナラティブ**: [How Forces interacted for this person]
   >
   > **Case [X] 継続利用の力学**
   > | 力 | 内容 | 根拠 (Fact#) | 強さ |
   > Push / Pull / Anxiety / Habit rows
   > **ナラティブ**: [How Forces shifted from Hire to Re-hire. Note data constraints if thin.]

2. **Cross-case comparison (4b)**: Execute in the main conversation (dialogue with user). Place per-case Forces side by side.

   First, reconcile 4a's Force classifications with Step 3's A/B/C categories:

   - For each Fact# cited in 4a, check whether it appears in Step 3's A/B/C tables
   - If the Force classification (Push/Pull/Anxiety/Habit) conflicts with the Step 3 category (A=situation, B=stance), flag it
   - Resolve mismatches by returning to the original Fact in Step 1, and record the resolution
   - Proceed to comparison analysis only after reconciliation is complete

   Then, use Step 3's common contexts (A/B) as comparison axes to identify:

   - **Common Forces dynamics**: Where both cases show the same Force pattern
   - **Divergent dynamics**: Where the same common context produced different Force behaviors

   Judge relative strength using three axes:

   - Scale of action (immediate response vs. deliberation period)
   - Urgency of expression (verbatim quotes indicating urgency or calm)
   - Behavioral magnitude (how much the person changed their operations)

**Output format**:

> ### ケースごとの力学 (4a)
>
> [Case A: 初回利用の力学 + ナラティブ + 継続利用の力学 + ナラティブ] > [Case B: 同上]
>
> ### ケース横断比較 (4b)
>
> _Note: Classification reconciliation（分類の照合）は内部処理として実施し、ユーザーには統合結果のみ提示する_
>
> #### 初回利用
>
> | 力 | 共通の力学 | Case A の特徴 | Case B の特徴 |
> **最も強い力**: [Per case and overall]
>
> #### 継続利用
>
> | 力 | 共通の力学 | Case A の特徴 | Case B の特徴 |
> [Note data constraints.]

**→ Present for user approval.**

### 5. Define Jobs (Hypotheses)

Synthesize the common context (Step 3) and Forces analysis (Step 4) into Job Statements. These are **hypotheses** — they require validation before acting on them. Step 4 may reveal multiple distinct demand structures; this step preserves that diversity.

**Input**:

- Step 4b Cross-case comparison: Dominant Force per phase (Hire-time / Re-hire)
- Step 4a Per-case Forces: case-specific strong Push/Pull forces
- Step 3 A (When clause material), B (Stance), C (Post-experience)
- Step 1 Facts (for evidence verification)

#### 5a. Job candidate enumeration

List candidate Jobs using the following axes (in priority order):

1. **Hire-time vs Re-hire split**: If Step 4b shows different Dominant Forces for Hire-time and Re-hire, treat them as separate Job candidates by default
2. **Case-specific strong Forces**: A Push/Pull force appearing strongly in only 1-2 cases is an Emerging Job candidate — list it separately
3. **Step 3 B/C signals**: If Stance (B) or Post-experience (C) patterns suggest an independent motivation structure not captured by Dominant Forces, add as a candidate

Output: numbered list of Job candidates with the source evidence (Step 4b Dominant Force line, specific Fact#s, Step 3 item#s).

#### 5b. Consolidation / separation decision

For each candidate pair, apply these criteria:

- **Separate** if Dominant Forces differ (even when the When clause overlaps — different motivation structures = different Jobs)
- **Merge** if candidates share both Dominant Force and motivation direction — state the merge rationale explicitly
- **Emerging label**: Jobs supported by only 1-2 cases receive the `[Emerging]` label and must include evidence strength (e.g., "1 case, 2 Facts")

If only one Job remains after consolidation, state why consolidation is justified.

Output: final Job list with separation/merge rationale.

#### 5c. Job Statements

For each Job from 5b, construct a statement:

1. **When clause**: Integrate Step 3 A common contexts into 1-2 sentences describing the shared situation
2. **Motivation (I want to)**: Derive from Step 4's Push/Pull integrated narrative. Push inversion = what they want to escape. Pull direction = what they want to achieve.
3. **Expected progress (so that)**: Derive from Step 4's narrative + Fact-based goal statements
4. **Traceability**: Document which Facts, Step 3 items, and Step 4 Forces inform each clause
5. **Hypothesis constraints**: State explicitly that this Job is a hypothesis. List conditions for validity and what needs verification.

**Output format**:

> ### ジョブ仮説
>
> #### ジョブ1: [短いラベル]
>
> > **When（どんな時に）** [situation],
> > **I want to（～したい）** [motivation],
> > **so that（そうすれば）** [expected progress].
>
> | 句        | 根拠                     |
> | --------- | ------------------------ |
> | When      | Step 3 A#, A#, ...       |
> | I want to | Step 4 Push/Pull + Facts |
> | So that   | Step 4 narrative + Facts |
>
> この仮説の限界・前提: [Conditions, verification needs]
>
> #### ジョブ2: [短いラベル] `[萌芽的]`
>
> > **When（どんな時に）** [situation],
> > **I want to（～したい）** [motivation],
> > **so that（そうすれば）** [expected progress].
>
> | 句        | 根拠                     |
> | --------- | ------------------------ |
> | When      | Step 3 A#, A#, ...       |
> | I want to | Step 4 Push/Pull + Facts |
> | So that   | Step 4 narrative + Facts |
>
> この仮説の限界・前提: [Conditions, verification needs]
> エビデンスの強さ: [N cases, M Facts]
>
> _(Repeat for additional Jobs. Omit Job 2 block if only one Job exists.)_

**→ Present for user approval. Verify that each clause has factual grounding and appropriate abstraction level.**

### 6. Answer RQ + Findings

Synthesize Steps 3-5 into a structured answer to the Research Question and present analysis findings.

**Input**: Step 3 (A/B/C) + Step 4 (Forces) + Step 5 (Jobs) + Step 0 (RQ)

**Process**: Execute directly in the main conversation (all Step outputs are already in the conversation context).

**Output**:

> ### RQ回答
>
> **RQ**: [from Step 0] > **回答**: [1 paragraph integrating the factual causal chain (Step 3), Force dynamics (Step 4), and Job hypotheses (Step 5)]
>
> ### 仮説との照合
>
> - 一致した点: [...]
> - ずれた点: [...]
> - 予想外の発見: [...]
>
> ### ケース間の違い
>
> [Case-specific dynamics not explained by common patterns]
>
> ### 未解決の問い
>
> - [List of questions for further investigation]
>
> ### 次のアクションへの入力
>
> - 検証すべきジョブ仮説: [from Step 5]
> - 推奨する検証アプローチ: [...]

**→ Present for user approval. Determine whether analysis is complete or additional investigation is needed.**

## Output Language Rules

- ユーザーに見せる出力（テーブル見出し、セクションタイトル、ラベル）は日本語で記述する
- Hire（＝サービスを使い始める決断）/ Re-hire（＝2回目以降の利用決断）は初出時に注釈し、以降は「初回利用」「継続利用」を使用
- JTBD専門用語（Push, Pull, Anxiety, Habit, Forces, Job）は初出時に日本語訳を併記し、以降は略称を使用可
- Strength（強さ）は日本語で表記: 強/中/弱
- Job Statement構文（When / I want to / so that）は英語+日本語の併記形式を使用
- サブエージェントへのプロンプト内では英語の専門用語をそのまま使用してよい（分析精度のため）
- 日本語に置き換えると原義が失われる定着用語（エビデンス等）は英語のまま残す

## Strict Rules

- Do not propose or suggest solutions — this skill is demand-side analysis only
- Do not skip from facts (Step 1) to job definition (Step 5)
- Do not proceed past a confirmation gate (→) without user approval
- Do not treat customer opinions or stated preferences as behavioral facts
- Do not score, rank, or prioritize — that belongs to experiment design
- NEVER ask the user to verify completeness — always perform self-review against the source material before presenting results at any confirmation gate
- Inference permissions follow the epistemological ladder:
  - Steps 0-3: No inference. Observable behavior and verbatim quotes only.
  - Step 4: Fact-grounded interpretation permitted (Forces analysis — inferring demand dynamics from observed contexts).
  - Step 5: Hypothesis synthesis permitted (Job definition — combining interpreted Forces with factual contexts).
  - Step 6: Integration only — synthesize Steps 3-5 outputs. Do not introduce new inferences not already established in Steps 4-5.

## Completion

This skill is complete when all conditions are met:

- A Job Statement (hypothesis) exists that the user confirms
- The statement is traceable to specific facts, common contexts (Step 3), and Forces (Step 4)
- RQ answer and Findings have been presented (Step 6)
- Input for next actions has been provided
- The user confirms analysis is complete, or directs additional investigation
