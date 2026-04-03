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

### 0. Analysis Setup

Confirm the prerequisites for the analysis.

1. **分析対象の素材**: What source material to analyze (interview transcripts, feedback logs, etc.)
2. **ケース一覧**: Who are the cases? (Name, business type, role)
3. **分析の焦点**: What decision (Hire) are we analyzing, and from what angle?
   - Examples: "初回利用→継続利用の流れ", "チャーンの経緯", "新規獲得の経路"
   - This determines the Narrator's narrative structure in Step 3 (e.g., Hire-time + Re-hire narratives for retention analysis)
   - Note: The current skill is optimized for Hire → Re-hire (初回利用→継続利用) analysis. Other focus types (churn, acquisition) require Narrator prompt adjustments.
4. **注目したい観点**（任意）: Any specific aspects the user wants to explore

**→ Confirm the setup with the user before proceeding.**

### 1. Extract Facts

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

**→ Self-review against the source material for completeness, then present the table for user approval.**

### 2. Organize Facts and Identify Background

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

**→ Self-review two things, then present for user approval:**

1. **網羅性**: Step 1の全ファクトが「前提条件」または「時系列の出来事」のいずれかに配置されていること
2. **データの充足性**: 分析の焦点（Step 0で定義）に対して十分なデータがあること。焦点の方向に対してデータが薄い・欠けている領域があれば報告する

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
> - Cite Fact identifiers (F-XX) for traceability
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
> - Each pattern must be traceable to specific Facts (F-XX) in both cases
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
> - Evaluation behavior during decision-making (cost comparison, risk assessment, ROI calculation, alternative cost structures)
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
>    - **A (Objective condition)**: Conditions observable by a third party, regardless of timing (before Hire, between Hire and Re-hire, or ongoing). These are the structural conditions that created demand.
>    - **B (Stance)**: The person's attitude/approach arising FROM a condition in category A. Always note which A-item it derives from
>    - **C (Post-experience change)**: Recognition shifts that occurred AFTER using the product. Not a demand-generating condition
>    - Test: "Could a third party observe this as an objective condition?" → Yes = A, No = B or C
> 4. **Redundancy**: Are any patterns listed independently that are actually sub-dimensions of another? Recommend merging or subordinating.
> 5. **Temporal placement**: Are any patterns classified as A that are actually post-experience recognitions (C)? Apply: "Could a third party observe this as an objective condition independent of product use?"
> 6. **Evidence strength**: Is each case's evidence based on recorded behavior/quotes, or merely a stated attitude? Flag weak evidence in Discrepancies.
> 7. **Pattern nature**: Is each entry a "common pattern" (shared across cases) or a "difference description" (contrasting cases)? Differences belong in Discrepancies, not as standalone patterns.
> 8. **Functional bias check**: Are any patterns presented as purely functional (operational efficiency, cost, speed) that also contain emotional signals (relief, security, liberation from worry) or social signals (identity, peer perception, industry positioning) in the original verbatim quotes? If so, note the emotional/social dimension and recommend whether it should be a separate pattern or an annotation on the existing pattern.
>
> Additionally: identify any common patterns the Comparator missed, based on your independent reading of the Facts.
>
> Output: For each pattern → Approve / Revise (with suggestion) / Reject (with reason) + Ctx-A/Ctx-B/Ctx-C classification.
> Do NOT write the final version yourself — provide critique and suggestions only.

**Output**: Validation report with verdicts, classification, and additional proposals.

#### 3d. Integration (main conversation)

1. Reflect the Critic's feedback: apply revisions, remove rejected patterns, add proposed patterns
2. Apply A/B/C classification
3. Compose the final table and present to the user

**Final output format**:

> ### A. 需要を生み出した共通の客観的条件
>
> | Ctx-A# | 共通コンテキスト | Case A 根拠 (F-XX) | Case B 根拠 (F-XX) | ケース間の差異 |
>
> ### B. 条件から生じた共通の態度・構え
>
> | Ctx-B# | 態度・構え | 由来する条件 (Ctx-A#) | Case A 根拠 (F-XX) | Case B 根拠 (F-XX) |
>
> ### C. 利用後に起きた共通の認識変化
>
> | Ctx-C# | 変化 | Case A (F-XX) | Case B (F-XX) |

**→ Present the final table for user approval. Confirm: Are the A/B/C classifications appropriate? Is the abstraction level right? Are any common contexts missing?**

**Single-case behavior**: When only one case exists, skip the Comparator. Run Narrator + Critic only, and output a single-case context description. Cross-case synthesis happens when additional cases are added.

### 4. Analyze Demand Forces

Analyze the Switch dynamics for each case individually, then compare across cases. This is the first step where **interpretation** (fact-grounded inference) is permitted.

Forces are about an individual person's decision dynamics — analyze each person's Switch story before looking for patterns.

**Input**:

- Per case: Fact Table (Step 1) + Background (Step 2)

**Steps**:

1. **Per-case Forces diagrams (4a)**: For each case, map the person's Hire decision onto Push/Pull/Anxiety/Habit using their Fact Table. Write a short narrative per case describing how the Forces interacted for this person's Switch.

   **Process**: Launch one subagent per case in parallel. Each subagent receives only its own case's Fact Table + Background, ensuring no cross-case anchoring. The subagent produces a Forces diagram + narrative.

   Per-case output:

   > **Case [X] Hire時の力学**
   > | 力 | 内容 | 根拠 (F-XX) | 強さ |
   > Push（現状への不満・圧力）/ Pull（新しい選択肢の魅力）/ Anxiety（新しい選択肢への不安）/ Habit（現状維持の慣性） rows
   > **ナラティブ**: [How Forces interacted for this person]
   >
   > **Case [X] Re-hire時の力学**
   > | 力 | 内容 | 根拠 (F-XX) | 強さ |
   > Push / Pull / Anxiety / Habit rows
   > **ナラティブ**: [How Forces shifted from Hire to Re-hire. Note data constraints if thin.]

2. **Cross-case comparison (4b)**: Execute in the main conversation (dialogue with user). Place per-case Forces side by side.

   Compare 4a's per-case Forces across cases to identify common dynamics:

   1. For each Force type (Push/Pull/Anxiety/Habit), place each case's Forces side by side
   2. Identify Forces with the same direction observed in 2 or more cases → assign as Common Force with identifier (CF-Push1, CF-Pull1, etc.)
   3. Record case-specific differences within each Common Force (same direction but different intensity or manifestation)
   4. Forces observed in only 1 case → retain in 4a only; do not include in 4b Common dynamics

   Judge relative strength using three axes:

   - Scale of action (immediate response vs. deliberation period)
   - Urgency of expression (verbatim quotes indicating urgency or calm)
   - Behavioral magnitude (how much the person changed their operations)

**Output format**:

> ### ケースごとの力学 (4a)
>
> [Case A: Hire時の力学 + ナラティブ + Re-hire時の力学 + ナラティブ] > [Case B: 同上]
>
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

**→ Present for user approval.**

### 5. Define Jobs (Hypotheses)

Synthesize the common context (Step 3) and Forces analysis (Step 4) into Job Statements. These are **hypotheses** — they require validation before acting on them. This step synthesizes only cross-case abstractions (Ctx-_ and CF-_) into Job Statements. Different demand structures (e.g., Hire-time vs Re-hire) may yield multiple Jobs.

**Input**:

- Step 4b Cross-case comparison: Common Forces (CF-\*) + 共通ナラティブ
- Step 3 Common contexts: A (Ctx-A*), B (Ctx-B*), C (Ctx-C\*)
- Step 1 Fact Tables (for hypothesis verification in 5e only — NOT for 根拠 column)

#### 5a. Job candidate enumeration

List candidate Jobs using the following axes (in priority order):

1. **Hire-time vs Re-hire split**: If Step 4b shows different Dominant Forces for Hire-time and Re-hire, treat them as separate Job candidates by default
2. **Step 3 B/C signals**: If Stance (Ctx-B) or Post-experience (Ctx-C) patterns suggest an independent motivation structure not captured by Dominant Forces, add as a candidate

Output: numbered list of Job candidates with the source evidence (CF-_ Dominant Force, Ctx-_ items).

#### 5b. Consolidation / separation decision

For each candidate pair, apply these criteria:

- **Separate** if Dominant Forces differ (even when the When clause overlaps — different motivation structures = different Jobs)
- **Merge** if candidates share both Dominant Force and motivation direction — state the merge rationale explicitly
- **Emerging label**: Jobs where the CF-\* cited in the 根拠 column is observed in fewer than half of the total cases receive the `[Emerging]` label and must include evidence strength (e.g., "2 of 5 cases")

If only one Job remains after consolidation, state why consolidation is justified.

Output: final Job list with separation/merge rationale.

#### 5c. Multi-lens Job Statement generation

For each Job from 5b, generate candidate Job Statements through 2 different analytical lenses. The goal is to produce diverse hypotheses as discussion material, not to converge on a single answer.

**Lens 1: Belief Chain (顧客の主観的ロジック)**

Extract the customer's own subjective reasoning from Step 1 Fact Tables — statements where the customer says "because X, I did Y" or "X means Y to me."

Process:

1. For each case, extract belief chains in the form: "If [situation] + [means] → [result], and that means [value to me]"
2. Place the 3 cases' belief chains side by side and identify **structurally similar beliefs** (not identical words, but the same reasoning pattern)
3. Express the shared belief structure as When / I want to / So that

**Lens 2: Synthesis Model (ゴール + 制約 + 触媒)**

Using Step 3 Ctx-\* and Step 4b 共通ナラティブ:

1. Classify Ctx-\* items into Goals (progress the customer wants to achieve) / Constraints (walls blocking that progress) / Catalysts (events that made the constrained goal unbearable)
2. A Job is synthesized at the moment: "A Goal that could not be achieved due to Constraints becomes unbearable because of a Catalyst"
3. When = Catalyst + Constraint becoming acute, I want to = bypass the Constraint toward the Goal, So that = achieve the Goal

**Traceability rules** (apply to all lenses):

- A clause with an empty 根拠 column is prohibited — every clause must be grounded in cross-case abstractions (Ctx-_ and/or CF-_)
- The 出典 column is optional — it provides supporting evidence from individual Facts
- Per-case Forces (4a) MUST NOT appear in the 根拠 column — they are individual-level analysis, not cross-case abstractions

#### 5d. Quality filter

Test each candidate from 5c against Step 1 Fact Tables and apply the following filters. Drop or revise candidates that fail:

| Filter                   | Criterion                                                                                                                                                                         | Action              |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| **Facts contradiction**  | Contradicted by 2+ cases                                                                                                                                                          | Drop                |
| **Tautology**            | I want to / So that merely restates the When condition. Test: "Would someone unfamiliar with this data say 'I see, so THAT's the structure' upon hearing this?" If No → tautology | Drop                |
| **Redundancy**           | Central premise is identical to another candidate (wording differs only)                                                                                                          | Drop the weaker one |
| **Granularity mismatch** | When / I want to / So that mix JyTBD-level (life transformation) with Micro-Job-level (operational task)                                                                          | Revise or Drop      |

Target: 2-3 candidates per Job slot after filtering.

#### 5e. Candidate presentation

Present surviving candidates in the following format:

> ### ジョブ仮説候補
>
> #### 候補1（レンズ名）: [短いラベル]
>
> > **When（どんな時に）** [situation],
> > **I want to（～したい）** [motivation],
> > **so that（そうすれば）** [expected progress].
>
> | 句        | 根拠（共通抽象）          | 出典（Facts）          |
> | --------- | ------------------------- | ---------------------- |
> | When      | Ctx-A1, Ctx-A2, ...       | F-A2, F-B4, F-C6 他    |
> | I want to | CF-Push1 + Ctx-B1, Ctx-B2 | F-A16, F-B16, F-C8 他  |
> | So that   | CF-Pull1 + Ctx-C1         | F-A29, F-B22, F-C28 他 |
>
> **このモデルが説明できること**: [What this candidate explains that others don't] > **このモデルが説明できないこと**: [Blind spots / limitations] > **代表的な顧客の言葉**: [Verbatim quote that best embodies this candidate]
>
> この仮説の限界・前提: [Conditions, verification needs]
>
> _(Repeat for each surviving candidate.)_

**→ Present candidates for user discussion. The user selects, combines, or modifies candidates to define the final Job Statement(s).**

## Output Language Rules

- All user-facing output (table headers, section titles, labels) must be written in Japanese
- Annotate Hire (= the decision to "hire" a solution) and Re-hire (= the decision to "hire" the same solution again) on first use; use Hire/Re-hire as-is thereafter
- JTBD terminology (Push, Pull, Anxiety, Habit, Forces, Job) must include a Japanese translation on first use; abbreviations may be used thereafter
- Strength levels must be written in Japanese: 強/中/弱
- Job Statement syntax (When / I want to / so that) must use a bilingual English + Japanese format
- English terminology may be used as-is in subagent prompts for analysis accuracy
- Established loanwords whose original meaning would be lost in Japanese translation (e.g., エビデンス) should remain in English

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
  - Step 5: Hypothesis synthesis permitted (Job definition — generating candidate Job Statements through multiple analytical lenses (Belief Chain, Synthesis Model), filtering for quality, and presenting as discussion material for user selection).

## Completion

This skill is complete when all conditions are met:

- Job Statement candidates have been generated through multiple lenses, quality-filtered, and presented to the user
- The user has selected, combined, or modified candidates to define the final Job Statement(s)
- The final statement is traceable to common contexts (Ctx-_) and Common Forces (CF-_), with Facts (F-\*) as supporting evidence
- The user confirms analysis is complete, or directs additional investigation
