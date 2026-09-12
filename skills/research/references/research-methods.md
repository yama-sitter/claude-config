# Research Methods Catalog

A guide for selecting research methods based on the nature of the RQ. Used in Step 2 of `/research plan`.

Every method below carries an **Evidence source** tag. Qualitative research finds a group by combining three moves — observing behavior, hearing the background behind the act, and analyzing — and no single method supplies all of them. Use the tags to check coverage in the Evidence Coverage Gate, not to rank methods.

| Tag | Meaning |
| --- | --- |
| Observed | Behavior is witnessed as it happens (or logged), not reported after the fact |
| Heard | The background of the act is elicited from the participant |
| Observed + Heard | Both in the same session |

## Method Catalog

### Qualitative Research (suited for exploratory RQs)

#### Depth Interview
- **Overview**: One-on-one semi-structured interview. 30-60 minutes
- **Suited for**: "Why do they...?" "How do they...?"
- **Sample size**: 5-8 participants (5 participants are said to uncover ~85% of issues)
- **Pros**: Deep understanding of motivations and context. Flexible deep-diving
- **Cons**: Time-consuming. Requires participant recruitment. Analysis is labor-intensive
- **Evidence source**: Heard only — behavior reaches you as self-report. Pair with an Observed method, or record the absence of observation as a limitation

#### Contextual Inquiry
- **Overview**: Interview conducted while observing behavior in the participant's actual environment
- **Suited for**: "How do they actually...?" "In what situations does X occur?"
- **Sample size**: 4-6 participants
- **Pros**: Discovers unarticulated behaviors and workarounds
- **Cons**: High cost. Requires access to the participant's environment
- **Evidence source**: Observed + Heard — the only single method that supplies both

#### Diary Study
- **Overview**: Participants record specific behaviors or feelings over a set period
- **Suited for**: "How does X change over time?" "How is X used in daily life?"
- **Sample size**: 10-15 participants
- **Pros**: Captures changes over time. Less recall bias
- **Cons**: High participant burden with dropout risk. Long duration
- **Evidence source**: Observed (participant-recorded, so weaker than first-hand observation) + Heard when follow-up probing is included

#### Focus Group
- **Overview**: A group of 4-8 people discusses a topic together
- **Suited for**: "What perceptions exist about X?" "How receptive are people to X?"
- **Sample size**: 2-3 groups (4-8 per group)
- **Pros**: Collects many perspectives in a short time. Interaction sparks new ideas
- **Cons**: Group pressure may skew opinions. Deep personal motivations are hard to surface
- **Evidence source**: Heard only, and group-mediated — what is said is shaped by who else is in the room

### Quantitative Research (suited for confirmatory RQs)

#### Survey
- **Overview**: Distribute a structured questionnaire online or in person
- **Suited for**: "What proportion...?" "Is there a correlation between X and Y?"
- **Sample size**: At least 100 (for statistical significance)
- **Pros**: Low cost. Can collect large amounts of data. Quantitative evidence
- **Cons**: Cannot uncover deep reasons. Risk of question design bias
- **Evidence source**: Heard only — self-report at scale

#### Usability Testing
- **Overview**: Observe participants executing tasks
- **Suited for**: "Can users complete X smoothly?" "Where do they get stuck?"
- **Sample size**: 5-8 participants
- **Pros**: Identifies specific usability issues. Clear improvement points
- **Cons**: Requires a prototype or product. Behavior in an artificial environment
- **Evidence source**: Observed (task behavior) + Heard when think-aloud is used

#### A/B Testing
- **Overview**: Randomly display two variations and compare behavioral data
- **Suited for**: "Which is more effective for X — A or B?"
- **Sample size**: Depends on statistical power (typically hundreds to thousands)
- **Pros**: Can verify causal relationships. Objective data
- **Cons**: Requires high traffic volume. Cannot answer "why"
- **Evidence source**: Observed only — behavioral logs, with no access to the background of the act

### Mixed Methods

#### Sequential Design (Exploratory → Confirmatory)
- **Overview**: First conduct qualitative research to form hypotheses, then validate with quantitative research
- **Suited for**: Mixed RQs. e.g., "Why is X happening? (exploratory) How prevalent is it? (confirmatory)"
- **Pros**: Yields both deep understanding and statistical evidence
- **Cons**: Doubles time and cost
- **Evidence source**: Inherited from the constituent methods — covers both only if the qualitative leg includes an Observed method

## Method Selection Criteria

| Decision axis | Choose qualitative | Choose quantitative |
|---|---|---|
| RQ type | Why? How? | How much? Which? |
| Existing knowledge | Limited (exploratory stage) | Moderate (validation stage) |
| Required deliverables | Hypotheses, insights, personas | Numbers, statistical evidence, comparison results |
| Timeline | 1-4 weeks | 1-2 weeks (excluding preparation) |
| Budget | Medium to high | Low to medium |

## Combining Methods for Evidence Coverage

Selecting one method is normally not enough. Check the selected set against both evidence sources:

| Selected set | Coverage | What to do |
| --- | --- | --- |
| Depth Interview only | Heard only | Add Contextual Inquiry, Usability Testing, a Diary Study, or behavioral log analysis — or state the missing observation as a limitation |
| A/B Testing or log analysis only | Observed only | Add a Heard method, or the "why" stays unanswerable by design |
| Contextual Inquiry | Observed + Heard | Covered by one method |
| Survey + Depth Interview | Heard only, twice | Scale changes; the evidence source does not. Still uncovered |

Failing to see something is a defect in the research design, not proof that participants have nothing to say. When budget or access rules out an Observed method, record that explicitly as a limitation rather than treating self-report as if it were observation.
