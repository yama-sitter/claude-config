# Wording Anti-Patterns

A catalog of common survey question wording failure patterns. Each anti-pattern is tagged with the quality checklist item it violates, the failure reason, and a corrected version.

Referenced in Step 3b of `/research survey` to help users recognize and fix wording problems in their draft SQs.

---

## 1. Leading Question

The question is phrased to suggest a particular answer, biasing respondents toward that answer.

- **Violates**: Wording neutrality (Stage 1, Wording)
- **Bad**: "Our easy-to-use interface makes your job simpler, doesn't it?"
  - Embeds the assumption that the interface is easy to use
- **Good**: "How would you describe the usability of this interface?"
  - Lets respondents bring their own assessment

---

## 2. Double-Barreled Question

The question bundles two or more concepts, making it impossible to answer cleanly when the respondent feels differently about each.

- **Violates**: Single concept per item (Stage 1, Wording)
- **Bad**: "How satisfied are you with the quality and price of our product?"
  - A respondent who loves the quality but hates the price has no clean answer
- **Good**: "How satisfied are you with the product's quality?" + a separate item for price
  - Each concept gets its own item, results disaggregated for analysis

---

## 3. Loaded Question

The question contains emotionally charged or evaluative language that pulls responses toward a tone.

- **Violates**: Wording neutrality (Stage 1, Wording)
- **Bad**: "We're excited to launch our innovative new feature. How thrilled are you about it?"
  - "Excited", "innovative", "thrilled" frame the feature positively before the respondent answers
- **Good**: "What is your opinion of the new feature?"
  - Removes evaluative loading

---

## 4. Negation / Double Negative

The question uses negation — especially nested negations — that increase cognitive load and create misinterpretation.

- **Violates**: Comprehension load (Tourangeau Stage 1, Wording)
- **Bad**: "Do you disagree that our service is not unreliable?"
  - Three layers of negation; respondents cannot reliably parse
- **Good**: "How reliable is our service?"
  - Direct, positive framing

---

## 5. Jargon / Analyst Vocabulary

The question uses internal team terminology, technical jargon, or analyst-centric concepts that respondents do not share.

- **Violates**: Participant-perspective vocabulary (Stage 1, Wording)
- **Bad**: "Rate the usability profile of the onboarding funnel."
  - "Usability profile", "funnel" are analyst terms
- **Good**: "How easy was it to get started with the product?"
  - Phrased in respondent vocabulary

---

## 6. Embedded Assumption

The question presupposes a behavior, attitude, or fact that may not apply to the respondent.

- **Violates**: Coverage / non-applicability handling (Stage 1, Wording)
- **Bad**: "When you use our app daily, what issues do you face?"
  - Assumes daily use; weekly users have no clean answer
- **Good**: Filter first ("How often do you use our app?"), then ask the issues question only of those who match the assumed condition. Or rephrase: "When you use our app, what issues, if any, do you face?"

---

## How to Use This Reference

When a user's draft SQ has a wording problem, identify the closest anti-pattern and:

1. Name the pattern (e.g., "This looks like a Double-Barreled Question")
2. Explain briefly why it is problematic (one sentence)
3. Show the contrast between the bad and good versions
4. Ask the user to rewrite — do not rewrite for them
5. Display Before → After when the rewrite lands, to make the improvement visible

This reference complements `survey-quality-checklist.md`: the checklist tells you **what** is wrong; anti-patterns tell you **why** it is wrong and suggest a direction for fixing it.
