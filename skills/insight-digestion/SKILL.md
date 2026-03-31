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

### 2. Map Situations

For each significant fact, define the situation across three dimensions:

- **Physical**: Where and when it happened, what tools or products were involved
- **Social**: Who else was involved, what roles or relationships were at play
- **Emotional**: What emotion did the interviewee express in their own words (from Step 1 verbatims)? If no emotion word appears in the verbatim, describe the observable tone or behavior only (e.g., "described the situation matter-of-factly")

**→ Self-review each Emotional cell: verify every emotion word traces back to a specific verbatim in Step 1. Remove or downgrade any label that exceeds the interviewee's own vocabulary. Then present the situation map for user approval.**

### 3. Identify Key Moments

From the situations, identify moments matching the **moment label** defined in Step 0. Use the **detection signals** from Step 0 as your filter criteria.

**→ Self-review the identified moments against the situation map for consistency, then present for user approval on which to pursue.**

### 4. Analyze Demand Forces

For each selected moment from Step 3, map the Four Forces of demand:

- **Push**: Dissatisfaction with current solution driving change
- **Pull**: Attraction toward the desired new behavior or outcome
- **Anxiety**: Fear or uncertainty about switching
- **Habit**: Attachment to the current way of doing things

### 5. Define the Job

Write a Job Statement in canonical form:

> When [situation], I want to [motivation], so that [expected progress].

The statement must trace back to specific facts from Step 1 and key moments from Step 3.

## Strict Rules

- Do not propose or suggest solutions — this skill is demand-side analysis only
- Do not skip from facts (Step 1) to job definition (Step 5)
- Do not proceed past a confirmation gate (→) without user approval
- Do not treat customer opinions or stated preferences as behavioral facts
- Do not score, rank, or prioritize — that belongs to experiment design
- NEVER ask the user to verify completeness — always perform self-review against the source material before presenting results at any confirmation gate
- NEVER assign emotion labels stronger than the interviewee's own words — always trace back to Step 1 verbatims (e.g., "悩ましい" must not become "frustration"; "抵抗感" must not become "fear")

## Completion

This skill is complete when all three conditions are met:

- A Job Statement exists that the user confirms as accurate
- The statement is traceable to at least one specific fact and one key moment from Step 3
- The user is ready to proceed to experiment design, or explicitly stops
