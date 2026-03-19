# Plan Review Guidelines

## When

After finishing the plan file in Plan Mode, before calling ExitPlanMode.

## Process

Perform 3 review cycles. Each cycle:

1. **Review** — Critically evaluate the plan from these aspects:
   - Feasibility: Are the proposed steps actually executable? Are prerequisites met?
   - Completeness: Are file changes, dependencies, and edge cases covered?
   - Consistency: Any contradictions between steps? Aligned with codebase conventions?
   - Risk: Any overlooked risks or side effects?
   - Verifiability: Is it clear how to confirm success?

2. **Improve** — Fix substantive issues in the plan (skip trivial wording changes)

3. **Record** — After all 3 cycles, append a `## Self-Review` section to the plan file:
   - Issues found per cycle (or "None")
   - Revisions applied per cycle (or "None")

## Rules

- Exactly 3 review cycles. If no issues remain after an earlier cycle, note "No further issues" and continue
- Focus on substantive issues, not minor wording improvements
