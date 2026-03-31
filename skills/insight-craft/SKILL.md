---
name: insight-craft
description: |
  Uncover "hidden true motives that drive people to act" by questioning what lies behind the data.
  Works with any material type — qualitative (interviews, feedback) or quantitative (analysis reports, KPI aggregations).
  Uses the Shusseuo Model (Dissonance → Conventional Wisdom → Question → Hypothesis → Validation) to progressively nurture insights through 5 stages.
  Use when: deriving insight candidates and designing follow-up analysis questions from any material.
  Do not use when: structuring demand/JTBD from customer behavior.
  Do not use when: designing experiments from an existing hypothesis.
  Subcommands:
    - (default): Collaborative mode. Includes a checkpoint at each step for user confirmation
    - `solo`: LLM-only mode. Replaces checkpoints with self-assessment and outputs insight candidates in batch
user-invocable: true
---

# Insight Craft — Shusseuo Model

Named after _shusseuo_ — fish that change names as they grow — this model nurtures raw dissonance into mature insight through 5 progressive stages of dialogue and structured thinking.

## Prerequisites

- Raw materials for analysis (interview logs, meeting notes, feedback, behavioral data, etc.) must be provided
- When using quantitative data (analysis reports, KPI aggregations, etc.) as materials, also provide what you want to ask from those numbers (a hypothesis to verify, or a sense of incongruity you noticed)
- Insight = a hidden true motive that drives people to act — a desire or motivation that the person themselves cannot consciously articulate
- Findings = interesting discoveries that do not lead to action. Distinct from insights
- This skill questions "why people act that way" and designs follow-up questions

## Mode

- **No arguments**: Collaborative mode (default). At each checkpoint (→), defer judgment to the user
- **`solo`**: LLM-only mode. Replace checkpoints with the following:
  1. State the rationale for each choice explicitly
  2. Flag the choice with the lowest confidence
  3. Check whether any discarded options support the opposite conclusion
  4. State the "direction" of your insight candidate in one line (what is assumed as the motive), and output at least one candidate that explains the phenomenon through a non-psychological axis (operational efficiency, temporal constraints, structural rules, or platform mechanics)
  - Label outputs as "insight candidates" — never call them "insights"

## Workflow

### 1. Notice Dissonance (Sensitivity)

Read through the materials and extract phenomena that contain "prediction errors."

Extraction lenses:

- Behaviors or statements that contradict general expectations
- Two facts that contradict each other
- Points where emotions surface strongly (frustration, joy, resignation)
- Workarounds (creative misuses of something beyond its intended purpose)
- Things people go out of their way to do

Output as a table:

| #   | Hook | Source / Evidence | Why it hooks you (Prediction Error) | Lens |
| --- | ---- | ----------------- | ----------------------------------- | ---- |

**Lens coverage check**: Review the Lens column above. If any of the 5 lenses (Behavior, Contradiction, Emotion, Workaround, Extra-effort) appears 0 times, explore that lens for additional hooks before proceeding.

**Supplementary pass**: Re-scan the materials with the following supplementary lenses. These capture seeds that do not manifest as dissonance. Output only new hooks not already in the table above, then append them to the table.

Supplementary lenses:

- **Repetition**: The same topic, phrase, or concern appears 3+ times across different contexts
- **Absence**: A topic that was asked about but received a thin, deflected, or avoided response
- **Quiet pattern**: A consistent behavior or practice that appears without strong emotion — routine yet deliberate

Supplementary lenses are optional: if a lens yields 0 hooks, skip it without further exploration.

**→ Which of these feel intriguing or unsettling to you? If you sense a dissonance not on the list, please add it.**

### 2. Identify which "Given" the Dissonance Challenges (Awareness of Conventional Wisdom)

Clarify the conventional wisdom, established beliefs, or assumptions behind the selected dissonance.

- Industry conventions ("X is supposed to do Y")
- Social norms ("Normally, people would do X")
- Data-derived orthodoxies
- Unspoken organizational assumptions
- For each, **explicitly state whose conventional wisdom it is**

Output as a table:

| #   | Dissonance | Underlying Conventional Wisdom | Whose conventional wisdom? |
| --- | ---------- | ------------------------------ | -------------------------- |

**→ Do these "givens" ring true? Are there any unspoken assumptions I'm missing? Please share them.**

### 3. Question the Conventional Wisdom (Provocation)

Generate three types of questions against each identified conventional wisdom:

- **Reframe**: What if we look at it from a different angle? ("What if X is not Y, but actually Z?")
- **Dig Deeper**: Why did this become conventional wisdom? ("Why has X always been assumed to be Y?")
- **Shake Up**: What if the opposite were true? ("If X were not Y, what would happen?")

Output as a table:

| #   | Conventional Wisdom | Question Type | Question |
| --- | ------------------- | ------------- | -------- |

**→ Which of these questions spark something for you? Which do you want to explore further? Feel free to add your own.**

### 4. Articulate the Hypothesis (Verbalization)

Verbalize hypotheses in response to the selected questions.

Verbalization techniques:

- **Make the subject specific**: Not "everyone," but "people in X situation"
- **Capture emotional intensity**: Express the strength and urgency of the feeling
- **Use contrast**: "It's assumed to be X, but actually it's Y"
- **Use true-motive language**: Not polished or diplomatic phrasing, but the words the person would actually use

When synthesizing multiple hypotheses into a higher-level one, explicitly show the logical connection from individual hypotheses to the synthesized one. If the connection feels forced, keep them separate.

Self-check each hypothesis: Does it "drive people to act"? Is it "hidden"? Is it a "true motive"?

Output format (per hypothesis):

```
[Hypothesis]
[Subject] is assumed to [conventional wisdom],
but actually [hidden true motive].
Because [evidence / reasoning]. (Mark inferences not directly derivable from materials with "※ Inference")

- Intensity: [Low / Medium / High] (How urgent is this for the person?)
- Hiddenness: [Low / Medium / High] (How unaware are they?)
- Driving Force: [Low / Medium / High] (How likely to trigger behavioral change?)
- Evidence Ratio: Direct quotes N / Inferences M (count each "Because" clause and "※ Inference" mark. When in doubt, count as inference)
```

If `M > N` (inferences outnumber direct quotes), append: `⚠ Inference-heavy — prioritize stress-testing in STEP 5`

**→ Does this wording feel true to the target's experience? Which phrasing would make them say "Yes, that's exactly it!"? Is the intensity too weak or too strong anywhere?**

### 5. Validate and Substantiate (Persuasion)

**Material type gate** — Determine which path to follow:

- **Quantitative materials** (analysis reports, KPI aggregations, dashboards): Use 5a-quant and 5b-quant below
- **Qualitative materials** (interviews, feedback, meeting notes): Use 5a-qual and 5b-qual below
- **Mixed materials**: Execute both paths. Run 5a-qual/5b-qual first, then additionally run 5a-quant/5b-quant

Confirm the hypothesis is not just an "N=1 assumption" and build supporting evidence.

**5a-qual. Gather supporting evidence (output consolidated in 5c):**

- Quantitative: Related statistics, survey data, trends
- Qualitative: Similar statements or behavioral patterns within the materials
- Case studies (optional): Reference examples from other industries or domains. Omit if in-material evidence is sufficient

**5a-quant. Design follow-up analysis questions from the data (output consolidated in 5c):**

List the unverified assumptions embedded in the data at hand, and design a follow-up analysis question for each. For each question, specify:

- **Metric**: What to measure
- **Segment / comparison axis**: How to slice or compare
- **Expected result vs. hypothesis-breaking result**: What you expect to see if the hypothesis holds, and what would overturn it

**5b-qual. Stress-test the hypothesis:**

If a hypothesis carries the `⚠ Inference-heavy` flag from STEP 4, stress-test it first and with extra rigor.

Return to the materials and challenge the hypothesis from these angles:

- Is there any fact in the materials that contradicts this hypothesis? (If so, quote it)
- If you replace the subject with someone else (e.g., repeat users, people from another industry), does the same thing hold? If yes, it's a generality, not a true motive. However, check whether you're merely narrowing the target rather than claiming specificity. Specificity comes from contextual concreteness, not from a narrow target definition
- Imagine how stakeholders would react to this hypothesis:
  - "Knew it" → Lacks novelty. Rephrase the angle and return to STEP 4
  - "So what?" → Doesn't drive action. Possibly stuck at Findings. Re-examine "Driving Force" in STEP 4
  - "Is that really true?" → Weak evidence. Reinforce 5a, or if no evidence is found, honestly note that in 5c

After writing counterarguments, compare whether the hypothesis or the counterarguments are better supported by the facts in the materials. If counterarguments are stronger, revise the hypothesis and redo from 5a, or return to STEP 4.

**5b-quant. Stress-test the hypothesis with data angles:**

If a hypothesis carries the `⚠ Inference-heavy` flag from STEP 4, stress-test it first and with extra rigor.

Challenge the hypothesis from these quantitative angles:

- **Alternative cuts**: Would a different segment or time period overturn the hypothesis?
- **Confounding variables**: Does the relationship hold after controlling for confounders?
- **Reverse causality**: Can the hypothesis be explained by swapping cause and effect?

After examining these angles, compare whether the hypothesis or the counterarguments are better supported by the data. If counterarguments are stronger, revise the hypothesis and redo from 5a-quant, or return to STEP 4.

**5c. Overall assessment:**

Output format:

```
[Insight Candidate]
[Final expression of the hypothesis (revised version if modified in 5b)]

[Supporting Evidence]
- Quantitative: [Data / Statistics]
- Qualitative: [Similar statements / Behavioral patterns]
- Case studies (optional): [Reference examples from other domains]

[Counterevidence & Risks]
- [The strongest counterargument from 5b and the response to it]

[Overall Assessment]
- Is this an Insight, not just a Finding?: [Yes / No + reason]
- Can it drive people to act?: [Assessment]
```

**→ [Next action branching]**

- If follow-up analysis questions were designed → Use them as the next analysis theme
- If a hypothesis candidate has sufficient strength → Move to experiment design
- If the hypothesis is weak or counterevidence is strong → Return to STEP 4 to re-hypothesize, or collect additional materials

**→ Does this insight feel like it can "move people"? If you heard this insight, would it make you want to change your behavior?**

## Strict Rules

- Never skip checkpoints (→) (except in solo mode)
- Follow the step order (1→2→3→4→5). Returning to a previous step is encouraged
- When synthesizing hypotheses, explicitly show the logical connection from individual to higher-level. If the connection is forced, keep them separate
- Avoid clichés. When using abstract terms like "essence" or "epistemological," immediately follow with a concrete example
- Check that the 3-axis ratings are not all the same value
- Only cite external theories (JTBD, etc.) to reinforce the logic derived from materials. Never substitute them for material-based reasoning
- Distinguish between facts from the materials and your own inferences. Never present inferences as facts
- Distinguish between facilitator/analyst opinions and participant behavioral facts in the materials. Do not treat opinions as facts
- If you sense that filling in the format has become the goal, abandon the format and return to the materials
  - Signs of format-as-goal: the Hook table follows the same pattern every time / checkpoint self-assessments become boilerplate / all 3-axis ratings are the same value

For anti-patterns and term definitions, see [framework.md](references/framework.md).

## Completion

- At least one insight candidate has been verbalized and the user has decided to adopt or discard it
- Each candidate is traceable from the STEP 1 hook through STEP 5 validation
- In solo mode: a list of insight candidates has been output (adoption decisions are deferred to the human)
