---
name: plan-template
description: |
  Plan structure and writing rules for Plan Mode.
  ALWAYS load this skill before writing any plan in Plan Mode.
  Defines required sections, verification criteria format, self-containment rules, and design decision points.
---

# Plan Template

## Writing Style

Use concrete, specific language — no vague expressions ("consider", "handle appropriately"). One idea per sentence, kept short. State what you will do, not what you will consider.

## Required Sections

1. **Goal** — target state in 1-3 lines. Separate from Context (why)
2. **Context** — why this change is needed
3. **Approach** — how the goal will be achieved; use a table when multiple components are involved
4. **Changes** — Summary table (Operation | File | What changes | Why), Affected surrounding areas, Not changing
5. **Verification** — acceptance criteria table (`# | Criterion | Command | Expected`). At least 2 criteria, at least 1 with an automated command runnable from the project root. Expected results must be concrete enough for an independent evaluator (`/verify`) to judge pass/fail
6. **Risks and Mitigations** (table, optional) — omit if there are no meaningful risks
7. **Investigation Scope** — Files read, Files not read but potentially affected. No catch-all entries ("other files") — list specific paths
8. **Change Details** — per-file breakdown supplementing the summary table; place ordering constraints here only when order matters

## Self-Containment Rule

Never reference a research/analysis/test-plan custom ID (e.g. `U\d+`, `RQ\d+`, `X-?\d+`) without including its body text in the same plan file — the plan must be understandable after the originating conversation is compacted or lost. Expand all such references before saving to agent-memory.

Out of scope: code identifiers, file paths, external IDs (cite the URL instead).

## Design Decision Points

Apply during plan creation and implementation. Stop and present the decision to the user instead of deciding independently when any trigger condition is met:

- Multiple reasonable implementation approaches exist
- Deviating from an existing codebase pattern is necessary
- Error handling or edge case strategy is not obvious from context
- A trade-off exists between competing concerns
- Implementation is becoming more complex than initially expected, or impact scope is growing beyond the original plan

Present as:

```
### Design Decision: [topic]
[What needs to be decided — one sentence]
- **A)** [option and its concrete outcome]
- **B)** [option and its concrete outcome]
[Trade-offs — brief]
```

Only ask when the decision genuinely matters — not when either option is fine. During implementation, if a new decision point emerges that wasn't visible during planning, stop and present it before proceeding.

This is separate from the `brainstorm` skill (design-phase dialogue, approach selection) — don't re-ask decisions already made there. Keep separate from `grill-me` as well; for high-complexity plans, note that `/grill-me` can stress-test the plan.

## Scaling

3 or fewer files changed AND following existing patterns → Context, Summary table, and Verification only; other sections may be omitted. All other cases → all sections required.
