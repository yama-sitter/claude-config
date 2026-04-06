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

| Args     | Action                                                                        |
| -------- | ----------------------------------------------------------------------------- |
| (none)   | Full analysis workflow: Step 0 → Step 5                                       |
| `output` | Generate output document from completed analysis (requires Step 5 in worklog) |

## Data Flow

Each Step reads its input from `job-discovery-worklog.md` and writes its output back to `job-discovery-worklog.md`. The conversation context is used only for the current Step's working data.

- **job-discovery-worklog.md**: Single source of truth. All Step outputs are persisted here.
- **Read before execute**: Each Step reads the relevant prior Step sections from the worklog before starting.
- **Write after confirm**: Each Step's output is written to the worklog after user approval at the confirmation gate.
- **Cross-session continuity**: Any Step can be resumed in a new conversation by reading the worklog.

Worklog path: `~/.agent-memory/<scope>/<date>_<topic>/job-discovery-worklog.md`

## Workflow

### 0. Analysis Setup

**I/O**: Input: user instructions. Output to worklog: frontmatter + Step 0 section. → Write after confirmation gate.

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

**→ Confirm the setup with the user before proceeding. After approval, create the worklog file and write Step 0.**

### 1. Extract Facts

**I/O**: Input from worklog: Step 0 (case list) + source material paths. Output to worklog: Step 1 section (Fact Tables). → Write after confirmation gate.

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

**→ Self-review against the source material for completeness, then present the table for user approval. After approval, append Step 1 to the worklog.**

### 2. Organize Facts and Identify Background

**I/O**: Input from worklog: Step 0 + Step 1. Output to worklog: Step 2 section (Background + Events + data sufficiency). → Write after confirmation gate.

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

**→ Self-review two things, then present for user approval. After approval, append Step 2 to the worklog:**

1. **網羅性**: Step 1の全ファクトが「前提条件」または「時系列の出来事」のいずれかに配置されていること
2. **データの充足性**: 分析の焦点（Step 0で定義）に対して十分なデータがあること。焦点の方向に対してデータが薄い・欠けている領域があれば報告する

If data sufficiency issues are found, present the user with options: (a) return to data collection, (b) continue with the constraint noted, or (c) stop.

### 3. Extract Common Context

**I/O**: Input from worklog: Step 0 + Step 1 + Step 2. Subagents read from worklog (not from conversation context). Output to worklog: Step 3 section (Narrator outputs + Common Contexts + Causal Chain). → Write after confirmation gate.

Extract the common contexts across cases **for each phase** defined in Step 0 — the circumstances that created demand for the Hire decision and how they evolved across phases. This step uses two stages of subagents: Narrators (one per case, in parallel) and an Analyst-Critic (cross-case comparison + validation in a single pass).

**"Situation" in JTBD** means the conditions in the person's business/life — NOT the product experience. A situation describes _why demand arose_, not _what happened after using the product_. Each phase captures situations and stances at that point in the journey.

#### 3a. Narrator (launch one per case, in parallel)

**Input**: The case's Fact Table (Step 1) + Background (Step 2) + Phase definitions (Step 0). **Data source**: Pass the worklog path to the subagent. The subagent reads its own case's Step 1 and Step 2 sections from the worklog.

See [narrator-prompt.md](references/narrator-prompt.md) for the full Narrator prompt.

**Output**: One narrative per phase per case, with Fact citations.

#### 3b. Analyst-Critic (launch one)

**Input**: All Narrator outputs + all Fact Tables + Background (Step 2) + Phase definitions (Step 0). **Data source**: Pass the worklog path to the subagent. The subagent reads all cases' Step 1, Step 2, and Step 3a Narrator outputs (full text) from the worklog.

See [analyst-critic-prompt.md](references/analyst-critic-prompt.md) for the full Analyst-Critic prompt.

**Output**: Comparison tables + Validation report + Completeness gap report + Additional proposals.

#### 3c. Integration (main conversation)

See [integration-format.md](references/integration-format.md) for integration rules and output format.

**→ Present the final tables and causal chain for user approval. After approval, append Step 3 to the worklog (including Narrator outputs as intermediate artifacts). Confirm: Are the Situation/Stance classifications appropriate? Are the phase assignments correct? Is the abstraction level right? Are any common contexts missing? Does the causal chain accurately represent the demand structure?**

**Single-case behavior**: When only one case exists, run Narrator + Analyst-Critic (Phase 3A-3B validation only). Skip Phase 1 Inventory, Phase 2 Cross-case Comparison, and Phase 3C Completeness Verification (these require multiple cases). Output a single-case context description. Cross-case synthesis happens when additional cases are added.

### 4. Analyze Demand Forces

**I/O**: Input from worklog: Step 1 + Step 2 (per-case Fact Table + Background only — do NOT read Step 3 for 4a to preserve case independence). For 4b cross-case comparison, also read Step 3. Subagents read from worklog. Output to worklog: Step 4 section (4a + 4b + common narrative). → Write after confirmation gate.

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

**→ Present for user approval. After approval, append Step 4 to the worklog.**

**Single-case behavior**: When only one case exists, skip 4b (cross-case comparison). Produce the per-case Forces diagram (4a) and narrative only. Common Forces (CF-\*) are not generated. Proceed to Step 5 with per-case Forces as the input.

### 5. Define Jobs (Hypotheses)

**I/O**: Input from worklog: Step 3 + Step 4 (+ Step 1 for 5d verification only). Output to worklog: Step 5 section (Job Slots + candidates). → Write after confirmation gate.

Synthesize the common context (Step 3) and Forces analysis (Step 4) into Job Statements. These are **hypotheses** — they require validation before acting on them. This step synthesizes only cross-case abstractions (P*-S*/P*-St* and CF-\*) into Job Statements. Different demand structures (e.g., different phases) may yield multiple Jobs.

**Input**:

- Step 4b Cross-case comparison: Common Forces (CF-\*) + 共通ナラティブ
- Step 3 Common contexts: Per-phase Situations (P*-S*) and Stances (P*-St*)
- Step 1 Fact Tables (for hypothesis verification in 5e only — NOT for 根拠 column)
- **Single-case adjustment**: When CF-\* does not exist (single-case analysis), use per-case Forces (4a) as the basis for Job Statements. Traceability rules are relaxed: the 根拠 column may cite per-case Forces and single-case context patterns instead of CF-\* and P\*-S\*/P\*-St\*. Label all resulting Job Statements as `[Single-case — requires cross-case validation]`

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

For each Job from 5b, generate candidate Job Statements through 3 analytical lenses (Belief Chain, Synthesis Model, Emotional/Social Job) to produce diverse hypotheses as discussion material.

See [step5-lenses.md](references/step5-lenses.md) for lens details and traceability rules.

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

**→ Present candidates for user discussion. After approval, append Step 5 to the worklog. The user selects, combines, or modifies candidates to define the final Job Statement(s).**

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

Generate a shareable Markdown document from the completed analysis worklog.

### Prerequisites

- `job-discovery-worklog.md` exists in agent-memory and contains a Step 5 section
- The worklog path is specified by the user or detected from conversation context
- If the worklog is not found or Step 5 section is missing, display: **「worklogが見つからない、またはStep 5が完了していません。分析を先に完了してください」** and stop

See [output-template.md](references/output-template.md) for implementation details and document template.
