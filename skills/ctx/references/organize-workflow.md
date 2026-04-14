# Organize Workflow

## Prerequisites

`{{FACT_TABLES}}` and `{{BACKGROUND_EVENTS}}` are replaced in the appendix file.

## Route Selection

Count the rows in CASE_TABLE (main report header) to determine the route:

| Cases | Route      | Behavior                                        |
| ----- | ---------- | ----------------------------------------------- |
| 1     | Single     | Phase A only (existing Single-case Behavior)    |
| 2–10  | Direct     | Skip Phase A → Phase B with integrated grouping |
| 11+   | Scaffolded | Phase A → Phase B with reference approach       |

## Owned Placeholders

`{{CONTEXT_DESCRIPTIONS}}` (appendix), `{{COMMON_CONTEXTS}}` (main report)

## Resume Logic

On start, check for owned placeholders:

- Both present → determine route, then:
  - Direct: start from Phase B (Phase A is skipped)
  - Scaffolded: start from Phase A
- Only `{{COMMON_CONTEXTS}}` present → resume from Phase B (Phase A already completed)
- None present → all phases already completed; inform the user

## Workflow

Structure facts into 5W1H contexts per case, then compare across cases to extract common contexts.

---

### Phase A: Context Description (per-case) — Scaffolded route only

> **Route guard**: This phase runs only in the Scaffolded route (11+ cases). For Direct route (2–10 cases), proceed directly to Phase B.

**Input from appendix**: Fact Tables + Background/Events.

For each case, group related facts into **context units** (a set of facts that together describe one situation) and describe each context unit using 5W1H axes.

Launch one subagent per case in parallel. Each subagent receives only its own case's Fact Table + Background/Events from the appendix file. The subagent produces a 5W1H context table.

**RQ Isolation Rule**: The main report header contains ANALYSIS_FOCUS and FRAME_AWARENESS — these define the research question, NOT the expected context structure. Subagents must derive contexts from observed facts, not from the RQ's assumed situational patterns.

**Output containment**: Subagent output must NOT include file paths, plan references, or any external file references. All output will be embedded directly into the appendix and must be self-contained.

#### Subagent Prompt

> You are a qualitative researcher. From the Fact Table and Background/Events below, group related facts into **context units** and describe each using 5W1H axes.
>
> A "context unit" is a set of facts that together describe one situation — a condition, event, or pattern in the person's environment.
>
> **Axes to describe:**
>
> - **What**: What happened or what condition existed (observable)
> - **When**: When it happened or when the condition existed (time period, phase, or relative timing)
> - **Where**: Where it happened (location, setting, channel)
> - **Who**: Who was involved (actors, stakeholders, sources)
> - **How**: How it happened or how the condition manifested (mechanism, channel, method)
>
> **Do NOT describe:**
>
> - **Why**: Do not infer or state reasons, causes, or motivations
> - **So what**: Do not state significance, implications, or consequences
>
> **Grouping:**
>
> - Group facts that belong to the same situation into one context unit
> - State which axis was the primary basis for grouping (the "まとめ軸")
> - The grouping axis varies by situation type — What may be primary for structural conditions, When for time-sensitive events, How for process patterns
>
> **Observable attitudes:**
>
> - Attitudes or behavioral patterns that are directly backed by verbatim quotes may be included as What entries
> - Example: "地方での実用性に懐疑的だった" is valid if a verbatim quote supports it
> - Attitudes that require inferring mental states beyond what was said or done must NOT be included
>
> **Output format:**
>
> ```
> ### Case [X]: コンテキスト記述
>
> | # | まとめ軸 | What | When | Where | Who | How | 出典 |
> |---|---|---|---|---|---|---|---|
> | X-C1 | [axis] | ... | ... | ... | ... | ... | X1, X3 |
> | X-C2 | [axis] | ... | ... | ... | ... | ... | X2, X5, X7 |
> ```
>
> - Identifier format: `{Case}-C{Number}` (e.g., A-C1, B-C1)
> - Use `—` for axes with no applicable information
> - Cite Fact identifiers in the 出典 column as plain text: `A1, A3` (no link syntax)
>
> Rules:
>
> - No inference of emotions or motivations not evidenced by quotes or observable behavior
> - Every fact from the Fact Table should appear in at least one context unit's 出典 column. If a fact doesn't fit any context unit, create a standalone entry for it
> - Do NOT include file paths, plan references, or any external file references in your output

#### Phase A Review (main conversation)

Before proceeding to Phase B, verify the per-case context descriptions:

1. **Fact coverage**: Check that every fact from the Fact Table appears in at least one context unit's 出典 column. List any missing facts
2. **Axis accuracy**: Verify that What describes observable conditions/events (not interpretations), and that no Why/So what has crept into any axis
3. **Grouping coherence**: Check whether any context units should be split (unrelated facts grouped) or merged (same situation split across units)

If issues are found, revise the Phase A outputs before proceeding.

**→ Confirmation Gate**: Present Phase A output for user approval. After approval, replace `{{CONTEXT_DESCRIPTIONS}}` in the appendix file.

---

### Phase B — Direct route (2–10 cases): Integrated Grouping + Comparison

> **Route guard**: This section runs only in the Direct route (2–10 cases). For Scaffolded route (11+ cases), skip to Phase B — Scaffolded route below.

**Input from appendix**: Fact Tables + Background/Events. NO context descriptions (Phase A is skipped).

Launch a single subagent. The subagent receives the appendix file (Fact Tables + Background/Events sections only). It does NOT receive the main report header — this ensures the analysis is RQ-free.

**Output containment**: Subagent output must NOT include file paths, plan references, or any external file references. All output will be written to a temporary analysis file and must be self-contained.

#### Subagent Prompt (Direct route)

> You are a qualitative researcher. From the Fact Tables and Background/Events below, group related facts into context units per case, then compare across cases to identify shared situational patterns.
>
> **Step 0: Per-case Context Grouping**
>
> For each case, group related facts into **context units** (a set of facts that together describe one situation) and describe each using 5W1H axes.
>
> A "context unit" is a set of facts that together describe one situation — a condition, event, or pattern in the person's environment.
>
> **Axes to describe:**
>
> - **What**: What happened or what condition existed (observable)
> - **When**: When it happened or when the condition existed (time period, phase, or relative timing)
> - **Where**: Where it happened (location, setting, channel)
> - **Who**: Who was involved (actors, stakeholders, sources)
> - **How**: How it happened or how the condition manifested (mechanism, channel, method)
>
> **Do NOT describe:**
>
> - **Why**: Do not infer or state reasons, causes, or motivations
> - **So what**: Do not state significance, implications, or consequences
>
> **Grouping:**
>
> - Group facts that belong to the same situation into one context unit
> - State which axis was the primary basis for grouping (the "まとめ軸")
> - The grouping axis varies by situation type — What may be primary for structural conditions, When for time-sensitive events, How for process patterns
>
> **Observable attitudes:**
>
> - Attitudes or behavioral patterns that are directly backed by verbatim quotes may be included as What entries
> - Example: "地方での実用性に懐疑的だった" is valid if a verbatim quote supports it
> - Attitudes that require inferring mental states beyond what was said or done must NOT be included
>
> Per-case output format:
>
> ```
> ### Case [X]: コンテキスト記述
>
> | # | まとめ軸 | What | When | Where | Who | How | 出典 |
> |---|---|---|---|---|---|---|---|
> | X-C1 | [axis] | ... | ... | ... | ... | ... | X1, X3 |
> | X-C2 | [axis] | ... | ... | ... | ... | ... | X2, X5, X7 |
> ```
>
> - Identifier format: `{Case}-C{Number}` (e.g., A-C1, B-C1)
> - Use `—` for axes with no applicable information
> - Cite Fact identifiers in the 出典 column as plain text: `A1, A3` (no link syntax)
> - Every fact from the Fact Table should appear in at least one context unit's 出典 column. If a fact doesn't fit any context unit, create a standalone entry for it
>
> **Critical**: You are grouping ALL cases yourself. Maintain consistent granularity across cases — similar situations should produce similar-sized context units regardless of case.
>
> **Step 1: Inventory**
>
> Extract and list ALL context units from each case to create an inventory:
>
> ```
> | # | Case A | Case B | Case C | ... |
> |---|---|---|---|---|
> | What | [list each context unit's What] | ... | ... | ... |
> ```
>
> This inventory is your **completeness reference** — every item listed here must be accounted for in the comparison output.
>
> **Step 2: Cross-case Comparison**
>
> 1. For each context unit, compare its 5W1H axes across cases
> 2. Judge commonality per axis:
>    - **一致**: Same or essentially identical across cases
>    - **部分一致**: Same direction/category but different specifics (e.g., Who = "業界関係者" but different specific relationships)
>    - **分岐**: Different across cases
>    - **—**: Axis not applicable or no data
> 3. Group context units that share commonality in **one or more axes** into candidate common contexts
> 4. For each candidate, propose an **abstraction label** that captures the common pattern (e.g., Who axis: "同市場の別現場" + "経営者研修の参加者" + "同業他社" → "業界関係者")
>
> **Step 3: Validation**
>
> **IMPORTANT: Go back to the original Fact Tables independently before validating. Do NOT rely solely on the context descriptions.**
>
> 1. **Abstraction check**: For each proposed abstraction label, verify that it accurately represents all cases' specifics without over-generalizing. "Any business that needs staff" is too vague; "業界関係者からの口コミ" is appropriately specific
> 2. **Completeness verification**: Compare the inventory (Step 1) against the comparison output:
>    - For each context unit in the inventory, verify it appears in at least one common context OR is explicitly noted as case-specific
>    - List any inventory items that were NOT reflected in any common context
>    - **Items that appear in 2+ cases' inventories but are absent from the comparison output are HIGH PRIORITY gaps**
>
> **Output Format**
>
> Part 1 — Per-case context descriptions (one `### Case [X]: コンテキスト記述` table per case, as produced in Step 0).
>
> Part 2 — Cross-case comparison.
>
> Summary table:
>
> ```
> | ID | 共通パターン | 該当 | What | When | Where | Who | How |
> |---|---|---|---|---|---|---|---|
> | CC-1 | [abstraction label] | N/N | [一致/部分一致/分岐/—] | ... | ... | ... | ... |
> ```
>
> For each CC, a detail table with representative verbatim quotes:
>
> ```
> #### CC-1: [共通パターン]
>
> | 軸 | 共通度合い | 共通パターン | Case A | Case B | Case C |
> |---|---|---|---|---|---|
> | What | 一致 | [common] | [specific] | [specific] | [specific] |
> | When | 部分一致 | [common] | [specific] | [specific] | [specific] |
> | Who | 分岐 | — | [specific] | [specific] | [specific] |
> | ... | | | | | |
>
> > A: 「[verbatim quote]」(A4)
> > B: 「[verbatim quote]」(B7)
> > C: 「[verbatim quote]」(C5)
>
> 出典: A-C1 (A4, A5), B-C3 (B7, B8, B9), ...
> ```
>
> **Verbatim quote selection rule**: For each case, select the single most concrete verbatim quote (the one with the lowest level of abstraction) from the context unit's source facts. One quote per case.
>
> Case-specific context units (not part of any CC) are listed separately at the end.
>
> Rules:
>
> - No inference of emotions or motivations not evidenced by quotes or observable behavior
> - Do NOT include file paths, plan references, or any external file references in your output
> - Do NOT infer Why or So what — describe observable patterns only
> - Do NOT over-abstract — each abstraction label must be traceable to the concrete cases

#### Phase B Review — Direct route (main conversation)

After the subagent returns, the main conversation performs the following checks:

1. **Frame blindness check** (requires FRAME_AWARENESS from main report header):
   - Compare the subagent's common contexts against the Frame Awareness section
   - Are there facts in the Fact Tables that do NOT appear in ANY common context? These omissions may indicate RQ-driven blind spots
   - Flag as HIGH PRIORITY if found
   - If blind spots are detected, consider whether additional CC entries should be added
2. **Output review**: Verify the subagent output is well-formed and complete

**→ Confirmation Gate**: Present Phase B output (with any frame blindness findings) for user approval. After approval:

- Extract Part 1 (per-case context descriptions: `### Case [X]: コンテキスト記述` sections) → replace `{{CONTEXT_DESCRIPTIONS}}` in the appendix file
- Extract Part 2 (CC summary table + detail tables) → replace `{{COMMON_CONTEXTS}}` in the main report file
- **Both placeholders are replaced simultaneously** (Atomic replacement rule)
- Boundary: Part 1 ends at the last case's context description table. Part 2 starts at the inventory table (Step 1 output)

---

### Phase B — Scaffolded route (11+ cases): Cross-case Comparison → Common Context Extraction

**Input from appendix**: Fact Tables + Context Descriptions (Phase A output as reference).

Launch a single subagent for cross-case comparison. The subagent receives **only** the appendix file (Context Descriptions + Fact Tables). It does NOT receive the main report header — this ensures the comparison is RQ-free.

**Output containment**: Subagent output must NOT include file paths, plan references, or any external file references. All output will be written to a temporary analysis file and must be self-contained.

#### Subagent Prompt

> You are a qualitative researcher. Compare the per-case context descriptions below to identify shared situational patterns across cases.
>
> Per-case context descriptions are provided as suggested groupings. Use them as a scaffold to reduce initial effort, but derive your cross-case comparison from the original Fact Tables. If the suggested groupings do not align well across cases, regroup from the source facts.
>
> **Step 1: Inventory**
>
> Extract and list ALL context units from each case to create an inventory:
>
> ```
> | # | Case A | Case B | Case C | ... |
> |---|---|---|---|---|
> | What | [list each context unit's What] | ... | ... | ... |
> ```
>
> This inventory is your **completeness reference** — every item listed here must be accounted for in the comparison output.
>
> **Step 2: Cross-case Comparison**
>
> 1. For each context unit, compare its 5W1H axes across cases
> 2. Judge commonality per axis:
>    - **一致**: Same or essentially identical across cases
>    - **部分一致**: Same direction/category but different specifics (e.g., Who = "業界関係者" but different specific relationships)
>    - **分岐**: Different across cases
>    - **—**: Axis not applicable or no data
> 3. Group context units that share commonality in **one or more axes** into candidate common contexts
> 4. For each candidate, propose an **abstraction label** that captures the common pattern (e.g., Who axis: "同市場の別現場" + "経営者研修の参加者" + "同業他社" → "業界関係者")
>
> **Step 3: Validation**
>
> **IMPORTANT: Go back to the original Fact Tables independently before validating. Do NOT rely solely on the context descriptions.**
>
> 1. **Abstraction check**: For each proposed abstraction label, verify that it accurately represents all cases' specifics without over-generalizing. "Any business that needs staff" is too vague; "業界関係者からの口コミ" is appropriately specific
> 2. **Completeness verification**: Compare the inventory (Step 1) against the comparison output:
>    - For each context unit in the inventory, verify it appears in at least one common context OR is explicitly noted as case-specific
>    - List any inventory items that were NOT reflected in any common context
>    - **Items that appear in 2+ cases' inventories but are absent from the comparison output are HIGH PRIORITY gaps**
>
> **Output Format**
>
> Summary table:
>
> ```
> | ID | 共通パターン | 該当 | What | When | Where | Who | How |
> |---|---|---|---|---|---|---|---|
> | CC-1 | [abstraction label] | N/N | [一致/部分一致/分岐/—] | ... | ... | ... | ... |
> ```
>
> For each CC, a detail table with representative verbatim quotes:
>
> ```
> #### CC-1: [共通パターン]
>
> | 軸 | 共通度合い | 共通パターン | Case A | Case B | Case C |
> |---|---|---|---|---|---|
> | What | 一致 | [common] | [specific] | [specific] | [specific] |
> | When | 部分一致 | [common] | [specific] | [specific] | [specific] |
> | Who | 分岐 | — | [specific] | [specific] | [specific] |
> | ... | | | | | |
>
> > A: 「[verbatim quote]」(A4)
> > B: 「[verbatim quote]」(B7)
> > C: 「[verbatim quote]」(C5)
>
> 出典: A-C1 (A4, A5), B-C3 (B7, B8, B9), ...
> ```
>
> **Verbatim quote selection rule**: For each case, select the single most concrete verbatim quote (the one with the lowest level of abstraction) from the context unit's source facts. One quote per case.
>
> Case-specific context units (not part of any CC) are listed separately at the end.
>
> Rules:
>
> - Do NOT include file paths, plan references, or any external file references in your output
> - Do NOT infer Why or So what — describe observable patterns only
> - Do NOT over-abstract — each abstraction label must be traceable to the concrete cases

#### Phase B Review (main conversation)

After the subagent returns, the main conversation performs the following checks:

1. **Frame blindness check** (requires FRAME_AWARENESS from main report header):
   - Compare the subagent's common contexts against the Frame Awareness section
   - Are there facts in the Fact Tables that do NOT appear in ANY common context? These omissions may indicate RQ-driven blind spots
   - Flag as HIGH PRIORITY if found
   - If blind spots are detected, consider whether additional CC entries should be added
2. **Output review**: Verify the subagent output is well-formed and complete

**→ Confirmation Gate**: Present Phase B output (with any frame blindness findings) for user approval. After approval, replace `{{COMMON_CONTEXTS}}` in the main report file.

---

## Single-case Behavior

When only one case exists, skip Phase B (cross-case comparison). Produce the per-case context description (Phase A) only. Replace `{{COMMON_CONTEXTS}}` with a note indicating single-case analysis (e.g., "単一ケース分析のため、クロスケース比較は省略").
