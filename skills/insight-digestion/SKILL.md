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

### 2. Reconstruct Timeline

Arrange facts from Step 1 chronologically, then group them into episodes — clusters of facts that belong together based on:

- **Temporal proximity**: Facts from the same time period
- **Causal chain**: "A led to B" relationships between facts
- **Narrative structure**: Facts the interviewee told as one continuous flow

Facts that describe ongoing structural conditions (not tied to a specific moment) go into a **Background** section.

Output format per episode:

> S[n]: [Episode name]
> Period: [When]
> Facts: [Fact numbers]
> What happened: [Factual summary using verbatim quotes where possible. No inference.]

Every fact from Step 1 must belong to at least one episode.

For large fact sets (30+ facts): Launch a subagent to reconstruct the timeline, then self-review for completeness.

**Note on semi-structured interviews**: Narrative breaks may reflect interviewer questions rather than the interviewee's own episodic grouping. Use all three clustering criteria, not just narrative structure.

**→ Self-review that every fact is covered, then present for user approval.**

### 3. Identify Key Moments and Their Situations

Scan the episodes from Step 2 for moments matching the **moment label** defined in Step 0. Use the **detection signals** as filter criteria.

For each identified moment, describe its **situation** — the context the person was in when this moment occurred:

- **What state was the person in?** (reference specific episodes and background from Step 2)
- **What was the specific trigger?** (the event or realization that made this moment significant)

The situation description must trace back to specific facts and episodes. It serves as raw material for the Job Statement's "When [situation]" clause (finalized in Step 5 after Four Forces analysis).

**→ Self-review that each moment's situation is grounded in facts (not inferred), then present for user approval on which moments to pursue.**

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
- Do not infer emotions, motivations, or states of mind not directly evidenced by verbatim quotes or observable behavior — applies to Steps 0 through 3. Step 4 (Forces analysis) permits fact-grounded inference as part of demand analysis

## Completion

This skill is complete when all three conditions are met:

- A Job Statement exists that the user confirms as accurate
- The statement is traceable to at least one specific fact and one key moment from Step 3
- The user is ready to proceed to experiment design, or explicitly stops
