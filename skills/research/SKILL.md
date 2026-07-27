---
name: research
description: |
  Support research design — building Research Questions (RQs), designing research plans, and creating interview guides.
  Built on the "Product Research Rules" 4-step framework, layered with FINER criteria, Known/Unknown matrix, and more.
  Use when: designing research (what to investigate and how)
  Do not use when: analyzing collected data (-> analyze)
  Subcommands:
    - (default): Subcommand guide
    - `rq`: Research Question construction sparring
    - `plan`: Research plan design
    - `interview`: Interview guide creation
    - `survey`: Survey question design
user-invocable: true
---

# Research — Research Design Skill

A skill that supports the "design" phase of research through collaborative sparring. Self-contained.

## Common Principles

- **RQ ≠ Asked Question (IQ / SQ)**: An RQ is "what you want to know"; an interview question (IQ) or survey question (SQ) is "how you ask it." Asking the RQ directly causes participants to guess the "expected answer" (IQ) or pick the implied option (SQ)
- **Dialogue style**: Hybrid. Guide through dialogue while weaving in external research and domain knowledge
- **One question at a time**: Never ask multiple questions at once. Reduce cognitive load on the user
- **Weaving in research**: Present Claude's research not as "answers" but as material naturally woven into the sparring dialogue

## Subcommand Routing

| Argument    | Behavior                                                              |
| ----------- | --------------------------------------------------------------------- |
| (none)      | Show subcommand guide. Interview the user's situation and suggest one |
| `rq`        | → RQ construction workflow                                            |
| `plan`      | → Research plan workflow                                              |
| `interview` | → Interview guide workflow                                            |
| `survey`    | → Survey design workflow                                              |

**Default behavior (no argument)**:

> "Which stage of research can I help with?"
>
> - `rq` — Research Question construction
> - `plan` — Research plan design
> - `interview` — Interview guide creation
> - `survey` — Survey question design

---

## `/research rq` — Research Question Construction

A layered, enhanced version of the "Product Research Rules" 4-step framework with quality gates at each step exit.

### Step 0: Pre-dialogue Preparation (Claude's side)

After the user shares their theme, Claude conducts research via WebSearch/WebFetch on the first turn:

- Basic domain structure (market, key players, trends)
- Existing research examples in similar areas
- Related academic findings and frameworks

Tell the user: "Let me do a bit of research on your theme before we start sparring." Weave research results naturally into the sparring from Step 1 onward. Do not present them all at once.

**Fallback**: If the theme is too vague to research, skip research and start directly from Step 1. Conduct research once the theme becomes more specific.

### Step 1: Capture Your Intuition

Verbalize the user's vague discomfort or interest.

- Ask: "What do you want to investigate?" "What kind of discomfort or unease do you feel?"
- Deepen the user's response by weaving in research results from Step 0
- Proceed one question at a time, continuing dialogue until the intuition is verbalized as 1-3 statements

**→ "Does this expression of your intuition feel right?"**

### Step 2: Decompose with 5W1H + Known/Unknown Matrix

Increase the resolution of the intuition and separate "what is known" from "what is unknown."

- For each intuition from Step 1, ask 5W1H questions one at a time (Who? What? Why? Where? When? How?)
- Sort each answer into "Known (fact)" and "Unknown (question)"

See [known-unknown-matrix.md](references/known-unknown-matrix.md) for details on the Known/Unknown matrix.

Output:

| 5W1H  | Known (facts) | Unknown (questions) |
| ----- | ------------- | ------------------- |
| Who   | ...           | ...                 |
| What  | ...           | ...                 |
| Why   | ...           | ...                 |
| Where | ...           | ...                 |
| When  | ...           | ...                 |
| How   | ...           | ...                 |

**→ "Does this breakdown look right? Which items in the Unknown column concern you most?"**

### Step 3: Evaluate & Filter with 3 Perspectives + FINER

From the "Unknown (questions)" identified in Step 2, filter down to questions worth investigating.

**Primary evaluation (3 perspectives)**:

1. **User perspective**: Is it important to the user?
2. **Business perspective**: Is it important to the business?
3. **Expert perspective**: Can it be answered with existing knowledge without research?

→ For the "Expert perspective," Claude conducts a web search. Questions already answered are excluded.

**Secondary evaluation (FINER criteria, applied to remaining questions)**:

- **F**easible: Can it be investigated with available resources?
- **I**nteresting: Will the team and stakeholders care?
- **N**ovel: Will it yield new insights?
- ※ Ethical / Relevant only when necessary

See [finer-criteria.md](references/finer-criteria.md) for details on FINER criteria.

Output: Prioritized question list

| Question | User | Business | Resolved by expert? | F   | I   | N   | Priority |
| -------- | ---- | -------- | ------------------- | --- | --- | --- | -------- |

**→ "Looking at these results, which questions would you like to turn into RQs?"**

### Step 4: RQ Formulation + Quality Check

Turn the selected questions into specific, researchable question statements through a two-phase process: first sharpen the RQ through dialogue (Phase A), then formally evaluate it (Phase B).

#### Phase A: Draft and Sharpen

**A1. Draft**: Ask the user to write an RQ first (rough is fine).

**A2. Refinement Dimensions**: Diagnose which parts of the draft RQ are vague by checking each dimension one at a time:

- Population/target — Who specifically? (e.g., "users" → "active users who use 3+ times per week")
- Variable(s) — What specifically is being examined? (e.g., "satisfaction" → "task completion rate")
- Comparison — Compared to what? (only when applicable — skip for purely descriptive RQs)
- Outcome/measure — How would we know the answer? (e.g., "impact" → "30-day retention rate")
- Scope/context — In what setting or timeframe? (e.g., "our product" → "mobile app, past 6 months")

Ask one dimension at a time. For each vague dimension, ask a sharpening question and let the user refine.

Note: Refinement Dimensions are diagnostic questions Claude asks to **find problems**. The [PICO framework](references/pico-framework.md) (offered in A5) is a template the user can apply to **build the solution**. They overlap in coverage but serve different purposes.

**A3. Before → After display**: After each round of refinement, show the before and after versions side by side to make the improvement visible:

> Before: "How does onboarding affect retention?"
> After: "Among first-time mobile app users, how does completing the 3-step onboarding tutorial affect 30-day retention compared to users who skip it?"

**A4. RQ type classification**: Classify the sharpened RQ into one of three types and confirm with the user:

| Type        | What it asks                          | Answer form             |
| ----------- | ------------------------------------- | ----------------------- |
| Descriptive | What is happening? What is the state? | Variable description    |
| Relational  | Is X associated with Y?               | Correlation/association |
| Causal      | Does X cause Y? How does X affect Y?  | Mechanism/effect        |

- **Caution**: "How should we...?" or "What should be done?" type questions are future-oriented and tend to become policy recommendations, not researchable questions. If detected, prompt the user to reframe toward "why" or "what is" — RQs should target past or present phenomena.
- Prompt: "This reads as a [type] question — it asks about [description]. Does that match what you want to find out?"

**A5. PICO (conditional)**: For relational or causal RQs only, offer the [PICO framework](references/pico-framework.md) as a structuring tool. For descriptive RQs, skip this step — rely on the Refinement Dimensions from A2 instead.

**A6. FINER diagnostic (fallback)**: If the RQ resists sharpening after 2+ rounds of refinement with no meaningful improvement, apply [FINER criteria diagnostically](references/finer-criteria.md) to identify where the question is structurally weak. A failed criterion becomes an improvement direction.

**A7. Anti-pattern check**: When providing feedback on a draft RQ, reference common failure patterns from [rq-antipatterns.md](references/rq-antipatterns.md) to help the user recognize structural problems.

**Lightweight path for descriptive RQs**: Steps A1-A4 → Phase B (skip A5 PICO; A6 FINER diagnostic only if needed).

**→ "Does this expression of your RQ feel right? Let's run the quality check."**

#### Phase B: Quality Gate

Formally evaluate the sharpened RQ with [rq-quality-checklist.md](references/rq-quality-checklist.md):

1. Stage 1a (Structural Soundness: items 1-3) → Stage 1b (Research Fitness: items 4-7)
2. Stage 2 (Structural Check: items 8-13)
3. Iterate improvements through dialogue until the user is satisfied with the RQ

When all items pass, identify the weakest item and explicitly state the rationale for marking it OK.

**→ On completion: "You can also design a plan with /research plan or create an interview guide with /research interview" (optional)**

---

## `/research plan` — Research Plan Design

### Entry Gate

"What do you want to clarify through this research?"

| User's state        | Response                                                  |
| ------------------- | --------------------------------------------------------- |
| Presents a clear RQ | Proceed directly → Step 1                                 |
| Vague explanation   | Confirm direction in 1-2 exchanges → Step 1               |
| "I don't know"      | Suggest `/research rq` and recommend building an RQ first |

**What this does NOT do**: Full RQ construction (4 steps). The entry gate only confirms "directional alignment."

### Step 1: RQ Nature Analysis

Determine the research direction based on the nature of the RQ:

- **Exploratory** (Why? How?) → Qualitative research recommended (interviews, behavioral observation)
- **Confirmatory** (Is X true? Which one?) → Quantitative research recommended (surveys, A/B testing)
- **Mixed** → Sequential design: qualitative to form hypotheses, then quantitative to validate

**→ Confirm the RQ nature and recommended direction with the user**

### Step 2: Research Method Selection

Based on the direction from Step 1, propose specific methods with pros/cons and fit analysis.

See [research-methods.md](references/research-methods.md) for method details.

Claude research: Conduct web research on best practices during method selection.

**→ User selects a method**

### Step 3: Participant Definition

- Screening criteria (age, occupation, behavioral characteristics, etc.)
- Recruitment criteria
- Sample size guidelines (qualitative: 5-8 participants, quantitative: statistically significant N)

**→ Confirm participant definition with the user**

### Step 4: Analysis Approach

- How to analyze collected data to answer the RQ
- Qualitative: thematic analysis, affinity diagramming, KJ method, etc.
- Quantitative: descriptive statistics, cross-tabulation, hypothesis testing, etc.
- Completion criteria for analysis (what constitutes having answered the RQ)

Output: Research plan document (a single document summarizing RQ, methods, participants, estimated schedule, and analysis approach)

**→ Confirm the entire research plan with the user. Iterate revisions as needed**

---

## `/research interview` — Interview Guide Creation

### Entry Gate

"What do you want to clarify through this interview? Who are the participants?"

| User's state      | Response                                                                      |
| ----------------- | ----------------------------------------------------------------------------- |
| Has RQ + plan     | Proceed directly → Step 1                                                     |
| Has RQ only       | Briefly confirm participants and time allocation → Step 1                     |
| Vague explanation | Confirm purpose and participants in 1-2 exchanges → Step 1                    |
| "I don't know"    | Suggest `/research rq` and recommend clarifying "what you want to know" first |

**What this does NOT do**: Research plan creation, full RQ construction.

### Step 1: Converting RQs to Interview Questions

Core principle: **RQ ≠ Interview Question**

For each RQ, design a set of questions that indirectly elicit answers.

See [interview-design.md](references/interview-design.md) for RQ → IQ conversion principles and examples.

Conversion checks:

- Is it non-leading?
- Is it open-ended? (doesn't end with Yes/No)
- Does it ask about specific experiences? ("the last time you..." rather than "usually...")

**→ Confirm conversion results with the user**

### Step 2: Interview Structure Design

4-part structure:

1. **Warm-up** (5-10 min): Build rapport. Questions related to the theme but easy to answer
2. **Core questions** (20-30 min): Question sets converted in Step 1. Elicit answers to the RQs
3. **Deep-dive questions**: Prepare follow-up patterns for each response ("Why is that?" "Can you be more specific?" "What else?")
4. **Closing** (5 min): Check for "anything else you wanted to share" or "anything we missed"

Output: Interview guide with explicit RQ mapping for each question

| #   | Section | Question | Mapped RQ | Intent        |
| --- | ------- | -------- | --------- | ------------- |
| 1   | Warm-up | ...      | -         | Build rapport |
| 2   | Core    | ...      | RQ1       | ...           |
| ... | ...     | ...      | ...       | ...           |

**→ Confirm the interview guide with the user. Iterate revisions as needed**

---

## `/research survey` — Survey Question Design

### Entry Gate

"What do you want to clarify through this survey? Who are the respondents?"

| User's state                                                                | Response                                                                  |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| Has RQ + nature (exploratory/confirmatory) declared + sampling concept | Proceed directly → Step 1                                                 |
| Has RQ but nature unclear                                                   | Confirm RQ nature (exploratory vs confirmatory) in 1-2 exchanges → Step 1 |
| Has RQ only                                                                 | Briefly confirm respondent profile and survey context → Step 1            |
| Vague explanation                                                           | Confirm purpose and respondents in 1-2 exchanges → Step 1                 |
| "I don't know"                                                              | Suggest `/research rq` (no RQ) or `/research plan` (no overall design)    |

**Minimum thresholds for "proceed directly"** (avoid stalling on missing detail):

- **RQ**: One sentence that names target population and the phenomenon to measure. Sharpness (PICO-level specificity, exact metric definitions) is *not* required here — it is handled inside Step 1. If the RQ is purely conversational, run `/research rq` instead.
- **Nature declared**: The user has indicated direction — either confirmatory (hypothesis to test, comparison expected) or exploratory ("we don't know yet, want to see distributions"). Explicit framing words are not required if the wording makes the direction obvious.
- **Sampling concept**: Target population is named and an order-of-magnitude N is given (e.g., "around 100 active users", "~200 returning users"). Detailed recruitment criteria, screening rules, and sampling frame are *not* required — those belong to `/research plan`.

**What this does NOT do**: Sampling design, distribution planning, or post-fielding analysis (delegate to `/research plan`); full RQ construction (delegate to `/research rq`); cognitive-interview technique detail (delegate to `/research interview`).

**Lightweight path** (validated-scale-only surveys: NPS, single CSAT, SUS):

- (a) Step 1 confirms only that the validated scale matches the construct
- (b) Step 3b locks the wording verbatim from the original
- (c) Skips Step 2 detailed selection and Step 4a bias checklist
- (d) Phase B applies only contextual fit and validated-scale fidelity items

### Step 1: Operationalization

Core principle: **RQ ≠ SQ (Survey Question)**

For each RQ, decompose abstract constructs into measurable indicators in two steps:

1. **RQ → Construct**: Identify the abstract concepts the RQ refers to (e.g., engagement, perceived value)
2. **Construct → Indicator**: Decompose each construct into observable items

For each construct, decide single-indicator vs multi-item scale, and whether to adopt a validated scale (NPS, SUS, SERVQUAL, ACSI, CSAT) verbatim.

See [survey-design.md](references/survey-design.md) for RQ → SQ conversion principles and validated-scale guidance.

Output: Construct × Indicator mapping table

| RQ  | Construct | Indicator | Validated scale? | Single / Multi-item |
| --- | --------- | --------- | ---------------- | ------------------- |

When multiple RQs share constructs, list them in the same table — repeat the RQ column or group rows under each RQ. There is no need to split by RQ unless they target disjoint constructs.

**→ "Does this operationalization cover what the RQ needs to measure?"**

### Step 2: Question Type Selection

Match each indicator to an appropriate question type.

| Indicator characteristic           | Recommended type                  |
| ---------------------------------- | --------------------------------- |
| Continuous attitude / satisfaction | Likert / VAS                      |
| Binary judgment                    | Single-select (Yes/No)            |
| Multiple applicable options        | Multi-select                      |
| Preference order                   | Ranking                           |
| Open opinion                       | Open-text                         |
| Quantity                           | Numeric input                     |
| Recommendation likelihood          | NPS (10-point)                    |
| Multiple items on the same scale   | Matrix (with straight-lining caveat) |

Output: Indicator × Question Type table

**→ "Are these question types appropriate for each indicator?"**

### Step 3: Scale + Wording + Order Design

#### 3a. Scale design (rating items only)

Walk the decision tree for points (5/7/10), midpoint policy, N/A handling, and anchor labels.

See [scale-decision-tree.md](references/scale-decision-tree.md).

#### 3b. Wording design

For each draft SQ:

1. Ask the user to write a draft (rough is fine)
2. Diagnose against anti-patterns one at a time: leading, double-barreled, loaded, double negation, jargon, embedded assumption
3. Display **Before → After** to make the improvement visible

See [wording-antipatterns.md](references/wording-antipatterns.md).

#### 3c. Order design

- Funnel (general → specific) vs inverted funnel (specific → general): pick one with rationale
- Place sensitive items late (after rapport / trust is built)
- For confirmatory surveys, decide on order randomization within blocks

**→ "Are the scale, wording, and order decisions sound?"**

### Step 4: Bias Mitigation + Cognitive Interview Plan

#### 4a. Response Bias checklist

Walk the SQ list against typical biases (Acquiescence, Social Desirability, Central Tendency, Recall, Extreme Response). For each detected risk, apply a mitigation or accept the risk explicitly.

See [response-bias-checklist.md](references/response-bias-checklist.md).

Output: Bias annotation table

| SQ  | Detected biases | Applied mitigations | Residual risk |
| --- | --------------- | ------------------- | ------------- |

#### 4b. Cognitive Interview plan

Pretest the survey via cognitive interviewing before fielding:

- **Technique**: Think-aloud (concurrent or retrospective) + probing — reuses techniques from `/research interview`
- **Iterative design**: 3 rounds × 5-9 participants is more effective than a single 27-person pass
- **Detection focus**: Comprehension issues, ambiguous interpretation, recall difficulty, fatigue points

**→ "Is the bias mitigation and cognitive interview plan complete?"**

### Phase B: Quality Gate

Formally evaluate the SQ set with [survey-quality-checklist.md](references/survey-quality-checklist.md):

1. Stage 1 (Structural Soundness: items 1-5)
2. Stage 2 (Implementation Quality: items 6-11)
3. Iterate improvements through dialogue until the user is satisfied

When all applicable items pass, identify the weakest item and explicitly state the rationale for marking it OK.

**→ On completion: "You can finalize sampling and analysis with `/research plan`, or pilot via cognitive interviewing using `/research interview` techniques" (optional)**

---

## Responsibility Boundaries

|                                  | rq  | plan | interview | survey |
| -------------------------------- | --- | ---- | --------- | ------ |
| Full RQ construction (4 steps)   | Yes | No   | No        | No     |
| Brief directional confirmation   | -   | Yes  | Yes       | Yes    |
| Research method selection        | No  | Yes  | No        | No     |
| Full participant definition      | No  | Yes  | No        | No     |
| Brief participant confirmation   | No  | -    | Yes       | Yes    |
| IQ design                        | No  | No   | Yes       | No     |
| SQ design                        | No  | No   | No        | Yes    |
| Cognitive interview planning     | No  | No   | -         | Yes    |
| Redirect when context is lacking | -   | Yes  | Yes       | Yes    |

## Downstream Skill Connections

- `/research rq` → Starting point for conducting interviews or surveys
- `/research survey` → Pilot via cognitive interviewing (`/research interview` for technique reuse)
- Survey results → `/analyze` (KPI / funnel sense-making)

## Artifact Management

### SSOT Principle

The SSOT for artifacts is agent-memory. The plan file is a working document during the session, not the final version. Output to external files (e.g., ~/Downloads) is done only on user request, generated from agent-memory content. Do not maintain the same content in multiple locations.

### Constraint Management

Constraints discovered during dialogue (e.g., via criticize, such as "hypothetical questions are NG because they demand self-analysis") are saved as `constraints.md` in the relevant research directory in agent-memory. When updating artifacts, always re-read constraints.md and verify no constraints are violated.

### Consistency Check Gate

When an RQ is modified or before outputting an interview guide or survey questions, run a consistency check by referring to [artifact-consistency-checklist.md](references/artifact-consistency-checklist.md).

## Strict Rules

1. Never skip checkpoints (→)
2. Always distinguish RQ ≠ Interview Question
3. Never present Claude's research as "answers" — weave them in as sparring material
4. Proceed one question at a time — never ask multiple questions at once
5. Do not force progress at the entry gate — if context is lacking, direct to the appropriate subcommand
6. Do not perform full RQ construction (4 steps) within `/research plan` or `/research interview`
7. When a quality check shows all items OK, identify the weakest item and explicitly state the rationale for marking it OK
8. Conduct external research only within a range that does not disrupt the dialogue flow
9. The SSOT for artifacts is agent-memory — the plan file is a working document during the session, not the final version
10. When an RQ, hypothesis, or guide is modified, run a consistency check based on [artifact-consistency-checklist.md](references/artifact-consistency-checklist.md)
11. Save constraints discovered during dialogue to constraints.md in agent-memory, and re-read them when updating artifacts
12. Do not rank exploratory RQs and hypothesis-driven RQs — propose the appropriate type based on the user's knowledge state
13. When adopting a validated scale (NPS, SUS, SERVQUAL, ACSI, CSAT, etc.) in `/research survey`, do not modify the original wording or use a partial subset of items — comparability and benchmarking depend on exact, full replication. If response burden is too high, drop the validated scale and design a custom multi-item scale instead, or move that construct to a separate study. Adaptations strictly necessary for translation must be documented with rationale

## Completion Criteria

### `/research rq`

- At least one RQ has passed the quality checklist
- The user is satisfied with the RQ

### `/research plan`

- A research plan document (RQ, methods, participants, analysis approach) is complete
- The user has agreed to the plan

### `/research interview`

- Interview questions are designed for all RQs
- A 4-part interview guide is complete
- The user has agreed to the guide

### `/research survey`

- All SQs have passed Stage 1 of the survey quality checklist
- The SQ set has been reviewed against typical response biases
- A cognitive interview plan exists
- The user has agreed to the SQ set
