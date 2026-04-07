# Step 5c Multi-Lens Job Statement Generation

For each Job from 5b, generate candidate Job Statements through 3 different analytical lenses. The goal is to produce diverse hypotheses as discussion material, not to converge on a single answer.

## Lens 1: Belief Chain (顧客の主観的ロジック)

Extract the customer's own subjective reasoning from Step 1 Fact Tables — statements where the customer says "because X, I did Y" or "X means Y to me."

Process:

1. For each case, extract belief chains in the form: "If [situation] + [means] → [result], and that means [value to me]"
2. Place the 3 cases' belief chains side by side and identify **structurally similar beliefs** (not identical words, but the same reasoning pattern)
3. Express the shared belief structure as When / I want to / So that
4. Map each element of the shared belief structure to cross-case abstractions (P\*-S\*/P\*-St\* and/or CF-\*) for the 根拠 column. If a belief element has no corresponding cross-case abstraction, note this gap — it may indicate a missing pattern in Step 3 or a single-case signal

## Lens 2: Synthesis Model (ゴール + 制約 + 触媒)

Using Step 3 P*-S*/P*-St* and Step 4b 共通ナラティブ:

1. Classify P*-S*/P*-St* items into Goals (progress the customer wants to achieve) / Constraints (walls blocking that progress) / Catalysts (events that made the constrained goal unbearable)
2. A Job is synthesized at the moment: "A Goal that could not be achieved due to Constraints becomes unbearable because of a Catalyst"
3. When = Catalyst + Constraint becoming acute, I want to = bypass the Constraint toward the Goal, So that = achieve the Goal

## Lens 3: Emotional/Social Job (感情的・社会的ジョブ)

Extract emotional and social signals from Step 1 Fact Tables — expressions of relief, anxiety, pride, liberation, peer comparison, identity, or self-perception.

Process:

1. For each case, extract verbatim quotes containing emotional expressions (安心, 不安, 衝撃, 解放, 誇り) or social expressions (同業者との比較, 自己認識の変化, 周囲の評価)
2. Place the 3 cases' emotional/social signals side by side and identify structurally similar patterns
3. Express as When / I want to / So that, focusing on what the person wanted to FEEL or how they wanted to BE SEEN, not what they wanted to DO

Note: Emotional/Social Jobs often share the When clause with Functional Jobs but diverge in I want to and So that. This is expected — the same situation creates both functional and emotional demand.

## Traceability Rules (apply to all lenses)

- A clause with an empty 根拠 column is prohibited — every clause must be grounded in cross-case abstractions (P*-S*/P*-St* and/or CF-\*)
- The 出典 column is optional — it provides supporting evidence from individual Facts
- Per-case Forces (4a) MUST NOT appear in the 根拠 column — they are individual-level analysis, not cross-case abstractions
- For Lens 3, emotional/social signals from individual Facts (F-XX) may appear in the 根拠 column when no cross-case abstraction captures the emotional dimension. In this case, cite the Facts directly and note that the pattern is observed across 2+ cases

## RQ Bias Guard (apply to all lenses)

- P*-S*/P*-St* patterns and CF-* forces were derived from data, but through phases and dimensions that may reflect RQ assumptions. When a lens output closely mirrors the RQ's expected demand structure, verify independently against Step 1 Fact Tables that this structure is data-grounded, not RQ-inherited
- Lens 1 (Belief Chain) is the strongest RQ-independence check because it starts from verbatim customer quotes. If Lens 1 outputs diverge significantly from Lens 2 outputs, this may indicate that Section 2 patterns (used by Lens 2) have been RQ-influenced — flag this divergence for the user and present both candidate sets in 5e for comparison
