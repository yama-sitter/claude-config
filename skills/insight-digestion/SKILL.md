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
   - **Moment label**: The type of moment Step 3 will search for
   - **Detection signals**: The specific behavioral signals to look for in Step 3
   - **RQ components**: The key elements the RQ requires data for (e.g., "situation before first use", "expectation-reality gap", "2nd use trigger situation")

| Question Type        | Moment Label             | Example Detection Signals                                                                        |
| -------------------- | ------------------------ | ------------------------------------------------------------------------------------------------ |
| Switch / Acquisition | Struggling moments       | Workarounds, resignation, switching behavior, unmet expectations                                 |
| Retention / Loyalty  | Expectation-reality gaps | Positive surprises, habitual rituals, moments of delight, disappointment after high expectations |
| Churn / Cancellation | Departure triggers       | Accumulating friction, broken promises, competitive pull, last-straw events                      |

The table above is a reference. For questions that don't fit these types, define a custom moment label and detection signals collaboratively with the user.

**→ Self-review the alignment between research question and chosen signals, then present for user approval.**

### 1. Extract Facts

List observable behaviors and verbatim quotes. Separate what happened from why it happened.

Output as a table:

| #   | Who | What they did / said (verbatim) | Context (when, where) |
| --- | --- | ------------------------------- | --------------------- |

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

> **Background**
> Facts: [Fact numbers]
> Summary: [Structural conditions — the person's business environment, ongoing constraints, resource limitations]
>
> **Chronological Events** > [Fact numbers in time order with brief period labels]

For large fact sets (30+ facts): Launch a subagent, then self-review for completeness.

**→ Self-review two things, then present for user approval:**

1. **Coverage**: Every fact from Step 1 is placed in either Background or Chronological Events
2. **Data sufficiency**: Each RQ component (defined in Step 0) has specific, concrete data. Report any component where data is thin or absent.

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

> ### A. Hire-time Situation (material for Job Statement "When" clause)
>
> | # | Common context | Case A evidence | Case B evidence | Discrepancies |
>
> ### B. Stances arising from the situation (material for Forces analysis)
>
> | # | Stance | Derived from (A#) | Case A evidence | Case B evidence |
>
> ### C. Post-experience changes (material for Re-hire / retention analysis)
>
> | # | Change | Case A | Case B |

**→ Present the final table for user approval. Confirm: Are the A/B/C classifications appropriate? Is the abstraction level right? Are any common contexts missing?**

**Single-case behavior**: When only one case exists, skip the Comparator. Run Narrator + Critic only, and output a single-case context description. Cross-case synthesis happens when additional cases are added.

### 4. Analyze Demand Forces

Map the common contexts from Step 3 onto Four Forces to construct an integrated narrative of the Switch dynamics. This is the first step where **interpretation** (fact-grounded inference) is permitted.

**Input**:

- Primary: Step 3 output (A/B/C + discrepancy notes) — the common patterns are the analysis target
- Supporting: Fact Table — for evidence strength judgment only, not for discovering new Forces

**Process**: Execute directly in the main conversation (no subagents). Forces analysis involves interpretation and should be built through dialogue with the user.

**Steps**:

1. **Compose Hire-time Forces diagram**: Map Step 3 A/B items to Push/Pull/Anxiety/Habit. Cite Fact numbers as evidence for each Force.
2. **Write integrated narrative**: Describe the Forces as one story — how they interacted to produce the Switch. Not a list of individual Forces, but their interplay (e.g., "Strong Push from channel failure, combined with low Anxiety from minimal expectations, enabled a rapid trial").
3. **Judge relative strength**: Determine whether the Switch was Push-dominant or Pull-dominant, using three axes:
   - Scale of action (immediate response vs. deliberation period)
   - Urgency of expression (verbatim quotes indicating urgency or calm)
   - Behavioral magnitude (how much the person changed their operations)
4. **Describe Re-hire Forces change**: How did Forces shift from first Hire to Re-hire? If data is thin (common for Re-hire), state the constraint explicitly.

**Output format**:

> ### Hire-time Forces
>
> | Force   | Content | Evidence  | Strength             |
> | ------- | ------- | --------- | -------------------- |
> | Push    | ...     | A#, Fact# | Strong/Moderate/Weak |
> | Pull    | ...     | A#, Fact# | ...                  |
> | Anxiety | ...     | B#, Fact# | ...                  |
> | Habit   | ...     | B#, Fact# | ...                  |
>
> **Integrated narrative**: [1 paragraph describing Force interplay] > **Dominant Force**: [Push-dominant / Pull-dominant / Balanced + rationale]
>
> ### Re-hire Forces change
>
> [How Forces shifted from first Hire to Re-hire. Note data constraints.]

**→ Present for user approval.**

### 5. Define the Job (Hypothesis)

Synthesize the common context (Step 3) and Forces analysis (Step 4) into a Job Statement. This is a **hypothesis** — it requires validation before acting on it.

**Input**:

- Step 3 A (When clause material)
- Step 4 integrated narrative + Push/Pull (primary source for motivation)
- Step 1 Facts (for evidence verification)

**Steps**:

1. **When clause**: Integrate Step 3 A common contexts into 1-2 sentences describing the shared situation
2. **Motivation (I want to)**: Derive from Step 4's Push/Pull integrated narrative at the common-pattern level. Push inversion = what they want to escape. Pull direction = what they want to achieve.
3. **Expected progress (so that)**: Derive from Step 4's narrative + Fact-based goal statements
4. **Traceability**: Document which Facts, Step 3 items, and Step 4 Forces inform each clause
5. **Hypothesis constraints**: State explicitly that this Job is a hypothesis. List conditions for validity and what needs verification.

**Output format**:

> ### Job Statement (Hypothesis)
>
> > When [situation],
> > I want to [motivation],
> > so that [expected progress].
>
> ### Traceability
>
> | Clause    | Evidence                 |
> | --------- | ------------------------ |
> | When      | Step 3 A#, A#, ...       |
> | I want to | Step 4 Push/Pull + Facts |
> | So that   | Step 4 narrative + Facts |
>
> ### Hypothesis constraints
>
> - [Conditions, verification needs]

**→ Present for user approval. Verify that each clause has factual grounding and appropriate abstraction level.**

### 6. Answer RQ + Findings

Synthesize Steps 3-5 into a structured answer to the Research Question and present analysis findings.

**Input**: Step 3 (A/B/C) + Step 4 (Forces) + Step 5 (Job) + Step 0 (RQ)

**Process**: Execute directly in the main conversation (all Step outputs are already in the conversation context).

**Output**:

> ### RQ Answer
>
> **RQ**: [from Step 0] > **Answer**: [1 paragraph integrating the factual causal chain (Step 3), Force dynamics (Step 4), and Job hypothesis (Step 5)]
>
> ### Hypothesis alignment
>
> - Aligned: [...]
> - Diverged: [...]
> - Unpredicted patterns: [...]
>
> ### Cross-case differences
>
> [Case-specific dynamics not explained by common patterns]
>
> ### Unresolved questions
>
> - [List of questions for further investigation]
>
> ### Input for next actions
>
> - Job hypothesis to validate: [from Step 5]
> - Recommended validation approaches: [...]

**→ Present for user approval. Determine whether analysis is complete or additional investigation is needed.**

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
