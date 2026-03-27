# RQ Quality Checklist

A two-stage framework for evaluating the quality of Research Questions (RQs). Used in Step 4 of `/research rq`.

- **Stage 1: Text Check** — Quality of the RQ text itself (items 1-5)
- **Stage 2: Structural Check** — Quality of the surrounding structure (items 6-10)

Pass Stage 1 before proceeding to Stage 2.

---

## Stage 1: Text Check

### 1. Is it open-ended?

Does it require explanation and understanding rather than a Yes/No answer?

- Bad example: "Are users using feature X?" (ends with Yes/No)
- Good example: "In what situations and how are users using feature X?"

### 2. Is it neutral?

Does it avoid leading toward a specific answer? Is the question free from bias or embedded assumptions?

- Bad example: "Why do users hate feature X?" ("hate" is assumed)
- Good example: "What perceptions do users have about feature X?"

### 3. Is it answerable?

Can it actually be investigated using available research methods (interviews, surveys, behavioral observation, etc.)?

- Bad example: "What kind of services will users want in 5 years?" (impossible to predict)
- Good example: "What unmet needs do current users feel?"

### 4. Is it specific?

Are the target audience, situation, and behavior clearly defined?

- Bad example: "Why do people use services?" (audience and situation are vague)
- Good example: "What barriers did active users who use the service 3+ times per week experience during their first use?"

### 5. Is it RQ ≠ IQ?

Is it a "what you want to know" through the entire research, rather than a question you'd ask directly in an interview?

- Bad example: "Tell me why you stopped using X" (this is an interview question)
- Good example: "What factors lead long-term users to leave the service?" (what you want to learn through research)

---

## Stage 2: Structural Check

Evaluate the surrounding structure for RQs that passed Stage 1 (Text Check).

### 6. Is the hypothesis state explicitly declared?

Is the current assessment (hypothesis) for the RQ explicitly declared as one of the following three types?

| Type | State | Example |
| ------------ | -------------------------------- | --------------------------------------------------------- |
| Hypothesis-driven | Clear hypothesis with rationale | "X is causing churn. Evidence: ..." |
| Exploratory | No hypothesis. Only direction defined | "Cause of churn is unknown. Exploring the context of declining usage frequency" |
| Hybrid | Directional hypothesis but specifics are exploratory | "X should be involved, but exactly how it affects things is unknown" |

- Prompt: "Do you have any 'I think it's probably this' sense about this RQ? It's fine either way."

### 7. Is a measurement mechanism (validation metric) defined?

Is there a criterion for judging the research results? The form of the metric differs by hypothesis type.

- **Hypothesis-driven**: What would confirm the hypothesis, and what would reject it?
- **Exploratory**: Are focus areas defined? Are there criteria for evaluating deliverables?
- **Hybrid**: Focus areas for the directional hypothesis + evaluation criteria for deliverables
- Prompt: "After the interviews are done, how will you organize the results? What would have to emerge for you to say 'this research was successful'?"

### 8. Is the scope clear?

Are the targets (who, what, what range) and exclusions explicitly stated?

- Bad example: "Investigate user churn factors" (unclear who is excluded)
- Good example: "Targets users who were active once a week or more but stopped using in the past month. New users who never activated are excluded"
- Prompt: "What will this research NOT ask about or NOT cover?"

### 9. Does it function as a measurement standard? (Overall judgment)

Overall judgment based on items 6-8. Looking at the RQ and its surrounding structure, could a different interviewer understand "what to ask" and "how to judge results"?

- Prompt: "If you handed this RQ set to a team member and said 'go interview with this,' would they be able to?"

### 10. Are the limitations of the research stated? (Only when applicable)

If there are things that cannot be answered due to design constraints, are they documented? Not all research has this, so skip if not applicable.

- Prompt: "What will remain unknown even after this research?"

---

## How to Conduct the Quality Check

### Stage 1: Text Check

1. Ask the user to write an RQ (rough is fine)
2. Evaluate on items 1-5, providing feedback on any problematic items
3. If all items are OK, identify the weakest item and explicitly state the rationale for marking it OK
4. User writes an improved version, then re-check
5. Repeat until a satisfactory RQ is complete

### Stage 2: Structural Check

1. For RQs that passed Stage 1, evaluate items 6-10 in order
2. Lock in the sequence: item 6 (hypothesis type) → item 7 (metric) → item 8 (scope)
3. Use item 9 for overall judgment; if gaps exist, return to the relevant item
4. Check item 10 only when applicable

## Additional Characteristics of Good RQs

Beyond passing the 10 items above, even better RQs also:

- Facilitate discussion among team members (directly inform decisions)
- Can be validated from multiple angles (not dependent on a single method)
- When answered, make the next action clear
