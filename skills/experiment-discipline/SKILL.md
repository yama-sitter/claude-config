---
name: experiment-discipline
description: |
  Transform digested insights into testable hypotheses and design minimum-cost experiments.
  Use when you have a JTBD from insight-digestion and need to decide what to test next.
  Do not use when the problem space is still unclear (use insight-digestion first),
  or when the task is implementation, investigation, or code changes.
user-invocable: true
---

# Experiment Discipline

Convert insights into prioritized experiments that maximize learning at minimum cost.
Focus on which metric to move, not what to build.

## Prerequisites

- A JTBD statement produced by insight-digestion exists (in the form: "When [situation], I want to [motivation], so that [expected progress]")
- If no JTBD exists, stop and direct the user to run insight-digestion first

## Workflow

### 1. Confirm Target Outcome

- Identify which stage of the pirate metrics (AARRR: Acquisition, Activation, Retention, Revenue, Referral) the JTBD relates to
- Define a single measurable outcome (metric + current baseline + target) the experiment aims to move
- If the user cannot provide a baseline, acknowledge the gap and note "baseline TBD" as the first thing to measure

**Output:** One sentence: "We aim to move [metric] from [baseline] to [target] by addressing [JTBD summary]."

**→ Confirm the target outcome with the user before proceeding.**

### 2. Build Opportunity Solution Tree

- List opportunities (unmet needs or pain points) that, if resolved, would move the target metric
- Under each opportunity, brainstorm 2-3 candidate solutions

**Output as a table:**

| Opportunity | Solution A | Solution B | Solution C |
|---|---|---|---|

**→ Ask the user which opportunities to carry forward to prioritization.**

### 3. Prioritize with ICE Scoring

Score each carried-forward solution on a 1-10 scale:

- **Impact** (1-10): How much will this move the target metric? (1 = negligible, 5 = moderate improvement, 10 = step-change)
- **Confidence** (1-10): How sure are we this will work? (1 = pure guess, 5 = analogous evidence, 10 = validated data)
- **Ease** (1-10): How cheaply can we test this? (1 = months of dev, 5 = days of work, 10 = hours or no-code)

**Output as a table:**

| Solution | I | C | E | Score (I x C x E) | Justification |
|---|---|---|---|---|---|

**→ Review scores with the user. Adjust before selecting the top experiment.**

### 4. Design Experiment Card

For the top-scoring solution, produce a structured experiment card:

- **Hypothesis:** If we [action], then [metric] will [change], because [rationale].
- **Target metric:** [metric name] from [baseline] to [success threshold]
- **Minimum viable test:** The cheapest way to validate (e.g., wizard-of-oz, fake door, landing page, concierge, A/B test)
- **Cost axis:** [dev effort in days] / [monetary cost] / [time to result]
- **Decision rule:** If [metric] reaches [threshold] within [timeframe], proceed to full build. Otherwise, pivot or kill.

Optionally, if the experiment involves changing user behavior, apply the Hook model (Trigger-Action-Variable Reward-Investment) or Fogg behavior model (Motivation-Ability-Prompt) to design the intervention.

## Completion

This skill is complete when:

- One experiment card with hypothesis, metric, success criteria, and minimum viable test is produced
- The user has confirmed the experiment card

## Strict Rules

- Do not skip opportunity mapping and jump straight to solutions
- Do not finalize ICE scores without user review
- Do not propose a full product build as the "minimum viable test"
- Do not proceed past a pause point (→) without user confirmation
- Do not define success criteria without a concrete metric and threshold
