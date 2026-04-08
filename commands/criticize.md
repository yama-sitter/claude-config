---
description: "Self-review and iteratively improve the previous response"
---

# /criticize

Self-review and iteratively improve the previous response until no issues remain.

## Usage

- `/criticize` - Review and improve until no issues remain (max 5 cycles)
- `/criticize [max]` - Set the maximum number of cycles (e.g., `/criticize 3`). Terminates early if no issues are found
- `/criticize --focus "aspect1,aspect2"` - Focus the review on specific aspects

## Execution

Repeat the following cycle on the previous response. The loop terminates when either (a) a review finds no issues, or (b) the maximum cycle count is reached.

### Each Cycle

1. **Review**: Critically evaluate the current response against all Review Aspects (or `--focus` items) and list specific issues
2. **Decide**:
   - If issues exist AND max not reached → output the review, apply changes internally, and proceed to the next cycle
   - If no issues exist → output the final version and stop
   - If max reached → output the final version with a note on remaining issues and stop

### Output Formats

**Intermediate cycle (issues found, continuing):**

```
=== Review [n] ===
**Issues**:
- [Specific issues in bullet points]

**Changes**:
- [Specific changes for each issue]
```

**Final cycle (no issues found):**

```
=== Review [n] ===
**Issues**:
- No further issues

=== Final Version ===
[Final improved response reflecting all cycles]
```

**Final cycle (max reached, issues remain):**

```
=== Review [n] (max reached) ===
**Remaining Issues**:
- [Unresolved issues]

=== Final Version ===
[Best version so far, incorporating all changes from previous cycles]
```

## Review Aspects (when --focus is not specified)

- Accuracy: Are there any errors in information or logic?
- Completeness: Are any necessary elements missing?
- Clarity: Are there any ambiguous or unclear expressions?
- Practicality: Is the content actually useful?
