# Scale Decision Tree

Decision tree for designing rating scales (Likert, semantic differential, satisfaction, etc.) in survey questions. Used in Step 3a of `/research survey`.

## When to Apply

Apply this tree when the question type requires a **rating scale** — i.e., Likert, agreement, satisfaction, frequency, importance, or any ordinal evaluation.

Skip this tree when the question type is single-select, multi-select, ranking, numeric input, or open-text. Skip when using a validated scale (NPS, SUS, CSAT) — adopt the standard scale verbatim.

## The Tree

### Decision 1: Number of points

| Choice | When to use |
|---|---|
| **5-point** | Default. Best for mobile UI. Sufficient discrimination for most product research. |
| **7-point** | When finer discrimination is needed and respondents are likely engaged (academic research, paid panels). |
| **10-point** | Only for benchmarks like NPS or when comparing to industry baselines that already use 10-point. |
| **4-point or 6-point** | Even-numbered scale; use only when forcing a directional answer is desirable (see Decision 2). |

### Decision 2: Odd vs Even (midpoint policy)

| Choice | Effect | When to use |
|---|---|---|
| **Odd (with midpoint)** | Allows neutral / "neither" responses | Default. Genuine neutrality is a real state for many topics. |
| **Even (no midpoint)** | Forces directional answer | When the construct demands a stance (e.g., binary preference); be aware of artificial polarization risk. |

If choosing odd, **always** evaluate Decision 3 (N/A handling) — odd scales blur the boundary between "neutral" and "doesn't apply".

### Decision 3: N/A or "Don't know" handling

| Choice | When to use | Trade-off |
|---|---|---|
| **Embedded (added as a scale option)** | When some respondents may not have an opinion | Easy for respondents, but mixes opinion data with non-opinion data — must filter in analysis |
| **Separated (offered as a distinct option, off-scale)** | Default | Cleaner data, slightly more UI complexity |
| **Omitted (forced answer)** | Only when the entire population definitely has an opinion | Risk of random selection if any respondent doesn't apply |

### Decision 4: Anchor labeling

| Choice | When to use |
|---|---|
| **Endpoint-only** (e.g., "Strongly disagree" ... "Strongly agree", numbers between) | Default. Lower cognitive load, common pattern. |
| **Fully labeled** (every point has a word: Strongly disagree / Disagree / Neutral / Agree / Strongly agree) | When the scale is unfamiliar or respondents need explicit calibration. Slightly higher load. |
| **Numeric-only** (e.g., 1–10 with no words) | NPS-style benchmarks; do NOT use for new constructs — interpretation drifts. |

## Context-Based Recommendations

| Context | Recommended scale |
|---|---|
| Mobile-first product survey | 5-point, odd, separated N/A, endpoint-only labels |
| In-depth attitude research (web, paid panel) | 7-point, odd, separated N/A, fully labeled |
| NPS / loyalty benchmark | 11-point (0–10), no midpoint policy decision (NPS standard) |
| CSAT / single-touch satisfaction | 5-point, fully labeled, no N/A (because the trigger is post-action) |
| Academic / clinical | 7-point, odd, separated N/A, fully labeled |

## Common Mistakes

- **Mixing scales within a survey** — Switching between 5-point and 7-point in adjacent questions confuses respondents. Pick one default and stick to it.
- **Using a midpoint when no neutrality exists** — Forcing "Neither agree nor disagree" on an inherently directional construct (e.g., purchase intent) inflates the midpoint with non-responses.
- **Reversing some items without flagging** — When mixing positive and negative item wording (a valid Acquiescence Bias mitigation), make sure analysis reverses the scoring; otherwise composite scores are nonsensical.
- **Inconsistent endpoint direction** — Sometimes putting "Strongly agree" on the left, sometimes on the right. Lock direction across the survey.

## Output

Record the chosen scale parameters alongside each rating question:

| SQ | Points | Odd/Even | N/A handling | Anchor labels |
|---|---|---|---|---|
| Q1 | 5 | Odd | Separated | Endpoint-only |
| Q2 | 5 | Odd | Separated | Endpoint-only |
| Q3 | 0–10 | (NPS) | None | Numeric-only |
