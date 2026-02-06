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

### Each Cycle

1. **Review**: Critically evaluate the current response and identify specific issues
2. **Improve**: Generate an improved version that addresses the issues

### Output Format

Each cycle:

```
=== Review [n]/[total] ===
**Issues**:
- [Specific issues in bullet points]

**Improved version**:
[Improved response]
```

### Final Output

After all cycles are complete:

```
=== Final Version ===
[Final improved response]
```

## Review Aspects (when --focus is not specified)

- Accuracy: Are there any errors in information or logic?
- Completeness: Are any necessary elements missing?
- Clarity: Are there any ambiguous or unclear expressions?
- Practicality: Is the content actually useful?
