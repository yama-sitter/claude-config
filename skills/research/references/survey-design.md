# Survey Question Design Principles

Principles for converting RQs (Research Questions) into usable survey questions (SQs). Used in Steps 1-2 of `/research survey`.

## Core Principle: RQ ≠ SQ

| | RQ (Research Question) | SQ (Survey Question) |
|---|---|---|
| Purpose | What you want to know through the entire research | Items actually administered to respondents |
| Level | Strategic, high-level | Tactical, measurable |
| Form | Conceptual (involves constructs) | Concrete (closed-form, scaled, or numeric) |
| Count | 2-3 | Multiple (3-15 per construct, depending on scale) |

**Why you must not ask the RQ directly**: RQs reference abstract constructs (satisfaction, engagement, trust) that respondents cannot reliably self-report in a single direct question. Operationalization decomposes a construct into observable indicators that can be administered as discrete items.

## Operationalization: RQ → Construct → Indicator

A two-step decomposition. This is the central activity of survey design and has no analog in qualitative interview design.

### Step 1: RQ → Construct

Identify the abstract concepts the RQ refers to.

- RQ: "Why are returning users dropping off in their second month?"
- Constructs: *Engagement*, *Perceived value*, *Friction*

### Step 2: Construct → Indicator

Decompose each construct into observable, measurable indicators.

- Construct: *Engagement*
  - Indicators: frequency of use last 7 days, number of features touched, session length
- Construct: *Perceived value*
  - Indicators: agreement with "this product is worth what I pay for it", likelihood to recommend, willingness to renew

### Single Indicator vs Multi-Item Scale

| Choice | When to use | Trade-off |
|---|---|---|
| **Single indicator** | Construct is concrete and unambiguous (e.g., "frequency of use") | Simpler, but fails when the construct is multi-faceted |
| **Multi-item scale** | Construct is abstract (e.g., "satisfaction", "trust") | Higher reliability via internal consistency (Cronbach's α), but longer survey |

A multi-item scale measuring the same construct with 3-7 items is the default for abstract constructs. Internal consistency can then be verified post-hoc.

## Conversion Patterns by RQ Type

### Pattern 1: Descriptive RQ → Direct measurement of state

- RQ: "What is the current satisfaction level among power users?"
- SQ: "Overall, how satisfied are you with [product]?" (5-point Likert) + multi-item satisfaction scale

### Pattern 2: Relational RQ → Measure both variables independently

- RQ: "Is feature usage frequency associated with renewal intent?"
- SQ A (frequency): "In the past 7 days, how many days did you use [feature X]?" (numeric)
- SQ B (renewal intent): "How likely are you to renew your subscription?" (5-point likelihood)

### Pattern 3: Causal RQ → Measure exposure, outcome, and confounders

- RQ: "Does completing onboarding improve 30-day retention?"
- SQ A (exposure): "Did you complete the welcome tutorial?" (Yes/No)
- SQ B (outcome): "Have you used the product in the past 7 days?" (Yes/No)
- SQ C (confounders): tenure, plan tier, prior product experience

For causal RQs, observational survey data alone is rarely sufficient — pair with experiment design or longitudinal measurement.

### Pattern 4: Comparative RQ → Same SQs across segments

- RQ: "Do enterprise users perceive setup as harder than self-serve users?"
- SQ: "How easy was it to set up [product]?" (5-point) — administered to both segments, compared in analysis.

## Existing Validated Scales

Prefer validated scales when they fit the construct. Do not modify their wording — comparability and benchmarking depend on exact replication.

| Scale | Construct | Items | Notes |
|---|---|---|---|
| **NPS** (Net Promoter Score) | Loyalty / advocacy | 1 (single 0-10 item) | Industry-standard benchmark; do not paraphrase the wording |
| **SUS** (System Usability Scale) | Perceived usability | 10 | Mature, comparable across products |
| **SERVQUAL** | Service quality | 22 (5 dimensions) | Heavy; consider only for service-heavy products |
| **ACSI** (American Customer Satisfaction Index) | Overall satisfaction | 3 | Lightweight composite |
| **CSAT** | Transactional satisfaction | 1 (single Likert) | Easy to embed in flows |

## Conversion Checklist

Verify that each SQ meets the following:

- [ ] **Mapped to a construct**: Each SQ traces to a named construct from Operationalization
- [ ] **Closed-form unless intentional**: Open-text only when no closed form fits the indicator
- [ ] **Single concept per item**: Asks one thing (no double-barreled)
- [ ] **Concrete reference period**: "in the past 7 days" rather than "usually"
- [ ] **Vocabulary at respondent level**: No analyst jargon (no "retention", "DAU", "cohort")
- [ ] **Validated scales preserved verbatim**: If using NPS/SUS/etc., wording is unchanged

## Output Format

Step 1 (Operationalization) output is a Construct × Indicator table. SQ wording and Question Type are decided in Step 2 / Step 3 — keep them out of this table to avoid premature commitment.

| RQ | Construct | Indicator | Validated scale? | Single / Multi-item |
|---|---|---|---|---|
| RQ1 | Engagement | days used last 7d | — | Single |
| RQ1 | Engagement | features touched in last 7d | — | Single |
| RQ1 | Perceived value | overall worth | NPS | Single |
| RQ1 | Perceived value | met-expectations / would-renew / fair-price | — | Multi-item (3 items) |
