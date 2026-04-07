# Context Workflow

## Prerequisites

`{{STEP1_FACT_TABLES}}` and `{{STEP2_BACKGROUND_EVENTS}}` are replaced in the report file.

## Owned Placeholders

`{{STEP3A_NARRATOR_OUTPUTS}}`, `{{STEP3B_ANALYST_CRITIC_OUTPUT}}`, `{{STEP3_COMMON_PATTERNS}}`

## Workflow

Extract the common contexts across cases **for each phase** defined in facts Step 3 — the circumstances that created demand for the Hire decision and how they evolved across phases. This step uses two stages of subagents: Narrators (one per case, in parallel) and an Analyst-Critic (cross-case comparison + validation in a single pass).

**"Situation" in JTBD** means the conditions in the person's business/life — NOT the product experience. A situation describes _why demand arose_, not _what happened after using the product_. Each phase captures situations and stances at that point in the journey.

**Input from report**: header + appendix (Fact Tables, Background/Events). Subagents read from report file appendix (not from conversation context).

### 3a. Narrator (launch one per case, in parallel)

**Input**: The case's Fact Table (Step 1) + Background (Step 2) + Phase definitions (facts Step 3). **Data source**: Pass the report file path to the subagent. The subagent reads its own case's Fact Table and Background/Events from the report file appendix, and phase definitions from the "フェーズ定義" appendix section (inside a `<details>` tag).

**RQ Isolation Rule**: The Narrator's task is to describe situations from raw data, not to validate the RQ. When instructing the Narrator subagent, emphasize that ANALYSIS_FOCUS and FRAME_AWARENESS in the report header define the research question — they are NOT the expected findings. The Narrator must derive narratives from Fact Tables and Background/Events, not from the RQ's framing.

See [narrator-prompt.md](narrator-prompt.md) for the full Narrator prompt.

**Output**: One narrative per phase per case, with Fact citations.

**→ After all Narrators complete, replace `{{STEP3A_NARRATOR_OUTPUTS}}` in the report file with the combined Narrator outputs.**

### 3b. Analyst-Critic (launch one)

**Input**: All Narrator outputs + all Fact Tables + Background (Step 2) + Phase definitions (facts Step 3). **Data source**: Pass the report file path to the subagent. The subagent reads all cases' Fact Tables, Background/Events, and Narrator outputs from the report file appendix, and phase definitions from the "フェーズ定義" appendix section (inside a `<details>` tag).

See [analyst-critic-prompt.md](analyst-critic-prompt.md) for the full Analyst-Critic prompt.

**Output**: Comparison tables + Validation report + Completeness gap report + Additional proposals.

**→ After the Analyst-Critic completes, replace `{{STEP3B_ANALYST_CRITIC_OUTPUT}}` in the report file.**

### 3c. Integration (main conversation)

See [integration-format.md](integration-format.md) for integration rules and output format.

## Confirmation Gate

Present the final tables and causal chain for user approval. After approval, replace `{{STEP3_COMMON_PATTERNS}}` in the report file with the section heading and final tables. The content must include the `## 2.` section heading (e.g., '## 2. 3社に共通する行動パターン') as part of the replacement since the heading is not in the template.

Confirm: Are the Situation/Stance classifications appropriate? Are the phase assignments correct? Is the abstraction level right? Are any common contexts missing? Does the causal chain accurately represent the demand structure?

If Narrator out-of-phase signals were flagged and validated by the Analyst-Critic as potential phase boundary issues, report them to the user with options: (a) return to facts Step 3 to revise phase definitions, then re-run context; (b) continue with current phase definitions (out-of-phase signals will be considered in jobs Step 5); (c) stop and return to data collection.

## Single-case Behavior

When only one case exists, run Narrator + Analyst-Critic (Phase 3A-3B validation only). Skip Phase 1 Inventory, Phase 2 Cross-case Comparison, and Phase 3C Completeness Verification (these require multiple cases). Output a single-case context description. Cross-case synthesis happens when additional cases are added.
