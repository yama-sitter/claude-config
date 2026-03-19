# Plan Review Guidelines

## When

After finishing the plan file in Plan Mode, before calling ExitPlanMode.

## Process

Perform 3 review cycles. Each cycle, output the following in the conversation:

```
=== Plan Review [n]/3 ===
**Feasibility**: [findings or "OK"]
**Completeness**: [findings or "OK"]
**Consistency**: [findings or "OK"]
**Risk**: [findings or "OK"]
**Verifiability**: [findings or "OK"]

**Changes applied**: [list of changes made to the plan file]
```

After evaluating, apply fixes directly to the plan file.

## Review Aspects

- Feasibility: Are the proposed steps actually executable?
- Completeness: Are any file changes, dependencies, or edge cases missing?
- Consistency: Any contradictions between steps or with codebase conventions?
- Risk: Any overlooked side effects or failure scenarios?
- Verifiability: Is it clear how to confirm success?

## Rules

- Exactly 3 review cycles
- Cycles 1-2 must identify at least one issue each — re-read the plan more carefully if nothing is found
- Cycle 3 may report "OK" for all aspects if genuinely no issues remain
- When finding issues, quote the specific problematic text from the plan
- Focus on substantive issues, not minor wording improvements
- After all 3 cycles, append to the plan file:

```markdown
## Self-Review
- Cycle 1: [1-line summary of key issue found and fixed]
- Cycle 2: [1-line summary of key issue found and fixed]
- Cycle 3: [1-line summary or "No further issues"]
```
