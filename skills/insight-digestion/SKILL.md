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

**→ Present the chosen moment label and detection signals to the user. Confirm before proceeding.**

### 1. Extract Facts

List observable behaviors and verbatim quotes. Separate what happened from why it happened.

Output as a table:

| #   | Who | What they did / said (verbatim) | Context (when, where) |
| --- | --- | ------------------------------- | --------------------- |

For lengthy source material, process in chunks and present facts incrementally.

**→ Present the table to the user. Confirm completeness before proceeding.**

### 2. Map Situations

For each significant fact, define the situation across three dimensions:

- **Physical**: Where and when it happened, what tools or products were involved
- **Social**: Who else was involved, what roles or relationships were at play
- **Emotional**: What frustration, anxiety, or desire was present
  - ALWAYS cite the source fact number (e.g., "based on #12") for each emotional description
  - If no verbatim quote or observable behavior supports the emotion, write "Not evident from data"

After completing the situation map, perform a coverage check:

1. List all fact numbers from Step 1
2. Mark which facts are included in Step 2 and which are excluded
3. For each excluded fact, state the reason for exclusion in one line

**→ Present the situation map and coverage check to the user. Confirm before proceeding.**

### 3. Identify Key Moments

From the situations, identify moments matching the **moment label** defined in Step 0. Use the **detection signals** from Step 0 as your filter criteria.

**→ Present the identified moments. Confirm with the user which ones to pursue.**

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
- Do not attribute emotions, motivations, or internal states unless directly supported by a verbatim quote or observable behavior from Step 1
- Do not score, rank, or prioritize — that belongs to experiment design

## Completion

This skill is complete when all three conditions are met:

- A Job Statement exists that the user confirms as accurate
- The statement is traceable to at least one specific fact and one key moment from Step 3
- The user is ready to proceed to experiment design, or explicitly stops
