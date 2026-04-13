# RQ Anti-Patterns

A catalog of common Research Question failure patterns. Each anti-pattern is tagged with the quality checklist item it violates, along with the failure reason and a corrected version.

Referenced in Step 4 Phase A of `/research rq` to help users recognize and fix structural problems in their draft RQs.

---

## 1. Scope Explosion

The question tries to cover too broad a domain without specifying population, variables, or context.

- **Violates**: Specific (Stage 1b, item 5), Single focus (Stage 1a, item 2)
- **Bad**: "How can education be improved?"
  - Scope is unbounded — no target population, no specific aspect of education, no measurable outcome
- **Good**: "How does smartphone screen time affect high school students' study efficiency?"
  - Population (high school students), variable (smartphone screen time), and outcome (study efficiency) are all concrete and measurable

---

## 2. Yes/No Trap

The question is structured to end with a binary Yes/No answer, shutting down exploration.

- **Violates**: Open-ended (Stage 1a, item 1)
- **Bad**: "Does social media negatively affect learning?"
  - Answerable with "Yes" or "No" — no room for nuance or mechanism discovery
- **Good**: "In what ways does social media usage relate to university students' academic engagement and study habits?"
  - Requires explanation of mechanisms and context, not just confirmation

---

## 3. False Binary

The question frames a complex relationship as a simple two-option choice, preventing discovery of nuance.

- **Violates**: Open-ended (Stage 1a, item 1)
- **Bad**: "Do more friends lead to happiness?"
  - Forces a binary framing on a multi-dimensional relationship — no room for "it depends on the type of friendship"
- **Good**: "What kinds of social interactions and friendship qualities contribute to improved well-being among young adults?"
  - Opens up exploration of the relationship's structure rather than forcing a Yes/No

---

## 4. Abstract Outcome

The outcome variable is too vague to measure or operationalize.

- **Violates**: Specific (Stage 1b, item 5)
- **Bad**: "How does well-being affect things?"
  - "Things" is undefined — no way to design a study or know when you have an answer
- **Good**: "Among people with high self-reported well-being, is physical health (sleep quality, exercise frequency) better compared to those with low well-being?"
  - Variables are concrete (well-being measured by self-report, physical health measured by specific indicators), and a research design is imaginable

---

## 5. Individual Case

The question is scoped to a single instance, producing findings that cannot transfer to other contexts.

- **Violates**: Generalizable (Stage 1b, item 6)
- **Bad**: "Why did this specific customer cancel their subscription?"
  - Answer applies to one person only — no transferable knowledge for product decisions
- **Good**: "What factors lead long-term subscribers to cancel within the first renewal period?"
  - Abstracts to a class of cases, producing actionable patterns

---

## 6. Compound Question

The question bundles multiple independent variables or outcomes, making it impossible to answer cleanly.

- **Violates**: Single focus (Stage 1a, item 2)
- **Bad**: "How do diet and exercise affect productivity and satisfaction?"
  - Two independent variables (diet, exercise) × two outcomes (productivity, satisfaction) = effectively four questions
- **Good**: "Among remote workers, how does regular exercise frequency relate to self-reported productivity?"
  - One variable, one outcome, one population — answerable in a single study

---

## How to Use This Reference

When a user's draft RQ has a structural problem, identify the closest anti-pattern and:

1. Name the pattern (e.g., "This looks like a Scope Explosion")
2. Explain briefly why it is problematic (one sentence)
3. Show the contrast between the bad and good versions to illustrate the fix direction
4. Ask the user to rewrite — do not rewrite for them

This reference complements the quality checklist: the checklist tells you **what** is wrong; anti-patterns tell you **why** it is wrong and suggest a direction for fixing it.
