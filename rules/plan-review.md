# Plan Review Guidelines

## When

After finishing the plan file in Plan Mode, before calling ExitPlanMode.

## Process

Perform 2 review cycles. Each cycle:

1. Critically evaluate the current plan
2. Output findings in the conversation using the format below
3. Rewrite the entire plan file incorporating all improvements

### Output Format (each cycle)

```
=== Plan Review [n]/2 ===
**Feasibility**: [findings or "OK"]
**Completeness**: [findings or "OK"]
**Consistency**: [findings or "OK"]
**Risk**: [findings or "OK"]
**Verifiability**: [findings or "OK"]
**Clarity**: [findings or "OK"]
**Accuracy**: [findings or "OK"]
```

### Review Aspects

- Feasibility: Are the proposed steps actually executable?
- Completeness: Are any file changes, dependencies, or edge cases missing?
- Consistency: Any contradictions between steps or with codebase conventions?
- Risk: Any overlooked side effects or failure scenarios?
- Verifiability: Is it clear how to confirm success?
- Clarity: Any ambiguous expressions, logical leaps, or misleading descriptions?
- Accuracy: Any incorrect technical details, file paths, or API names?

## Rules

- Exactly 2 review cycles
- Cycle 1 must identify at least one issue — re-read the plan more carefully if nothing is found
- When finding issues, quote the specific problematic text from the plan
- Focus on substantive issues, not minor wording improvements
- Each cycle rewrites the entire plan file (do not patch — rewrite)
- Preserve the substance of sections without issues; improve only what needs fixing
- After all cycles, append to the plan file:

```markdown
## Self-Review
- Cycle 1: [1-line summary of key issue found and fixed]
- Cycle 2: [1-line summary of remaining issue, or "No further issues"]
```
