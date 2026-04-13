# PICO Framework

A structuring tool for comparative and interventional Research Questions. Originally from evidence-based medicine, widely applicable to product and social research when the RQ involves comparison or intervention.

Used in Step 4 Phase A of `/research rq`, conditionally offered for relational or causal RQs.

---

## Definition

| Element                         | Meaning                 | Question it answers                               |
| ------------------------------- | ----------------------- | ------------------------------------------------- |
| **P** — Population              | Who is being studied?   | Target group, segment, context                    |
| **I** — Intervention / Exposure | What is being examined? | The variable, treatment, or condition of interest |
| **C** — Comparison              | Compared to what?       | The baseline, control, or alternative condition   |
| **O** — Outcome                 | What is being measured? | The result, metric, or observable change          |

**Template**: "Among **[P]**, does **[I]** compared to **[C]** lead to **[O]**?"

---

## When to Use

**Use PICO when** the RQ is relational or causal — i.e., it asks about associations between variables or cause-and-effect relationships, and there is an identifiable comparison.

**Do NOT use PICO when** the RQ is purely descriptive — i.e., it asks "What is happening?" or "What do users experience?" without comparing conditions. For descriptive RQs, use the Refinement Dimensions directly instead.

---

## Relationship to Refinement Dimensions

Refinement Dimensions (in SKILL.md Phase A) and PICO serve different purposes:

|               | Refinement Dimensions                                          | PICO                                                     |
| ------------- | -------------------------------------------------------------- | -------------------------------------------------------- |
| **Purpose**   | Diagnostic — Claude identifies which parts of the RQ are vague | Constructive — user restructures the RQ using a template |
| **When used** | Always (all RQ types)                                          | Conditionally (relational/causal RQs only)               |
| **Output**    | Sharpening questions asked one at a time                       | A reformulated RQ sentence                               |

They overlap in the dimensions they cover (population, comparison, outcome), but Refinement Dimensions are questions Claude asks to **find problems**, while PICO is a template the user applies to **build the solution**.

---

## Worked Examples

### Example 1: Education

- **Rough RQ**: "Is sleep good for learning?"
- **PICO decomposition**:
  - P: University students
  - I: Consistent early-to-bed routine
  - C: Irregular sleep patterns
  - O: GPA and exam scores
- **Refined RQ**: "Among university students, how do early-to-bed routines compare to irregular sleep patterns in their effect on GPA and exam scores?"
  - F: Population and comparison are concrete and accessible
  - N: Compares specific sleep patterns rather than "sleep in general"
  - R: Directly supports student well-being initiatives

### Example 2: Business

- **Rough RQ**: "Are incentives effective?"
- **PICO decomposition**:
  - P: IT company employees
  - I: Autonomy-focused work design
  - C: Traditional monetary incentives
  - O: Long-term motivation and productivity
- **Refined RQ**: "In IT companies, how does autonomy-focused work design compare to traditional monetary incentives in its effect on employees' long-term motivation and productivity?"
  - F: Industry and conditions are specified
  - N: Focuses on non-monetary factors (less studied)
  - R: Applicable to talent management practice

---

## Partial PICO

Not all four elements need to be present. Common valid patterns:

| Pattern                    | When                                                                     | Example                                                                                                         |
| -------------------------- | ------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------- |
| **PI_O** (no Comparison)   | Examining the effect of a single variable without an explicit comparator | "Among new users (P), how does onboarding tutorial completion (I) relate to 30-day retention (O)?"              |
| **P_CO** (no Intervention) | Comparing naturally occurring groups                                     | "Among remote workers (P), how do those in different time zones (C) differ in meeting participation rates (O)?" |

If PICO feels forced — i.e., you struggle to identify I or C — the question may be fundamentally descriptive. That is fine. Use Refinement Dimensions instead and do not force a PICO structure.
