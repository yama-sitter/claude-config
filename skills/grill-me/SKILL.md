---
name: grill-me
description: |
  Relentless interviewing that stress-tests plans and designs through systematic questioning.
  Walks down each branch of the design tree, resolving dependencies between decisions one-by-one.
  Use when: you have a rough idea or plan and want to drill into it through aggressive questioning before implementation.
  Do not use when: you want a structured design process with formal approach proposals and section-by-section approval (-> brainstorm).
user-invocable: true
args: "[topic or plan]"
---

# Grill Me — Relentless Design Interviewing

Interview the user relentlessly about every aspect of their plan until you reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. Ask questions one at a time. If a question can be answered by exploring the codebase, explore the codebase instead of asking.

If a topic or plan is provided as an argument, begin questioning immediately from that starting point. If nothing is provided, ask what they want to explore.

## Question Format

For each question, provide your recommended answer with reasoning. At decision points where multiple valid approaches exist, present options with trade-offs and mark your recommendation.

## Exit Condition

Propose ending the questioning phase when:

- All major branches of the design tree have been explored
- Dependencies between decisions are resolved
- Enough specificity exists to begin implementation

Present a brief summary of the shared understanding and confirm with the user.

## Transition

After the user confirms shared understanding, present these options:

1. Proceed to implementation directly
2. Enter Plan Mode (EnterPlanMode) for formal planning
3. Save to agent-memory and end session

If questioning was extensive or the change scope is large, recommend option 2 or 3.

## Strict Rules

- Ask only one question per message
- Do not ask questions answerable by exploring the codebase — explore it yourself
- Do not produce design documents or formal specs (use brainstorm for that)
- Do not proceed to the next question without the user's response
- Do not skip the transition choice — always present options when questioning is complete

## Completion

This skill is complete when the user has chosen a transition option and that transition has been executed.

## Attribution

Based on [grill-me](https://github.com/mattpocock/skills) by Matt Pocock.
Copyright (c) 2026 Matt Pocock. MIT License.
