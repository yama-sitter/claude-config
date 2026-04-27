# Response Bias Checklist

Checklist of common response biases in survey research, with detection cues and mitigation strategies. Used in Step 4a of `/research survey`.

Run this checklist against the SQ list produced by Step 3 before moving to the cognitive interview plan.

---

## 1. Acquiescence Bias (yea-saying)

Tendency to agree with statements regardless of content. Inflates positive responses on agreement scales.

- **Detection cues**:
  - All Likert items are phrased in the same direction (all positive)
  - Construct measured by agreement-only items
  - Population includes respondents likely to be cognitively fatigued or rushed
- **Mitigation**:
  - Mix item directions: alternate positive and negative wording within a multi-item scale
  - Reverse-score the negative items in analysis
  - Avoid pure agreement scales for low-stakes constructs — prefer behavioral frequency or specific evaluations
- **Caveat**: Reversed items can backfire if wording is awkward or confusing. Test in cognitive interview.

---

## 2. Social Desirability Bias

Tendency to answer in ways that present the respondent favorably. Inflates reports of socially valued behaviors (exercise, healthy eating) and deflates reports of stigmatized ones (alcohol use, skipping work).

- **Detection cues**:
  - Question touches identity, ethics, health, finance, or social norms
  - Survey is not anonymous
  - Question asks about general habits ("how often do you exercise?") rather than specific events
- **Mitigation**:
  - Emphasize anonymity in the introduction
  - Replace "usually / typically" with concrete recall ("in the past 7 days, how many days did you...")
  - Use forced-choice formats that pair socially-equivalent options
  - For very sensitive topics, consider list-experiment or randomized-response techniques

---

## 3. Central Tendency Bias

Tendency to avoid scale extremes and cluster around the midpoint. Compresses variance and obscures real differences.

- **Detection cues**:
  - 5-point or 7-point scales with a labeled midpoint and weak anchor labels
  - Long matrix questions where respondents are fatigued
  - Topics on which respondents have weak or unformed opinions
- **Mitigation**:
  - Sharpen anchor wording to make extremes feel achievable ("Strongly agree" not "Completely agree")
  - For constructs that demand a stance, use even-numbered scales (no midpoint)
  - Break long matrix questions into multiple shorter blocks
  - Make sure the midpoint is genuine neutrality, not a "no opinion" placeholder — separate N/A as a distinct option

---

## 4. Recall Bias

Errors in retrospective reports due to memory limits, especially for frequent or low-salience behaviors.

- **Detection cues**:
  - Question asks about behavior over a long period ("in the past year")
  - Behavior is high-frequency or routine (likely to blur in memory)
  - Question asks for precise counts of unmemorable events
- **Mitigation**:
  - Shorten the recall window to a period the respondent can actually remember (last 7 days, last month)
  - Anchor recall to a specific event ("the last time you used the product")
  - Provide bracketed ranges instead of asking for exact counts ("0", "1–2", "3–5", "6+")
  - For very recent behavior, prefer experience sampling over retrospective surveys

---

## 5. Extreme Response Bias

Tendency to choose endpoints regardless of content. Inflates apparent strength of opinions; varies by culture and personality.

- **Detection cues**:
  - Population spans cultures with different extremity norms
  - Topics on which respondents have strong identity-relevant opinions
  - Scale lacks intermediate gradations
- **Mitigation**:
  - Use 7-point scales where finer gradations let extreme-leaning respondents differentiate
  - Add behavioral-frequency items as cross-checks ("how many times did you...")
  - In analysis, report distributions, not just means — extreme response shows up as bimodality

---

## How to Apply This Checklist

For each bias above, walk through the SQ list one bias at a time:

1. **Scan**: Which SQs match the detection cues?
2. **Annotate**: Mark the affected SQs with the bias name (e.g., `Q4 — Acquiescence risk: all positive Likert items`)
3. **Decide**: Apply a mitigation strategy or accept the risk with explicit acknowledgement
4. **Re-check**: After applying mitigations, run through the cues again to confirm the risk is reduced

## Output

Produce a Bias Annotation table:

| SQ | Detected biases | Applied mitigations | Residual risk |
|---|---|---|---|
| Q4 | Acquiescence | Reversed Q5 wording | Low |
| Q7 | Social Desirability | Anonymity emphasized; specific 7-day recall | Medium |
| Q11 | Recall | Shortened window to past month | Low |

The residual risk column feeds into the cognitive interview plan: items with Medium or High residual risk should be probed during pilot testing.
