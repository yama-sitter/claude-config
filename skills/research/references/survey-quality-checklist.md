# Survey Quality Checklist

A two-stage framework for evaluating the quality of survey question (SQ) sets. Used in Phase B of `/research survey`.

- **Stage 1: Structural Soundness** — Quality of the SQ set itself (items 1-5)
- **Stage 2: Implementation Quality** — Quality of the surrounding implementation (items 6-11)

Pass Stage 1 before proceeding to Stage 2.

---

## Stage 1: Structural Soundness

### 1. Construct coverage

Does each construct identified in Operationalization have at least one corresponding SQ? Are abstract constructs covered by multi-item scales rather than a single proxy?

- Bad example: Construct *Engagement* is measured only by "How engaged do you feel?" (single self-report on an abstract concept)
- Good example: *Engagement* is measured by frequency of use (numeric), features touched (multi-select), and self-report on a 5-point scale (composite signal)

### 2. Question type appropriateness

Is each SQ's question type matched to the indicator it measures?

- Bad example: Asking "list all features you used" as open text when a closed multi-select would yield comparable data
- Good example: Multi-select for feature usage; numeric input for counts; Likert for attitudes; NPS for loyalty
- Reference: `survey-design.md` for the indicator → question-type mapping

### 3. Scale design integrity

For rating-scale items, is the scale design (points, midpoint policy, N/A handling, anchor labels) consistent within the survey and matched to the construct?

- Bad example: Mixing 5-point and 7-point scales across adjacent attitude questions
- Good example: All attitude items use 5-point odd, separated N/A, endpoint-only labels — except the NPS item which is 0–10 (preserved verbatim)
- Reference: `scale-decision-tree.md`

### 4. Wording quality

Does every SQ pass wording anti-pattern checks (leading, double-barreled, loaded, double negative, jargon, embedded assumption)?

- Bad example: "How satisfied are you with the quality and price?" (double-barreled)
- Good example: "How satisfied are you with the quality?" + separate price item
- Reference: `wording-antipatterns.md`

### 5. Order soundness

Does the question order minimize priming, anchoring, and carryover effects? Are sensitive questions placed late? Is the overall arc funnel (general → specific) or inverted-funnel, with rationale?

- Bad example: Asking "How satisfied are you overall?" after the respondent has been primed by 10 specific complaint-elicitation questions
- Good example: Funnel arc — broad satisfaction first, specific feature questions next, demographics and sensitive items last

---

## Stage 2: Implementation Quality

### 6. Response bias mitigation

Have typical response biases been considered for each SQ, with mitigations applied or risks explicitly accepted?

- Reference: `response-bias-checklist.md`
- Prompt: "For each SQ, what biases were detected and what mitigations were applied?"

### 7. Cognitive interview plan

Is there a documented plan to pretest the survey via cognitive interviewing before fielding?

- Specifies: technique (think-aloud, probing), participant count, number of rounds, detection focus (comprehension, recall, judgment, response)
- Note: Cognitive interviewing reuses think-aloud techniques from `/research interview` — refer to that skill for technique detail

### 8. Validated scale fidelity

If validated scales (NPS, SUS, SERVQUAL, ACSI, CSAT, etc.) are adopted, is their wording preserved verbatim? Any adaptation is documented with rationale.

- Bad example: Paraphrasing the NPS question "How likely is it that you would recommend..." into a custom variant
- Good example: NPS used as-is; if any adaptation is needed for translation or context, the change and its rationale are noted in constraints

### 9. Composite scale reliability plan

For multi-item scales measuring the same construct, is there a plan to verify internal consistency post-fielding (e.g., Cronbach's α)?

- Applicable only when a multi-item scale is used. Skip if all SQs are single-indicator.

### 10. Order randomization decision

For confirmatory surveys where order effects could threaten validity, has order randomization been considered (within blocks where logical sequence permits)?

- Applicable only for confirmatory or comparative surveys. Skip for exploratory surveys with strong narrative flow.

### 11. RQ ↔ SQ consistency

Is each RQ traceable to one or more SQs via the operationalization mapping? Are there orphan SQs (no RQ) or orphan RQs (no SQ)?

- Run via `artifact-consistency-checklist.md`
- Especially important after RQ revisions: SQs may need updating

---

## How to Conduct the Quality Check

### Stage 1: Structural Soundness

1. Walk items 1-5 in order; provide feedback on any problematic items
2. If all items are OK, identify the weakest item and explicitly state the rationale for marking it OK
3. User revises the SQ set, then re-check
4. Repeat until structural soundness holds

### Stage 2: Implementation Quality

1. For SQ sets that passed Stage 1, evaluate items 6-11 in order
2. Items 9 and 10 are conditional — skip if not applicable
3. Item 11 is the final cross-check; gate completion on this
4. As with Stage 1, when all applicable items are OK, identify the weakest and state the rationale

## Lightweight Path (validated-scale-only surveys)

When the survey adopts only a validated scale (e.g., NPS-only, single CSAT) without custom items:

- Stage 1: Check item 1 (does the scale measure the right construct?) and item 4 (is the validated wording preserved?). Skip 2, 3, 5.
- Stage 2: Check item 8 (validated scale fidelity) and item 11 (RQ ↔ SQ consistency). Skip 6, 7, 9, 10.

This path keeps the gate fast while still preventing the most common failure modes — wrong construct fit and accidental scale modification.

## Additional Characteristics of Good SQ Sets

Beyond passing the items above, even better SQ sets also:

- Take less than the planned completion time in the cognitive interview pilot (room for fatigue in the field)
- Produce data that can be cross-validated against behavioral signals (logs, telemetry)
- Include a debrief item ("anything we should have asked?") to surface missing constructs
