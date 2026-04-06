# Plan Template

## When

Use this template when writing plans in Plan Mode.

## Required Sections

### 1. Context

Why this change is needed — the problem, what prompted it, and the intended outcome. Keep it concise but include enough detail for the scope to be clear.

### 2. Changes (table format)

| Operation | File | Purpose |
|---|---|---|
| Create/Modify/Delete | `path/to/file` | What and why |

### 3. Implementation Steps (numbered list)

Concrete, executable steps. Each step should reference specific files and functions.

### 4. Verification

Define acceptance criteria as a table. A separate evaluator (`/verify`) uses this table to confirm the implementation.

| # | Criterion | Command | Expected |
|---|-----------|---------|----------|
| 1 | [What to verify] | `[command]` or `Manual` | [What success looks like] |

- At least 2 criteria required, at least 1 must have an automated command
- Commands must be runnable from the project root
- Expected results must be concrete enough for an independent evaluator to judge pass/fail

### 5. Risks and Notes (bullet list, optional)

Side effects, edge cases, or caveats worth noting. Omit this section if there are no meaningful risks.
