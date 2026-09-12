# Question Altitude Ladder

A tool for raising a draft Research Question from the **feature level** to the **level of practice**. Used in Step 4 Phase A (A2) of `/research rq`.

The rest of Phase A sharpens an RQ — it makes population, variables, and scope more specific. That direction alone is not enough. A question whose subject is a feature can only ever discover facts about that feature. It cannot discover the practice the feature sits inside, and it cannot see the people who accomplish the same thing by other means.

---

## Why Altitude Matters

Qualitative research exists to **find a group**. It does that by combining three moves — observing behavior, hearing the background of the act, and analyzing — and the altitude of the question decides whether a group can come into view at all. Too low and the answer describes one person; too high and it describes everyone, which is the same as describing no one.

An insight is the **greatest common divisor** of a user group — the tacit value or need that overlaps across its members. It is not the peculiar behavior of one individual.

A feature-level question fails at this in two ways:

1. It takes one group's surface behavior (people who touch the feature) as the object of study, so the common denominator across the whole population never comes into view.
2. It treats non-users of the feature as a **residual category** — "people who have not done it yet" — instead of as people who may have established a different practice entirely.

Raising altitude is how you get the question to point at the common denominator instead of at the feature.

---

## The Core Operation

**Raising abstraction is not using bigger words. It is removing one premise from the question.**

A draft RQ typically carries several removable premises at once. Remove them one at a time — each removal produces a different, separately useful framing question.

Do not remove all four at once. That produces a question so general it fits any service, which is useless for design (see Ceiling Test).

---

## The Four Levers

| Lever | Premise being removed | Signal in the draft | Removal question |
| --- | --- | --- | --- |
| 1. Negation | The behavior is an absence to be fixed | "Why do users **not** ...", "barriers to ...", "blockers", "drop-off" | What **is** this act, to the person performing it? Whom is it addressed to, and for what? |
| 2. Feature ★ | The unit of analysis is a feature / screen / UI | A product noun is the grammatical subject: "the rating UI", "the search filter" | What **practice** is this feature embedded in, and where in that practice does it sit? |
| 3. Individual | The unit is one person at a time | "users", "each employer", attitudes and perceptions held individually | What tacit rules are forming **among** this group? Is the act natural or alien within them? |
| 4. Time | The present arrangement is the natural one | The question is stated entirely in the present tense, with no reference to what preceded it | How was this practice **remade** when the surrounding arrangement changed? |

★ Lever 2 is the primary one. When in doubt about which lever to apply, apply this one.

### Worked Example

**Draft RQ**: "Between employers who have rated at least once in the past 3 months and employers who have not rated in 3 consecutive months, what differences are there in awareness of the rating UI and in the factors blocking rating behavior?"

| Lever | Resulting framing question |
| --- | --- |
| 1. Negation | For an employer, what kind of act is leaving a record about someone who worked a few hours? Whom is it for — the platform, the next employer, the worker, or their own future self? |
| 2. Feature | How do employers running spot work carry out the work of **sizing people up**? Where does the rating feature sit inside that procedure? |
| 3. Individual | What tacit norms are forming among habitual spot-work employers about how to deal with workers? Within those norms, is rating a natural act or a foreign one? |
| 4. Time | "Evaluating a person" presumed a continuing employment relationship. How was that practice remade once the same labor is used repeatedly but never continuously? |

Note what Lever 2 buys: the framing question **holds for employers who never touch the feature**. They also size people up; they just do it by other means.

---

## Functional Equivalents

Lever 2 leads directly to the most useful follow-up question:

> What else are they using to accomplish what this feature accomplishes?

Naming the substitutes (direct re-invitation, blocking, the site manager's memory, a handwritten note on the shift sheet, a message in the team chat) changes the competitive picture. The feature is not competing with a void. It is competing with **substitutes that already work**.

This also gives the "no trigger exists" style of causal explanation a deeper layer instead of contradicting it: there is no trigger because something else already discharges the need.

---

## Floor Test

Altitude has a lower bound. Test every framing question:

> If this question were answered, would a **group** come into view — or only an account of what particular individuals did?

- **A group comes into view → keep it.** The answer names a shared practice, a shared substitute, or a shared norm that more than one person is running.
- **Only individuals → it is too low.** Apply the Individual lever and raise it to the level of the group's tacit rules.

Signals that a draft is below the floor: the subject is one person's attributes or one account; the expected answer takes the form "this person did X because Y"; the question could be settled by reading a single interview transcript.

This is not the same check as item 6 (Generalizable) in [rq-quality-checklist.md](rq-quality-checklist.md), and the two fire at different times. Item 6 asks, after the fact, whether a finding transfers beyond the case studied. The Floor Test asks, during the dialogue, whether the question is even aimed at a group — a question can produce a transferable-sounding statement while never having looked for a group at all.

## Ceiling Test

Altitude has an upper bound. Test every framing question:

> Would this question hold, unchanged, for an unrelated service — e-commerce reviews, home-sharing, used cars?

- **Yes → it is too high.** Drop back one level. A question that fits everything constrains no design decision.
- **No, it carries this domain's context → keep it.**

The usable band is bounded on both sides: **above the floor** (a group comes into view) and **below the ceiling** (this domain's context is still attached). Within it, the question is general enough to cover non-users of the feature. Levers 1–3 usually land inside that band. Lever 4 lands above it: it is a good question to hold for a year, but it cannot inform next quarter's decision. Offer Lever 4 only when the user has a long-horizon research program, and say what it costs.

---

## The Framing Question Is Not an RQ

The framing question does **not** replace the RQ. It is an interpretive frame laid on top of it, and the two are carried forward as a set.

Consequently:

- The framing question is **exempt from the specificity and scope checks** in [rq-quality-checklist.md](rq-quality-checklist.md) (item 5 Specific, item 11 Scope) and from the Scope Explosion anti-pattern in [rq-antipatterns.md](rq-antipatterns.md). Those apply to the RQ only. Judging the framing question by them defeats its purpose.
- The framing question is instead judged by exactly two criteria: the Floor Test and the Ceiling Test.
- If a user wants to promote a framing question into the RQ itself, it must then pass the full checklist like any other RQ.

---

## What Changes Downstream

Record the framing question alongside the RQ, because three things downstream depend on it:

| Area | Without the frame | With the frame |
| --- | --- | --- |
| Segmentation | The non-using group is treated as one block | The group is split by which substitute they use |
| Interview questions | "Why don't you use it?" — demands self-analysis, returns rationalization | "How much do you remember about the last worker who came?" "When there is someone you want back, what do you do?" — practices surface only through recent, concrete episodes |
| Analysis frame | Only passages mentioning the feature are coded | Passages where the practice appears **without** mentioning the feature are also in scope |

The interview column is the reason `/research interview` takes the framing question as an input, not just the RQ.

One more thing travels downstream. A framing question about a practice usually cannot be answered by asking alone — practices are visible in what people do, not only in what they say about it. When that is the case, say so beside the RQ so `/research plan` can walk its Evidence Coverage Gate with the requirement already on the table.
