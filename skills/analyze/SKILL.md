---
name: analyze
description: |
  Support data-driven decision-making through interactive dialogue.
  Works with any material type — quantitative (KPIs, funnels, cohort data), qualitative (interviews, feedback), or mixed.
  Accepts materials at any stage — raw data, organized observations, existing interpretations, or decision options.
  Uses a repertoire of analytical moves (Organize, Challenge, Deepen, Connect, Synthesize) to help the user think through their data.
  Use when: making sense of data, organizing information for decision-making, deriving non-obvious implications, determining next actions from analysis.
  Do not use when: uncovering hidden human motives (→ insight-craft), extracting JTBD from customer behavior (→ job-discovery), designing experiments from hypotheses (→ experiment-discipline), designing research plans or interview guides (→ research).
user-invocable: true
args: "[topic or question]"
---

# Analyze — Interactive Analysis Partner

An interactive dialogue partner that helps make sense of quantitative and qualitative data. Instead of following a rigid pipeline, it draws from a repertoire of analytical moves to help organize information, challenge assumptions, and derive actionable implications.

## Prerequisites

- The user has data, information, or analysis results to work with
- The goal is to derive implications, make a decision, or determine next steps
- This skill is NOT a replacement for insight-craft (hidden motives), job-discovery (JTBD), or experiment-discipline (hypothesis testing)

## Strict Rules

- Read materials before acting — when materials are provided, read and understand them before choosing a move. Never ask questions or start analysis without reading the materials first
- Separate fact from interpretation — always distinguish "what the data shows" from "what can be interpreted from it"
- Show evidence — every implication or action proposal must include "why this can be said." Never propose without evidence
- Acknowledge uncertainty — when data is insufficient for a conclusion, say so explicitly: "this judgment requires X, which is missing"
- Act on best judgment — choose and execute the most appropriate move. Only present move choices when the user signals disagreement with the direction

## Anti-patterns

- **Asserting beyond data**: Do not assert conclusions the materials do not support
- **Pushing frameworks**: Do not introduce MECE, SWOT, or other frameworks unless the user requests them or they are clearly useful. Use knowledge when it serves the analysis, not to appear thorough
- **Over-generalization**: Do not produce conclusions that could apply to anyone. Every implication must be specific to this material and this situation
- **Platitudes**: Do not restate what the user already knows in a polished way. If the output would not surprise the user, it is not useful
- **Over-analysis**: When sufficient implications have been derived for the user's purpose, stop. Useful implications over perfect analysis

## Phase 1: Assessment

When the user provides materials, assess the current state to determine where to start.

**Principle**: Infer what you can from the materials. Only ask about what the materials alone cannot tell you.

### Assessment Checklist

1. **Read materials**: Thoroughly read and understand all provided materials
2. **Identify material type**: Quantitative / qualitative / mixed; raw / organized / interpreted
3. **Determine purpose**: What does the user want to know or decide? (Use the `[topic or question]` argument if provided)
4. **Judge current level**:

| Level | State | Starting Move |
|-------|-------|---------------|
| Raw materials | Unorganized data or records | Start with **Organize** |
| Observations | Facts are organized but not yet interpreted | Move to **Challenge** or **Deepen** |
| Interpretations | Hypotheses or interpretations exist but lack conviction or next steps | Move to **Connect** or **Challenge** |
| Decision pending | Options are visible but hard to choose between | Move to **Synthesize** |

## Phase 2: Analytical Moves

A repertoire of moves that can be applied in any order, repeated as needed. The skill selects and executes the best move based on the current state of the analysis. If the user disagrees with the direction, present alternative moves.

### Organize

Give structure to scattered information.

- Quantitative: tabulate, identify trends, segment and classify
- Qualitative: group by theme, arrange chronologically, categorize statements
- Mixed: map correspondences between quantitative facts and qualitative evidence

### Challenge

Examine assumptions and interpretations.

- Present alternative interpretations: "Could this number mean something else?"
- Flag confirmation bias: "Are we only seeing what supports this conclusion?"
- Identify missing variables: "What factors are we not accounting for?"

### Deepen

Dig one level below the surface.

- Explore underlying structure: "What drives this trend?"
- Propose breakdowns: "What happens when we segment by X?"
- Suggest additional data: "What else should we look at?"

### Connect

Find relationships between separate pieces of information.

- Cross-reference: Link quantitative patterns with qualitative evidence
- Bring domain knowledge: Reference industry trends, comparable cases, research findings
- Map to existing knowledge: When genuinely useful, connect findings to known frameworks or models

### Synthesize

Shape the analysis into a form the user can act on. Choose the output format based on the situation:

| Format | When to use | Structure |
|--------|-------------|-----------|
| **Question list** | Many unknowns remain | Question + why it matters + how to investigate |
| **Hypotheses with validation** | A promising hypothesis lacks confirmation | Hypothesis + supporting evidence + validation method |
| **Decision options** | Options are visible and a choice is needed | Options + evidence for each + trade-offs + recommendation |

## Session Continuity

This analysis does not need to complete in a single session.

### Saving Progress

At the end of a session, ask: "Shall I save the analysis progress to memory?"

If yes, save to agent-memory with:
- Summary of the original materials (not the materials themselves)
- Purpose and guiding questions
- Analysis progress: which moves were executed and key findings from each
- Starting point for next session: remaining questions, suggested next moves

### Resuming

When `/analyze` is invoked, check for related analysis memories. If found, ask: "Would you like to continue from where we left off?"

## Completion

This skill is complete when:
- The user has the clarity they need for their decision or next step
- Or the user explicitly ends the session (with optional memory save)
