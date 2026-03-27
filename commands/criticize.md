---
description: "Self-review and iteratively improve the previous response"
---

# /criticize

Self-review and iteratively improve the previous response.

## Usage

- `/criticize` - Repeat review and improvement 3 times (default)
- `/criticize [count]` - Repeat the specified number of times (e.g., `/criticize 2`)
- `/criticize --focus "aspect1,aspect2"` - Focus the review on specific aspects

## Execution

Repeat the following cycle on the previous response.

### Intermediate Cycles (1 to N-1)

1. **Review**: Critically evaluate the current response and identify specific issues
2. **Plan**: Determine specific changes for each issue (do NOT output the full improved text; apply improvements internally and use the improved version as the review target for the next cycle)

Output format:

```
=== Review [n]/[total] ===
**Issues**:
- [Specific issues in bullet points]

**Changes**:
- [Specific changes for each issue]
```

### Final Cycle (N)

1. **Review**: Perform a final review and identify any remaining issues
2. **Improve**: Generate the final version incorporating all changes from all cycles

Output format:

```
=== Review [n]/[total] ===
**Issues**:
- [Specific issues, or "No further issues"]

=== Final Version ===
[Final improved response reflecting all cycles]
```

## Review Aspects (when --focus is not specified)

- Accuracy: Are there any errors in information or logic?
- Completeness: Are any necessary elements missing?
- Clarity: Are there any ambiguous or unclear expressions?
- Practicality: Is the content actually useful?
