---
name: job-discovery
description: |
  Discover Jobs-to-be-Done from customer behavior facts, interview logs, or feedback data.
  Use when the user provides raw customer data and wants to discover the underlying demand structure and generate Job hypotheses.
  Do not use when the user already has a clear hypothesis and wants to design experiments.
  Do not use when the user wants to brainstorm or evaluate solutions.
user-invocable: true
---

# Job Discovery

Discover Jobs-to-be-Done from raw customer data by climbing the Ladder of Inference one rung at a time.

## Prerequisites

- Customer interview logs, behavior data, or feedback are accessible
- This skill produces demand-side analysis only — output feeds into experiment design

## Argument Routing

| Args     | Action                                                                                                         |
| -------- | -------------------------------------------------------------------------------------------------------------- |
| (none)   | Full analysis workflow: Step 0 → Step 5                                                                        |
| `output` | Generate output document from completed analysis (requires Step 5 to be completed in the current conversation) |

## Workflow

### 0. Analysis Setup

Confirm the prerequisites for the analysis.

1. **分析対象の素材**: What source material to analyze (interview transcripts, feedback logs, etc.)
2. **ケース一覧**: Who are the cases? (Name, business type, role)
3. **分析の焦点とフェーズ**: What decision (Hire) are we analyzing, from what angle, and what phases does the journey have?
   - Examples: "初回利用→継続利用の流れ", "チャーンの経緯", "新規獲得の経路"
   - Define 2-4 phases that the customer goes through (e.g., "利用前 → 初回利用後 → 2回目以降")
   - This determines the Narrator's narrative structure in Step 3 (one narrative per phase)
   - Note: The current skill is optimized for Hire → Re-hire analysis. Other focus types require Narrator prompt adjustments.
4. **フレーム認識**: What does this RQ assume? What might it NOT ask?
   - Note the implicit assumptions in the RQ's framing (e.g., "re-hire" assumes a single purpose for hiring)
   - The analysis should answer the RQ, but remain open to demand structures the RQ does not anticipate. If the data reveals purposes, segments, or dynamics outside the RQ's frame, capture them
5. **注目したい観点**（任意）: Any specific aspects the user wants to explore

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

Extract the common contexts across cases **for each phase** defined in Step 0 — the circumstances that created demand for the Hire decision and how they evolved across phases. This step uses three specialized subagents.

**"Situation" in JTBD** means the conditions in the person's business/life — NOT the product experience. A situation describes _why demand arose_, not _what happened after using the product_. Each phase captures situations and stances at that point in the journey.

#### 3a. Narrator (launch one per case, in parallel)

**Input**: The case's Fact Table (Step 1) + Background (Step 2) + Phase definitions (Step 0)

**Prompt essence**:

> You are a JTBD researcher. From the Fact Table below, describe the **situation** this person was in across the phases defined in the analysis setup.
>
> "Situation" means conditions in the person's business/life — NOT the product experience (what happened after using it).
>
> Write one narrative per phase defined in the analysis setup.
> For each phase, describe:
>
> - **Situations**: Objective conditions observable by a third party at this phase
> - **Stances**: The person's attitude/approach at this phase, arising from the situations
>
> Each narrative must include:
>
> - **Background constraints**: Structural limitations of their business/environment
> - **Structural affordances**: Business characteristics that make certain solution types viable (e.g., task simplicity, work schedule flexibility, geographic patterns)
> - **Purpose**: What is the person explicitly trying to achieve by using this solution? Different cases may have different purposes — list all that are explicitly stated.
>   - Purposes stated in verbatim quotes: cite the quote (F-XX) directly
>   - Purposes inferred from observable action patterns (e.g., repeated ordering behavior → intent to secure ongoing supply): tag as `[推定]` and state in one sentence the action pattern and the inferential leap. Example: `[推定] 毎週発注を繰り返している (F-A3, F-A7) → 継続的な人材確保が目的と推定`
>   - Do NOT infer purposes the customer did not express or demonstrate through repeated behavior
> - **Struggling moment**: When their current approach stopped working
> - **Why now**: Why they acted at this point (not earlier, not later)
>
> For Phase 2 and beyond, also note:
>
> - Which situations **continued** from the previous phase
> - Which situations **changed** from the previous phase
> - Which situations are **new** (first appeared in this phase)
>
> Rules:
>
> - Do NOT include product experience (what happened after using the product) in Phase 1. Phase 2+ may reference post-experience observations as situations or stances
> - Cite Fact identifiers (F-XX) for traceability
> - No inference of emotions or motivations not evidenced by quotes or observable behavior

**Output**: One narrative per phase per case, with Fact citations.

#### 3b. Comparator (launch one)

**Input**: All Narrator outputs + all Fact Tables + Phase definitions (Step 0)

**Prompt essence**:

> You are a JTBD researcher. Compare the situation narratives across cases and extract common patterns **for each phase**.
>
> Steps:
>
> 1. Read all narratives. Discover **dimensions** for comparison — derive dimensions from what the narratives contain. As a checklist against blind spots, also consider whether any of the following are present in the data: decision-making structure, information acquisition path, task characteristics, geographic/physical constraints, relationship with alternatives, evaluation behavior during decision-making. Only add dimensions that are actually evidenced in the narratives
> 2. For each dimension, describe each case's situation and write a tentative **common pattern**
> 3. For each dimension, check whether cases are using the solution for the same purpose or for divergent purposes. If purposes diverge, note this in the table — it may indicate different Jobs within the same phase
> 4. Produce separate tables for each phase defined in the analysis setup
> 5. If a divergent purpose identified in step 3 is observed in 2+ cases, promote it to a formal Situation pattern (P*-S*) in the appropriate phase table. If observed in only 1 case, retain it in the Purpose table only — it may feed Step 5 as an [Emerging] signal but does not become a common pattern
>
> Common pattern rules:
>
> - Each pattern must be traceable to specific Facts (F-XX) in both cases
> - Do not over-abstract — "any business that needs staff" is too vague
> - Note where one case's fit is weaker than the other's
>
> For Phase 2+ patterns, determine the change tag:
>
> - **Continued**: This pattern existed in the previous phase and remains essentially the same
> - **Changed**: This pattern existed in the previous phase but its content or intensity has shifted
> - **New**: This pattern first appeared in this phase

**Output**: Per-phase cross-case comparison table: `| Dimension | Case A | Case B | Common pattern (tentative) | Change tag (Phase 2+) | Notes |`

#### 3c. Critic (launch one)

**Input**: Comparator output + Narrator outputs + original Fact Tables + JTBD theoretical frame

**Prompt essence**:

> You are a critical reviewer with deep JTBD expertise. Validate the Comparator's common patterns.
>
> **IMPORTANT: Do NOT take the Comparator's output at face value.** Go back to the original Fact Tables independently and form your own view before reviewing.
>
> **First**, review the Narrator outputs for upstream issues:
>
> 1. **Narrator inference check**: Review each Narrator's Purpose entries. Purposes inferred from action patterns must carry a `[推定]` tag with a stated inferential leap. Flag any Purpose that appears to be inferred (not a verbatim quote) but lacks the tag
> 2. **Narrator situation/experience boundary**: Check whether any Narrator described product experience (what happened after using the product) as a Phase 1 Situation. Phase 1 must contain only pre-Hire conditions
>
> **Then**, validate the Comparator's common patterns:
>
> 1. **Conceptual accuracy**: Is each pattern a description of a _situation_ (conditions the person was in), or is it actually a _fact/event_ (something that happened) or _product experience_ (what happened after using the product)?
>    - NG: "Filled in 5 minutes" → product experience, not a situation
>    - OK: "Traditional recruitment channels produced zero applicants for months" → situation
> 2. **Theoretical consistency**: Does each pattern describe a condition that _created demand_ for a new solution? Or is it merely a characteristic of the business that doesn't drive the Hire decision?
> 3. **Category assignment**: For each pattern, classify as:
>    - **Situation**: Objective condition observable by a third party
>    - **Stance**: The person's attitude/approach arising from a Situation. Always note which Situation item it derives from
>    - And assign to the appropriate phase (P1, P2, P3, ...).
>    - For Phase 2+, tag situations AND stances as: **Continued** / **Changed** / **New**
>    - Classification test: "Could a third party observe this as an objective condition?" → Yes = Situation, No = Stance
>    - Note: Items that were previously "post-experience changes" (old C category) must be re-classified as either Situation or Stance in the appropriate phase. Example: "ワーカーの質が期待を上回った" = Situation (observable), "安心感を得た" = Stance (subjective)
> 4. **Redundancy**: Are any patterns listed independently that are actually sub-dimensions of another? Recommend merging or subordinating.
> 5. **Phase placement**: Are any patterns assigned to the wrong phase? Apply: "At which point in the journey did this condition first become observable?"
> 6. **Evidence strength**: Is each case's evidence based on recorded behavior/quotes, or merely a stated attitude? Flag weak evidence in Discrepancies.
> 7. **Pattern nature**: Is each entry a "common pattern" (shared across cases) or a "difference description" (contrasting cases)? Differences belong in Discrepancies, not as standalone patterns.
> 8. **Functional bias check**: Are any patterns presented as purely functional (operational efficiency, cost, speed) that also contain emotional signals (relief, security, liberation from worry) or social signals (identity, peer perception, industry positioning) in the original verbatim quotes? If so, note the emotional/social dimension and recommend whether it should be a separate pattern or an annotation on the existing pattern.
> 9. **Causal chain verification**: After reviewing the Integration's causal chain, verify: (a) every pattern participates in at least one chain, (b) each arrow's causal claim is supported by Fact Table evidence, (c) any isolated pattern (belongs to no chain) is truly independent or should be merged.
> 10. **Frame blindness check**: Review Step 0's frame awareness notes. Are there signals in the data that fall outside the RQ's frame? Specifically, check whether the Narrator's Purpose entries reveal divergent use cases not captured by the current pattern set.
>
> Additionally: identify any common patterns the Comparator missed, based on your independent reading of the Facts.
>
> Output: For each pattern → Approve / Revise (with suggestion) / Reject (with reason) + Phase + Layer (Situation/Stance) classification + Change tag (Phase 2+).
> Do NOT write the final version yourself — provide critique and suggestions only.

**Output**: Validation report with verdicts, classification, and additional proposals.

#### 3d. Integration (main conversation)

1. Reflect the Critic's feedback: apply revisions, remove rejected patterns, add proposed patterns
2. Apply Phase × Layer (Situation/Stance) classification
3. Compose the final tables per phase
4. Write a **causal chain** connecting patterns across phases

**Baseline conditions**: Conditions that persist unchanged across all phases (structural affordances, business characteristics) should be placed in Phase 1 as baseline conditions. They do not require a change tag in later phases unless they become relevant to a phase-specific pattern.

**Pattern descriptions must be observational only**: Describe what a third party could observe. Do NOT add interpretive conclusions (causes, effects, evaluations, significance). Interpretation belongs in the causal chain, not in the table.

- NG: "〜が脅かされている", "〜が確認される", "〜転換点となる", "〜コストが低下する"
- OK: "〜が発生している", "〜を上回っている", "〜が確立している", "〜が使われている"

**Final output format**:

> ### フェーズ1: [phase name]
>
> #### 共通状況
>
> | P1-S# | パターン | 3社での現れ方 | 出典 |
>
> #### 共通の構え
>
> | P1-St# | 構え | 由来する状況 | 出典 |
>
> ### フェーズ2: [phase name]
>
> #### 共通状況
>
> | P2-S# | 変化タグ | パターン | 3社での現れ方 | 出典 |
>
> (変化タグ: 継続 / 変化 / 新規)
>
> #### 共通の構え
>
> | P2-St# | 変化タグ | 構え | 由来する状況 | 出典 |
>
> _(Repeat for each additional phase)_
>
> ### 因果チェーン
>
> Describe the causal relationships between patterns using the following notation:
>
> - `→`: A situation/stance generates another stance
> - `×`: Multiple conditions combine to produce a stance
> - `※`: Annotate a pattern's analytical role (前提条件 = precondition that made this solution viable / 促進条件 = accelerant that enabled quick action)
> - Use block headings to label demand structure phases (e.g., Hire需要の形成 / 体験による需要構造の変化 / Re-hire需要の構造)
> - For Purpose divergence: Include a 1-line summary in the relevant block heading (e.g., "Purpose divergence: A=量的確保, B=スカウト+休息, C=休息+拡張"). Single-case purposes that were not promoted to P*-S* should be noted as `※ Purpose [Case]: [description] (1ケースのみ。[Emerging]信号としてStep 5に渡す)`
>
> Every pattern must participate in at least one chain. If a pattern is isolated (belongs to no chain), reconsider whether it is truly independent or should be merged.
>
> **Note**: The Narrator's Purpose entries and Comparator's Purpose divergence analysis are intermediate artifacts. They are NOT included as separate tables in the Integration output. Purposes that are common across 2+ cases should already be promoted to P*-S* patterns. The remaining Purpose information is captured in the causal chain annotations above.

**→ Present the final tables and causal chain for user approval. Confirm: Are the Situation/Stance classifications appropriate? Are the phase assignments correct? Is the abstraction level right? Are any common contexts missing? Does the causal chain accurately represent the demand structure?**

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

2. **Cross-check (4a review)**: Before proceeding to cross-case comparison, verify the per-case Forces in the main conversation:

   1. **Category consistency**: Check whether the same Fact (F-XX) has been assigned to different Force categories across cases (e.g., F-A5 as Push in Case A, but a similar fact F-B3 as Pull in Case B). If found, resolve the categorization
   2. **Strength justification**: Confirm that each strength rating (強/中/弱) is grounded in the three axes — scale of action, urgency of expression, and behavioral magnitude — not just impressionistic judgment
   3. **Push/Pull separation**: Verify that Push items describe dissatisfaction with the _current state_, and Pull items describe attraction to _the new solution's promise_. Mixed items should be split or reclassified

   If inconsistencies are found, revise the 4a outputs before proceeding.

3. **Cross-case comparison (4b)**: Execute in the main conversation (dialogue with user). Place per-case Forces side by side.

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
> If Step 3 is already completed and its Purpose divergence identified divergent use cases, note how these divergent purposes manifest as different Force dynamics in the common narrative.
>
> **Hire時の共通因果フロー**: [3ケースに共通するForceの相互作用と因果の流れを1段落で記述。各ケースの個別事情ではなく、共通する構造的因果を表現する]
>
> **Re-hire時の共通因果フロー**: [同上。Hire時からの変化の共通構造を含む]

**→ Present for user approval.**

### 5. Define Jobs (Hypotheses)

Synthesize the common context (Step 3) and Forces analysis (Step 4) into Job Statements. These are **hypotheses** — they require validation before acting on them. This step synthesizes only cross-case abstractions (P*-S*/P*-St* and CF-\*) into Job Statements. Different demand structures (e.g., different phases) may yield multiple Jobs.

**Input**:

- Step 4b Cross-case comparison: Common Forces (CF-\*) + 共通ナラティブ
- Step 3 Common contexts: Per-phase Situations (P*-S*) and Stances (P*-St*)
- Step 1 Fact Tables (for hypothesis verification in 5e only — NOT for 根拠 column)

#### 5a. Job candidate enumeration

List candidate Jobs using the following axes (in priority order):

1. **Phase split**: If Step 4b shows different Dominant Forces for different phases, treat them as separate Job candidates by default
2. **Stance signals**: If Stance (P*-St*) patterns suggest an independent motivation structure not captured by Dominant Forces, add as a candidate
3. **Causal chain divergence**: If the causal chain shows that a common pattern within the same phase diverges at the case level into different Progress (desired outcomes), list each divergent path as a sub-slot. Example: If ROI evaluation leads some cases to "limited use as backup" and others to "structural integration into operations," these represent different Jobs despite sharing the same phase and Dominant Force

Output: numbered list of Job candidates with the source evidence (CF-_ Dominant Force, P_-S*/P*-St\* items).

#### 5b. Consolidation / separation decision

For each candidate pair, apply these criteria:

- **Separate** if Dominant Forces differ (even when the When clause overlaps — different motivation structures = different Jobs)
- **Merge** if candidates share both Dominant Force and motivation direction — state the merge rationale explicitly
- **Emerging label**: Jobs where the CF-\* cited in the 根拠 column is observed in fewer than half of the total cases receive the `[Emerging]` label and must include evidence strength (e.g., "2 of 5 cases")

If only one Job remains after consolidation, state why consolidation is justified.

Output: final Job list with separation/merge rationale.

#### 5c. Multi-lens Job Statement generation

For each Job from 5b, generate candidate Job Statements through 3 different analytical lenses. The goal is to produce diverse hypotheses as discussion material, not to converge on a single answer.

**Lens 1: Belief Chain (顧客の主観的ロジック)**

Extract the customer's own subjective reasoning from Step 1 Fact Tables — statements where the customer says "because X, I did Y" or "X means Y to me."

Process:

1. For each case, extract belief chains in the form: "If [situation] + [means] → [result], and that means [value to me]"
2. Place the 3 cases' belief chains side by side and identify **structurally similar beliefs** (not identical words, but the same reasoning pattern)
3. Express the shared belief structure as When / I want to / So that

**Lens 2: Synthesis Model (ゴール + 制約 + 触媒)**

Using Step 3 P*-S*/P*-St* and Step 4b 共通ナラティブ:

1. Classify P*-S*/P*-St* items into Goals (progress the customer wants to achieve) / Constraints (walls blocking that progress) / Catalysts (events that made the constrained goal unbearable)
2. A Job is synthesized at the moment: "A Goal that could not be achieved due to Constraints becomes unbearable because of a Catalyst"
3. When = Catalyst + Constraint becoming acute, I want to = bypass the Constraint toward the Goal, So that = achieve the Goal

**Lens 3: Emotional/Social Job (感情的・社会的ジョブ)**

Extract emotional and social signals from Step 1 Fact Tables — expressions of relief, anxiety, pride, liberation, peer comparison, identity, or self-perception.

Process:

1. For each case, extract verbatim quotes containing emotional expressions (安心, 不安, 衝撃, 解放, 誇り) or social expressions (同業者との比較, 自己認識の変化, 周囲の評価)
2. Place the 3 cases' emotional/social signals side by side and identify structurally similar patterns
3. Express as When / I want to / So that, focusing on what the person wanted to FEEL or how they wanted to BE SEEN, not what they wanted to DO

Note: Emotional/Social Jobs often share the When clause with Functional Jobs but diverge in I want to and So that. This is expected — the same situation creates both functional and emotional demand.

**Traceability rules** (apply to all lenses):

- A clause with an empty 根拠 column is prohibited — every clause must be grounded in cross-case abstractions (P*-S*/P*-St* and/or CF-\*)
- The 出典 column is optional — it provides supporting evidence from individual Facts
- Per-case Forces (4a) MUST NOT appear in the 根拠 column — they are individual-level analysis, not cross-case abstractions
- For Lens 3, emotional/social signals from individual Facts (F-XX) may appear in the 根拠 column when no cross-case abstraction captures the emotional dimension. In this case, cite the Facts directly and note that the pattern is observed across 2+ cases

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
> | When      | P1-S1, P1-S2, ...         | F-A2, F-B4, F-C6 他    |
> | I want to | CF-Push1 + P1-St1, P1-St2 | F-A16, F-B16, F-C8 他  |
> | So that   | CF-Pull1 + P2-S1          | F-A29, F-B22, F-C28 他 |
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
  - Steps 0-3: No inference. Observable behavior and verbatim quotes only. Exception: Step 3a Purpose allows action-pattern-based inference tagged as `[推定]` (see Narrator prompt).
  - Step 4: Fact-grounded interpretation permitted (Forces analysis — inferring demand dynamics from observed contexts).
  - Step 5: Hypothesis synthesis permitted (Job definition — generating candidate Job Statements through multiple analytical lenses (Belief Chain, Synthesis Model), filtering for quality, and presenting as discussion material for user selection).

## Completion

This skill is complete when all conditions are met:

- Job Statement candidates have been generated through multiple lenses, quality-filtered, and presented to the user
- The user has selected, combined, or modified candidates to define the final Job Statement(s)
- The final statement is traceable to common contexts (P*-S*/P*-St*) and Common Forces (CF-_), with Facts (F-_) as supporting evidence
- The user confirms analysis is complete, or directs additional investigation

## Output Subcommand (`/job-discovery output`)

Generate a shareable Markdown document from the completed analysis. Requires Step 5 to be completed in the current conversation.

### Prerequisites

- Step 5 candidates have been presented in the current conversation
- If Step 5 is not completed, display: **「Step 5が完了していません。分析を先に完了してください」** and stop

### Output Document Structure

Write the document to agent-memory as `output.md` in the analysis directory (e.g., `~/.agent-memory/<scope>/<date>_<topic>/output.md`).

**Design principles**:

- **No JTBD jargon without explanation**: Annotate Hire, Re-hire, Push, Pull, etc. with plain-language descriptions on first use
- **Conclusion first**: Job hypotheses (most abstract) → supporting patterns → detailed data
- **Traceability throughout**: All sections use P*-S*/P*-St*/CF-\*/F-XX identifiers. Include a legend at the top
- **Hide internal process**: No lens names, Step numbers, or skill-internal terminology
- **Appendix is collapsible**: Use `<details>` tags for raw data
- **List formatting in tables**: When listing multiple items per case (e.g., "A: x / B: y / C: z"), use comma-separated format `A: x, B: y, C: z` for Notion compatibility. Do NOT use `<br>` tags.

**Document template**:

```markdown
# Job Discovery: [1-line summary of the analysis focus]

- **分析対象**: [source material description]
- **焦点**: [analysis focus from Step 0]

| ケース                  | 企業 | 事業 | 体制 | トリガー | 現在の位置づけ |
| ----------------------- | ---- | ---- | ---- | -------- | -------------- |
| [Case rows from Step 0] |

> **識別子の読み方**
>
> - `P1-S1` 等: フェーズ1の共通状況パターン（下記「共通する行動パターン」で定義）
> - `P1-St1` 等: フェーズ1の共通の構え（下記「共通する行動パターン」で定義）
> - `CF-Push1` 等: 3社に共通する意思決定の力（下記「共通する力学」で定義）
> - `F-A1` 等: 個別ケースの発言・行動記録（付録「ファクトテーブル」で参照可能）

---

## 1. 発見されたジョブ仮説

「顧客がこのサービスを使う理由」の仮説候補。
確定版ではなく、議論・検証のための叩き台として複数の視点から生成しています。

### [Phase label]のジョブ（[plain-language question]）

#### 候補N: [short label]

| 句               | 内容                | 根拠        | 出典      |
| ---------------- | ------------------- | ----------- | --------- |
| **どんな時に**   | [situation]         | Ctx-_, CF-_ | F-XX, ... |
| **何をしたいか** | [motivation]        | Ctx-_, CF-_ | F-XX, ... |
| **そうすれば**   | [expected progress] | Ctx-_, CF-_ | F-XX, ... |

- 💡 **説明できること**: [unique explanatory power]
- 🔍 **さらに検討が必要な点**: [blind spots]
- 🗣️ **代表的な声**: _"[verbatim quote]"（[Case]）_

この仮説の限界・前提: [constraints]

_(Repeat for each candidate per phase)_

---

## 2. 3社に共通する行動パターン

### フェーズ1: [phase name]

#### 共通状況

| P1-S# | パターン | 3社での現れ方 | 出典 |
| ----- | -------- | ------------- | ---- |

#### 共通の構え

| P1-St# | 構え | 由来する状況 | 出典 |
| ------ | ---- | ------------ | ---- |

### フェーズ2: [phase name]

#### 共通状況

| P2-S# | 変化タグ | パターン | 3社での現れ方 | 出典 |
| ----- | -------- | -------- | ------------- | ---- |

(変化タグ: 継続 / 変化 / 新規)

#### 共通の構え

| P2-St# | 変化タグ | 構え | 由来する状況 | 出典 |
| ------ | -------- | ---- | ------------ | ---- |

_(Repeat for each additional phase)_

---

## 3. 共通する意思決定の力学

### [Phase]時

| CF-# | 力  | 共通の力学 | ケース間の違い | 出典 |
| ---- | --- | ---------- | -------------- | ---- |

**最も強い力**: [summary]

### 共通ナラティブ

**[Phase 1]の共通因果フロー**:

- [sentence 1]
- [sentence 2]
- ...

**[Phase 2]の共通因果フロー**:

- [sentence 1]
- [sentence 2]
- ...

---

## 付録

<details>
<summary>ファクトテーブル（生データ）</summary>

[Step 1 full Fact Tables per case]

</details>

<details>
<summary>ケースごとのストーリー（時系列）</summary>

Per case:

**前提条件**: List format, one condition per line with F-XX identifiers

**時系列の出来事**: Table format:

| # | フェーズ | 出来事 | 出典 |

[Step 2 Background + Events per case]

</details>

<details>
<summary>ケースごとの力学分析</summary>

Per case, per phase: summary line + table format:

| 力 | 強さ | 内容 |

[Step 4a per-case Forces data]

</details>
```

**→ Save the document to agent-memory and display the saved path to the user.**
