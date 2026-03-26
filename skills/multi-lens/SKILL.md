---
name: multi-lens
description: |
  Evaluate a subject from 4 personality-based perspectives (Pragmatist/Skeptic/Idealist/Connector).
  Use when: brainstorming, multi-perspective evaluation, organizing thoughts, decision analysis, comparing options.
  Do not use when: uncovering human motives from qualitative data (->insight-craft), improving Claude's responses (->criticize), fixing Claude Code behavior (->kaizen).
  Subcommands:
    - (default): 4-perspective evaluation -> synthesis -> conclusion -> next actions
    - `debate`: Inter-perspective debate based on previous evaluation -> re-synthesis -> conclusion
user-invocable: true
args: "[subcommand] <subject>"
---

# Multi-Lens — Personality-Based Multi-Perspective Evaluation

Evaluate a subject from 4 personality-based perspectives. Each personality has an independent thinking orientation and analyzes the subject based on its core question.

Personalities operate as "thinking tendencies," not "roles."

## Strict Rules

- This evaluation format is applied only when `/multi-lens` is explicitly invoked
- After `/multi-lens` execution completes, subsequent conversation returns to normal responses. Do not carry the 4 personality perspectives into follow-up responses
- Only `/multi-lens debate` continues by referencing the previous evaluation results

## Argument Routing

| Args | Action |
|------|--------|
| `<subject>` | Evaluation mode: 4-perspective evaluation -> synthesis -> conclusion -> next actions |
| `debate` | Debate mode: 2 rounds of debate based on previous evaluation results -> re-synthesis -> conclusion |

## Evaluation Mode

### Workflow

1. Receive the subject
2. Launch 4 subagents in parallel (Agent tool, subagent_type=general-purpose). Pass the subject and one personality definition to each subagent. Use the following prompt template:

```
You are an evaluator with a thinking tendency called "{personality name}."
Act as a thinking tendency, not a role.

{personality definition}

Evaluate the following subject based on your personality.
Focus on the core points and omit supplementary explanations.

Subject: {subject}
```

3. Receive the 4 evaluation results and display a concise excerpt from each perspective
4. Synthesize across all 4 evaluations
5. State the conclusion
6. Present next actions

### Personality Definitions (content passed to subagents)

**Pragmatist:**
- Core question: What is the simplest and most actionable approach?
- Focus: Eliminate complexity; judge by feasibility and cost
- Pushes back against: Over-idealization, unrealistic proposals, unnecessary complexity
- Tone: Direct and concrete. "Bottom line, here's what to do"
- Angles: Implementation cost, required resources, immediately actionable steps

**Skeptic:**
- Core question: What is being overlooked? Are the assumptions really correct?
- Focus: Uncover risks, blind spots, and implicit assumptions
- Pushes back against: Optimistic bias, unfounded certainty, unverified assumptions
- Tone: Frequent questioning. "Can you really say that for certain?"
- Angles: Implicit assumptions, failure scenarios, unverified hypotheses

**Idealist:**
- Core question: What should the ideal state be? What is the best form long-term?
- Focus: Pursue essential value and sustainability
- Pushes back against: Short-term compromises, ad-hoc responses, optimization that loses sight of the essence
- Tone: Returns to first principles. "What was the original purpose?"
- Angles: Essential purpose, long-term impact, gap between ideal and reality

**Connector:**
- Core question: What does this resemble? What else does it connect to?
- Focus: Discover analogies, pattern recognition, and connections to knowledge from other domains
- Pushes back against: Isolated local optima, ignoring context, dismissing existing knowledge
- Tone: Associative. "In the world of X, they solved the same problem with Y"
- Angles: Similar cases, cross-domain patterns, relationship to the overall system

### Output Format

```
## Multi-Lens Evaluation: [subject]

### Pragmatist
[Concise excerpt from subagent's evaluation]

### Skeptic
[Concise excerpt from subagent's evaluation]

### Idealist
[Concise excerpt from subagent's evaluation]

### Connector
[Concise excerpt from subagent's evaluation]

---

## Synthesis
- **Common ground**: Findings where multiple perspectives agree
- **Points of conflict**: Where perspectives diverge and why
- **Unresolved questions**: Important questions that remain unanswered

## Conclusion
[An overall judgment informed by all 4 perspectives, stated in 1-3 sentences.
 The conclusion need not be unanimous; present the best judgment given the conflicts]

## Next Actions
[Present applicable items]
- Questions to deepen understanding
- Hypotheses to verify
- Concrete next steps
```

## Debate Mode

### Prerequisites

A previous `/multi-lens` evaluation result must exist in the same conversation.
If none exists, reply with "Please run `/multi-lens <subject>` first" and stop.

### Workflow

1. Reference the previous `/multi-lens` evaluation results
2. Launch one debate subagent (Agent tool, subagent_type=general-purpose). Pass the 4 personality evaluations and the points of conflict/unresolved questions from the synthesis section. Use the following prompt template:

```
Below are evaluation results from 4 personality-based perspectives.

{4 evaluation results}

Points of conflict and unresolved questions from the synthesis:
{points of conflict and unresolved questions}

Starting from these points of conflict and unresolved questions, conduct 2 rounds of debate.

Round 1 (Mutual critique): Each personality responds to others in the format "PersonalityName -> PersonalityName:" with rebuttals, reinforcements, or questions. Focus on meaningful axes of disagreement. Each statement should be core points only.
Round 2 (Position revision): Each personality revises and deepens their evaluation in light of the rebuttals. Concisely state what they conceded and what they stand firm on.
```

3. Receive and display the debate results
4. Perform re-synthesis informed by the debate
5. State the conclusion
6. Present deepened next actions

### Output Format

```
## Multi-Lens Debate: [subject]

### Round 1: Mutual Critique
[Excerpt from subagent's debate results]

### Round 2: Position Revision
[Excerpt from subagent's debate results]

---

## Re-Synthesis
[What changed from the initial evaluation. Deepened understanding and overturned assumptions]

## Conclusion
[An overall judgment informed by the debate, stated in 1-3 sentences]

## Deepened Next Actions
[New questions, hypotheses, and steps that emerged from the debate]
```
