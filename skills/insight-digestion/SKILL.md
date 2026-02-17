---
name: insight-digestion
description: |
  Extract Jobs-to-be-Done from customer behavior facts, interview logs, or feedback data.
  Use when the user provides raw customer data and wants to understand the underlying demand structure before designing solutions.
  Do not use when the user already has a clear hypothesis and wants to design experiments (use experiment-discipline instead).
  Do not use when the user wants to brainstorm or evaluate solutions.
user-invocable: true
---

# Insight Digestion

Digest raw customer data into a structured Job-to-be-Done by climbing the Ladder of Inference one rung at a time.

## Prerequisites

- Customer interview logs, behavior data, or feedback are accessible
- This skill produces demand-side analysis only — output feeds into experiment-discipline

## Workflow

### 1. Extract Facts

List observable behaviors and verbatim quotes. Separate what happened from why it happened.

Output as a table:

| # | Who | What they did / said (verbatim) | Context (when, where) |
|---|-----|---------------------------------|------------------------|

For lengthy source material, process in chunks and present facts incrementally.

**→ Present the table to the user. Confirm completeness before proceeding.**

### 2. Map Situations

For each significant fact, define the situation across three dimensions:

- **Physical**: Where and when it happened, what tools or products were involved
- **Social**: Who else was involved, what roles or relationships were at play
- **Emotional**: What frustration, anxiety, or desire was present

### 3. Identify Struggling Moments

From the situations, identify moments where existing solutions fail. Look for:

- Workarounds the customer has invented
- Complaints or resignation ("I just gave up and...")
- Switching behavior between competing solutions
- Unmet expectations explicitly stated

**→ Present the struggling moments. Confirm with the user which ones to pursue.**

### 4. Analyze Demand Forces

For each selected struggling moment, map the Four Forces of demand:

- **Push**: Dissatisfaction with current solution driving change
- **Pull**: Attraction toward the desired new behavior or outcome
- **Anxiety**: Fear or uncertainty about switching
- **Habit**: Attachment to the current way of doing things

### 5. Define the Job

Write a Job Statement in canonical form:

> When [situation], I want to [motivation], so that [expected progress].

The statement must trace back to specific facts from Step 1 and struggling moments from Step 3.

## Strict Rules

- Do not propose or suggest solutions — this skill is demand-side analysis only
- Do not skip from facts (Step 1) to job definition (Step 5)
- Do not proceed past a confirmation gate (→) without user approval
- Do not treat customer opinions or stated preferences as behavioral facts
- Do not score, rank, or prioritize — that belongs to experiment-discipline

## Completion

This skill is complete when all three conditions are met:

- A Job Statement exists that the user confirms as accurate
- The statement is traceable to at least one specific fact and one struggling moment
- The user is ready to proceed to experiment-discipline, or explicitly stops
