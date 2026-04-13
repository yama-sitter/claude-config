# RQ Quality Checklist

A two-stage framework for evaluating the quality of Research Questions (RQs). Used in Step 4 Phase B of `/research rq`.

- **Stage 1: Text Check** — Quality of the RQ text itself (items 1-7)
  - Stage 1a: Structural Soundness — does the question have the right shape?
  - Stage 1b: Research Fitness — is it fit for research?
- **Stage 2: Structural Check** — Quality of the surrounding structure (items 8-13)

Pass Stage 1 before proceeding to Stage 2.

---

## Stage 1a: Structural Soundness

### 1. Is it open-ended?

Does it require explanation and understanding rather than a Yes/No answer?

- Bad example: "Are users using feature X?" (ends with Yes/No)
- Good example: "In what situations and how are users using feature X?"

### 2. Does it have a single focus?

Does the question ask about exactly one relationship, phenomenon, or variable? A question that bundles multiple concerns cannot be answered cleanly.

- Bad example: "How do sleep habits and diet affect university students' academic performance and mental health?" (two independent variables × two outcomes = four questions)
- Good example: "Among university students, how do irregular sleep patterns relate to GPA compared to consistent early-to-bed routines?"

### 3. Is it neutral?

Does it avoid leading toward a specific answer? Is the question free from bias or embedded assumptions?

- Bad example: "Why do users hate feature X?" ("hate" is assumed)
- Good example: "What perceptions do users have about feature X?"

---

## Stage 1b: Research Fitness

### 4. Is it answerable?

Can it actually be investigated using available research methods (interviews, surveys, behavioral observation, etc.)?

- Bad example: "What kind of services will users want in 5 years?" (impossible to predict)
- Good example: "What unmet needs do current users feel?"

### 5. Is it specific?

Are the target audience, situation, and behavior clearly defined?

- Bad example: "Why do people use services?" (audience and situation are vague)
- Good example: "What barriers did active users who use the service 3+ times per week experience during their first use?"

### 6. Is it generalizable?

Will the answer apply beyond the specific instance being studied? Good RQs produce transferable knowledge, not just case reports.

- Bad example: "Why did user ID #12345 cancel their subscription?" (individual case — no transferable knowledge)
- Good example: "What factors lead long-term subscribers to cancel within the first renewal period?"

### 7. Is it RQ ≠ IQ?

Is it a "what you want to know" through the entire research, rather than a question you'd ask directly in an interview?

- Bad example: "Tell me why you stopped using X" (this is an interview question)
- Good example: "What factors lead long-term users to leave the service?" (what you want to learn through research)

---

## Stage 2: Structural Check

Evaluate the surrounding structure for RQs that passed Stage 1 (Text Check).

### 8. Is the hypothesis state explicitly declared?

Is the current assessment (hypothesis) for the RQ explicitly declared as one of the following three types?

| Type              | State                                                | Example                                                                         |
| ----------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------- |
| Hypothesis-driven | Clear hypothesis with rationale                      | "X is causing churn. Evidence: ..."                                             |
| Exploratory       | No hypothesis. Only direction defined                | "Cause of churn is unknown. Exploring the context of declining usage frequency" |
| Hybrid            | Directional hypothesis but specifics are exploratory | "X should be involved, but exactly how it affects things is unknown"            |

- Prompt: "Do you have any 'I think it's probably this' sense about this RQ? It's fine either way."

### 9. Is the question type identified?

Is the structural form of the answer this RQ demands explicitly classified?

| Type        | What it asks                          | Answer form             | Example                                                                                          |
| ----------- | ------------------------------------- | ----------------------- | ------------------------------------------------------------------------------------------------ |
| Descriptive | What is happening? What is the state? | Variable description    | "What barriers do first-time users encounter during onboarding?"                                 |
| Relational  | Is X associated with Y?               | Correlation/association | "Among remote workers, is meeting frequency associated with job satisfaction?"                   |
| Causal      | Does X cause Y? How does X affect Y?  | Mechanism/effect        | "Does a 5-minute warm-up routine reduce onboarding drop-off rates compared to the current flow?" |

- **Caution**: "How should we...?" or "What should be done?" type questions are future-oriented and tend to become policy recommendations rather than research questions. RQs should target past or present phenomena. If detected, prompt the user to reframe toward "why" or "what is" to make the question researchable.
- Prompt: "This reads as a [type] question — it asks about [description]. Does that match what you want to find out?"

### 10. Is a measurement mechanism (validation metric) defined?

Is there a criterion for judging the research results? The form of the metric differs by hypothesis type.

- **Hypothesis-driven**: What would confirm the hypothesis, and what would reject it?
- **Exploratory**: Are focus areas defined? Are there criteria for evaluating deliverables?
- **Hybrid**: Focus areas for the directional hypothesis + evaluation criteria for deliverables
- Prompt: "After the interviews are done, how will you organize the results? What would have to emerge for you to say 'this research was successful'?"

### 11. Is the scope clear?

Are the targets (who, what, what range) and exclusions explicitly stated?

- Bad example: "Investigate user churn factors" (unclear who is excluded)
- Good example: "Targets users who were active once a week or more but stopped using in the past month. New users who never activated are excluded"
- Prompt: "What will this research NOT ask about or NOT cover?"

### 12. Does it function as a measurement standard? (Overall judgment)

Overall judgment based on items 8-11. Looking at the RQ and its surrounding structure, could a different interviewer understand "what to ask" and "how to judge results"?

- Prompt: "If you handed this RQ set to a team member and said 'go interview with this,' would they be able to?"

### 13. Are the limitations of the research stated? (Only when applicable)

If there are things that cannot be answered due to design constraints, are they documented? Not all research has this, so skip if not applicable.

- Prompt: "What will remain unknown even after this research?"

---

## How to Conduct the Quality Check

### Stage 1: Text Check

1. Ask the user to write an RQ (rough is fine)
2. Evaluate Stage 1a (items 1-3) first, providing feedback on any problematic items
3. Once Stage 1a passes, evaluate Stage 1b (items 4-7)
4. If all items are OK, identify the weakest item and explicitly state the rationale for marking it OK
5. User writes an improved version, then re-check
6. Repeat until a satisfactory RQ is complete

### Stage 2: Structural Check

1. For RQs that passed Stage 1, evaluate items 8-13 in order
2. Lock in the sequence: item 8 (hypothesis type) → item 9 (question type) → item 10 (metric) → item 11 (scope)
3. Use item 12 for overall judgment; if gaps exist, return to the relevant item
4. Check item 13 only when applicable

## Additional Characteristics of Good RQs

Beyond passing the 13 items above, even better RQs also:

- Facilitate discussion among team members (directly inform decisions)
- Can be validated from multiple angles (not dependent on a single method)
- When answered, make the next action clear
