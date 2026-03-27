# FINER Criteria

Criteria for evaluating the value of a Research Question. Originally established in medical research, but applicable to product research. Used in Step 3 (secondary evaluation) of `/research rq`.

## Criteria Definitions

### Feasible

Can it be investigated with available time, data access, budget, and expertise?

- Good example: "Can be investigated through interviews with 10 existing users"
- Bad example: "Requires tracking all global user behavior for one year"

Evaluation points:
- Can you access the target participants?
- Is the required data obtainable?
- Does the team have the necessary skills?
- Can it be conducted within budget and time constraints?

### Interesting

Will the team and stakeholders care? Will the findings be used in decision-making?

- Good example: "The results directly influence the next sprint's priorities"
- Bad example: "Interesting, but won't impact business decisions"

Evaluation points:
- Are there stakeholders waiting for the results?
- Will the answer lead to concrete actions?
- Is it a topic that sparks discussion within the team?

### Novel

Will it yield new insights? Or will it merely reconfirm known facts?

- Good example: "Can reveal a usage context that no one has investigated yet"
- Bad example: "Industry reports already show the same conclusion"

Evaluation points:
- Has existing research or industry reports already provided the answer? (verify via Claude research)
- Does it add a new angle to known facts?
- Can new insights be expected because the target audience or context is different?

### Ethical — Only When Necessary

Does it avoid violating participants' privacy or rights?

- Generally not an issue for typical product research (interviews, surveys, etc.)
- Check when: vulnerable participants (children, patients, etc.), sensitive data, experiments involving behavioral manipulation

### Relevant — Only When Necessary

Is it related to current business or product challenges?

- Can be omitted if already covered by the 3-perspective evaluation (User, Business, Expert)
- Check when: academic/research interests are leading, or the connection to business goals is unclear

## Application in This Skill

Apply FINER criteria as a secondary filter to questions that passed the "3-perspective evaluation" primary filter in Step 3.

1. Evaluate each question on F, I, N (E and R only when necessary)
2. Prioritize questions that satisfy all three as RQ candidates
3. For questions that partially fall short, discuss with the user whether the gap can be filled
   - Example: Weak on Feasible → Can scoping down make it doable?
   - Example: Weak on Novel → Can changing the angle or target audience add novelty?
