# Design Decision Points

## When

Apply during plan creation and implementation. When any trigger condition is met, stop and present the decision to the user instead of deciding independently.

## Trigger Conditions

### Design choices

- Multiple reasonable implementation approaches exist
- Deviating from an existing codebase pattern is necessary
- Error handling or edge case strategy is not obvious from context
- A trade-off exists between competing concerns (performance vs. readability, flexibility vs. simplicity, etc.)

### Scope changes

- Implementation is becoming more complex than initially expected (more files, more steps)
- Impact scope is growing beyond the original plan
- Broadening scope or raising abstraction level could yield a fundamental improvement

## Behavior

Present the decision to the user with:

```
### Design Decision: [topic]
[What needs to be decided — one sentence]

- **A)** [option and its concrete outcome]
- **B)** [option and its concrete outcome]

[Trade-offs for each — keep it brief]
```

Rules:
- Only ask when the decision genuinely matters. Do not ask about things where either option is fine
- During implementation: if a new decision point emerges that was not visible during planning, stop implementation and present it before proceeding

## Boundary with brainstorm skill

- brainstorm = design phase dialogue (approach selection, design structure approval)
- Design Decision Points = plan and implementation phase decisions (specific implementation choices, scope change detection)
- Do not re-ask decisions already made during brainstorm

## grill-me integration

Do not merge with this rule. Keep grill-me as an independent skill. When a plan has high complexity, add a note: "You can run `/grill-me` to stress-test this plan."
