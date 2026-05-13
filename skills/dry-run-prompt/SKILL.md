---
name: dry-run-prompt
description: Empirically tune agent-facing text instructions (prompts / slash commands / CLAUDE.md sections / code-gen directives) and existing skills (SKILL.md + subfiles) by having a bias-free executor run them and evaluating both sides (executor self-report + caller-side metrics), iterating until improvement plateaus. Use immediately after creating or substantially revising a prompt or skill to dynamically verify trigger accuracy and self-containedness. Also use when agent behavior diverges from intent and the cause may be ambiguity in the instruction side. For creating a new skill from scratch (structure design, A/B bench), use skill-creator instead.
---

# Empirical Prompt Tuning

The quality of a prompt is invisible to its author. The more "clear" it seems to the writer, the more likely a different agent will get stuck on it. The core of this skill is to **have a bias-free executor actually run it, evaluate both sides, and iterate** until improvement plateaus.

## When to Use

- Immediately after creating or substantially revising a skill / slash command / task prompt
- When an agent is not behaving as expected and the cause may be ambiguity in the instruction
- When hardening a high-importance instruction (frequently used skill, automation-critical prompt)
- When verifying the trigger accuracy of an existing skill (does it dispatch on matching utterances? does it avoid misfiring on near-matches?)
- When verifying the self-containedness of an existing skill (can it complete a standard task with SKILL.md alone?)

Do not use when:
- The prompt is a one-off throwaway (evaluation cost not worth it)
- The goal is to reflect the author's subjective preference, not to improve success rate
- Creating a new skill from scratch (structure design, A/B bench) → use `skill-creator`

## Modes and Input Formats

This skill operates in 2 modes. Auto-detect from input; confirm interactively only when ambiguous.

**Input formats and mode selection:**

- **Primary input (recommended): skill name only** — e.g., `/dry-run-prompt arch-review`. Resolves `~/.claude/skills/<name>/SKILL.md` and launches in **skill evaluation mode**
- Fallback inputs:
  - Directory path / `SKILL.md` path (e.g., `skills/arch-review/`) → skill evaluation mode
  - Plain text paragraph / non-`.md` file → **prompt evaluation mode** (classic)
  - No argument → ask interactively (which skill / which instruction to target)
- **Resolution target is user skills (`~/.claude/skills/`) only.** Plugin skills (`~/.claude/plugins/`) are out of scope (plugins follow a separate lifecycle and are not meant to be freely modified by the user). If given a plugin name, return that it is not in user skills and ask interactively
- If the input cannot be resolved, do not dispatch a subagent — return a confirmation to the user
- If ambiguous (path points outside user skills, text argument might be mistaken for a skill name), have a subagent confirm the mode at the start

**Mode differences:** The only differences between prompt evaluation mode and skill evaluation mode are the **scenario design pattern** and the **[critical] template**. The skeleton (dual-side evaluation, convergence judgment, red flags) is shared.

## Workflow

0. **Iteration 0 — description / body consistency check** (static, no dispatch needed)
   - Read the trigger / purpose stated in the frontmatter `description`
   - Read the scope covered by the body
   - If there is a discrepancy, reconcile the description or body before proceeding to iteration 1
   - Example discrepancy: description says "navigation / form filling / data extraction" but body contains only `npx playwright test` CLI reference
   - Skipping this step lets subagents "re-interpret" the body to match the description, producing false-positive accuracy even when the skill does not actually meet the requirement
   - **Additional checks in skill evaluation mode:**
     - Are the trigger vocabulary (verbs / nouns) in the description covered by the body?
     - Is the subfile reference discipline (`references/`, `axes/`, `templates/`, etc.) explicitly stated in the body (when to read, what to read)?
     - If there are subcommands, are the routing conditions precise at the string-match / regex level? (Vague expressions like "in case of X" should be avoided)
   - **Note:** This is a static audit (text-level check, no dispatch). Dynamic verification (dispatch decision / behavioral deviation) is handled by [critical] items 4 and 5 of the skill evaluation mode checklist in Step 1. Together, both static and dynamic catch both "textually aligned but subagent still uncertain" and "textually divergent but subagent compensates correctly"

1. **Baseline preparation**: Confirm the target prompt, then prepare:
   - **Evaluation scenarios**: 2–3 variants (1 median + 1–2 edges). Use realistic tasks that represent actual usage of the target prompt.
   - **Requirements checklist** (for accuracy calculation): list 3–7 requirements the output must satisfy per scenario. Accuracy % = satisfied items / total items. Fix the checklist upfront — do not change it mid-run.

   **Skill evaluation mode variant:**

   Scenario types (3 recommended):
   - **Median scenario**: a standard utterance that clearly matches the description
   - **Boundary scenario (positive)**: matches, but with indirect or synonymous phrasing (tests trigger recall)
   - **Boundary scenario (negative)**: adjacent but outside the description's scope (tests misfire resistance)

   Skill evaluation mode checklist (5 items, **3 marked [critical]**. Items 1–3 are the minimum bar = proof the skill is not broken; 4–5 are quality items with partial acceptance. All items are quantified at the judgment-statement level):

   1. [critical] **Trigger accuracy**: If the subagent decides "use this skill" for **both** the median and boundary-positive scenarios, mark ○. If it decides "do not use" for either, mark ×
   2. [critical] **Misfire resistance**: If the subagent decides "do not use this skill" for the boundary-negative scenario, mark ○. If it decides "use", mark ×
   3. [critical] **Self-containedness**: **Compare only among scenarios where `dispatch decision = use`** (i.e., median + boundary-positive; exclude boundary-negative since it is not executed). If `tool_uses` for each scenario stays within **3× the median scenario**, mark ○ (consistent with the threshold "3–5× or more → low self-containedness signal" in the `tool_uses` section below)
   4. **Frontmatter alignment**: Extract the trigger vocabulary (3–5 nouns) from the first sentence of the description. If **0–1 of them are not defined or mentioned in the body**, mark ○; if 2 or more are missing, mark × (dynamic verification of the static audit in Step 0)
   5. **Subfile reference discipline**: If the subagent's file read count at the `references/` locations indicated in the body is **within the expected range**, mark ○; if it goes beyond the indicated scope, mark ×

   **Static + dynamic dual coverage:** Step 0 is a static audit (text alignment, no dispatch). [critical] item 4 is dynamic verification (does vocabulary divergence appear in subagent dispatch decisions or execution behavior?). Together they catch both types of divergence.

2. **Bias-free reading**: Have the instruction read by an "blank slate" executor. **Dispatch a new subagent via the Task tool.** Do not self-re-read (objectively re-reading something just written is structurally impossible). When running multiple scenarios in parallel, place multiple Agent calls in a single message. See "Environment constraints" for dispatch-unavailable environments.

3. **Execution**: Pass a prompt following the **subagent launch contract** below to the subagent, which runs the scenario, produces an output, and returns a self-report at the end.

4. **Dual-side evaluation**: From the returned result, record:
   - **Executor self-report** (extracted from subagent's report body): unclear points / discretionary fills / template application sticking points
   - **Caller-side measurement** (judgment rules defined here — other sections reference this section):
     - Pass/fail: passes only when **all `[critical]`-tagged requirements are ○**. Any single × or partial → fail. Label is ○ / × only (2-value).
     - Accuracy (% of requirements checklist satisfied. ○ = full marks, × = 0, partial = 0.5, divided by total items)
     - Step count (`tool_uses` from Task tool usage metadata, including Read / Grep — do not exclude)
     - Duration (`duration_ms` from Task tool usage metadata)
     - Retry count (how many times the subagent redid the same decision, extracted from the self-report — cannot be measured on the caller side)
     - **On failure, add 1 line to the "unclear points" field in the presentation format: which [critical] item failed** (for root-cause tracing)
   - The requirements checklist must include **at least 1 [critical]-tagged item** (0 items makes the pass judgment vacuous). Do not add or remove [critical] tags after the fact.

5. **Apply diff**: Apply the minimum fix to address the unclear points. One theme per iteration (related fixes in one batch is fine; unrelated fixes go in the next iteration).
   - **Before applying, state explicitly which requirements checklist item / judgment statement this fix satisfies.** Fixes inferred from axis names alone often fail to reach the judgment text. (See "Fix propagation patterns" below.)

6. **Re-evaluate**: Run steps 2–5 with a new subagent (do not reuse the previous one — it has learned from the prior improvement).  Increase parallelism if improvement has not plateaued after multiple iterations.

7. **Convergence judgment**: Stop when, for 2 consecutive iterations, **all** of the following hold:
   - New unclear points: 0
   - Accuracy improvement from previous: ≤ 3 percentage points (saturation)
   - Step count change from previous: ±10% or less
   - Duration change from previous: ±15% or less
   - **Over-fit check**: At convergence, add 1 hold-out scenario not used before and evaluate. If accuracy drops ≥ 15 points from the recent average, the model is over-fit — return to baseline scenario design and add more edges
   - **Additional condition for skill evaluation mode only**: boundary-negative scenario produces "do not use" decision ([critical] item 2 is ○) for **2 consecutive iterations**. Including precision (do not use when you shouldn't) alongside recall (use when you should) prevents false convergence caused by trigger bias

## Evaluation Axes

| Axis | How measured | Meaning |
|---|---|---|
| Pass/fail | Did the executor produce the intended output? (binary) | Minimum bar |
| Accuracy | What % of requirements did the output satisfy? | Degree of partial success |
| Step count | Tool calls / decision steps the executor used | Indicator of instruction overhead |
| Duration | Executor's `duration_ms` | Proxy for cognitive load |
| Retry count | How many times the executor redid the same decision | Signal of instruction ambiguity |
| Unclear points (self-report) | Bullet list from the executor | Qualitative improvement material |
| Discretionary fills (self-report) | Decisions not specified in the instruction | Surfaces implicit specs |

**Weighting:** Qualitative (unclear points, discretionary fills) is primary; quantitative (time, step count) is supplementary. Chasing only time reduction causes the prompt to become too sparse.

### Qualitative Interpretation of `tool_uses`

Accuracy alone can hide skill problems. Using `tool_uses` as a **relative value across scenarios** reveals structural flaws:

- If one scenario is **3–5× or more** compared to others, that skill is **decision-tree indexed with low self-containedness** — the executor is forced to descend through references
- Typical example: all scenarios have `tool_uses` of 1–3, but one has 15+ → no recipe for that scenario exists in the skill, and the executor cross-searches `references/`
- Fix: in iteration 2, add a "minimum complete example inline" or "when to read references" guideline near the top of SKILL.md — `tool_uses` drops significantly

Even at 100% accuracy, imbalanced `tool_uses` justifies starting iteration 2. "Only checking accuracy and stopping" tends to miss structural flaws.

### Fix Propagation Patterns (Conservative / Upside / Zero)

Fix → effect is not linear. Three patterns can occur:

- **Conservative** (estimate > actual): 1 fix targeted multiple axes but only moved 1. "Multi-axis targeting tends to miss"
- **Upside** (estimate < actual): 1 structural piece of information (e.g., command + config + expected output together) simultaneously satisfied multiple judgment statements. "Information combinations can structurally cover multiple axes"
- **Zero** (estimate > 0, actual = 0): A fix inferred from the axis name failed to reach any judgment statement. "Axis names and judgment statements are different things"

To stabilize this: **before applying a fix, have the subagent state which judgment statement the fix satisfies**. Linking at the threshold-statement level is required to get reliable estimates. When introducing a new evaluation axis, specify each point's judgment criteria at the threshold-statement level (e.g., "all fields explicit", "full text of minimum working example") so the subagent can determine the score.

## Subagent Launch Contract

The prompt passed to the executor takes this structure — this is the input contract for "dual-side evaluation":

```
You are an executor reading <target prompt name> with a blank slate.

## Target Prompt
<paste the full text of the target prompt, or specify the path for the executor to Read>

## Scenario
<1-paragraph situation description>

## Requirements checklist (what the output must satisfy)
1. [critical] <minimum-bar item>
2. <standard item>
3. <standard item>
...
(Judgment rules are defined centrally in "Workflow step 4". [critical] requires at least 1.)

## Task
1. Follow the target prompt to execute the scenario and produce an output.
2. At the end, return your response in the report structure below.

## Report structure
- Output: <produced artifact or execution result summary>
- Requirements met: for each item, ○ / × / partial (with reason)
- Unclear points: parts of the target prompt where you got stuck, phrasing you had to interpret (bullet list)
- Discretionary fills: decisions not specified in the instruction that you filled in yourself (bullet list)
- Retries: how many times you redid the same decision and why
```

The caller extracts the self-report portion and fills the evaluation axis table using `tool_uses` / `duration_ms` from the Agent tool's usage metadata.

### Skill Evaluation Mode Variant

In skill evaluation mode, the target is a "skill (SKILL.md + subfiles)" rather than an "instruction text." Replace the contract with this structure:

```
You are an executor reading <target skill name> with a blank slate.

## Target skill
<directory path resolved from skill name: `~/.claude/skills/<name>/`. Have the executor Read SKILL.md and subfiles>

## Scenario
<1-paragraph situation description in natural user utterance form>

## Requirements checklist (judgment rules defined centrally in "Workflow step 4")
1. [critical] Trigger accuracy: ...
2. [critical] Misfire resistance: ...
3. [critical] Self-containedness: ...
4. Frontmatter alignment: ...
5. Subfile reference discipline: ...
(Paste the full 5-item checklist from Workflow Step 1's skill evaluation mode variant)

## Task
1. **Decide first**: determine whether to invoke <target skill name> for this scenario. Return your reasoning in 1 line
2. Only if you decide "use": follow the skill's instructions to execute the scenario
3. At the end, return your response in the report structure below

## Report structure
- Dispatch decision: use / do not use + 1-line reason (★ new field added to the base format)
- Output: <produced artifact (only if "use") or "not dispatched">
- Requirements met: for each item, ○ / × / partial (with reason)
- Unclear points: parts of the skill where you got stuck, phrasing you had to interpret (bullet list)
- Discretionary fills: decisions not specified in the instruction that you filled in yourself (bullet list)
- Retries: how many times you redid the same decision and why
```

The caller uses the `dispatch decision` field as input for [critical] items 1 / 2, and compares `tool_uses` **only among scenarios where `dispatch decision = use`** to evaluate [critical] item 3 (boundary-negative is excluded since it is not executed).

## Environment Constraints

In environments where dispatching a new subagent is not possible (already running as a subagent, Task tool is disabled, etc.), this skill **does not apply**.

- Alternative 1: Ask the user to start a separate Claude Code session and run the evaluation there
- Alternative 2: Skip empirical evaluation and report "empirical evaluation skipped: dispatch unavailable" to the user
- **Prohibited:** substituting with self-re-reading (results are not trustworthy — bias is introduced)

**Structure-audit mode:** If the goal is only to check **textual consistency and clarity** of a skill / prompt without empirical evaluation, explicitly label it as structure-audit mode. Include "This run is structure-audit mode: text consistency check only, not execution" in the subagent's prompt. This prevents the environment-constraint skip behavior from triggering and lets the subagent return a static review. Structure audit is a supplement to empirical evaluation, not a substitute (it cannot count toward consecutive convergence).

## Termination Criteria

- **Convergence (stop):** 2 consecutive iterations where **all** of the following hold:
  - New unclear points: 0
  - Accuracy improvement from previous: ≤ 3 percentage points (saturation like 5% → 8%)
  - Step count change from previous: ±10% or less
  - Duration change from previous: ±15% or less
  - **Over-fit check:** At convergence, add 1 previously unused hold-out scenario. If accuracy drops ≥ 15 points from the recent average, the model is over-fit — return to baseline scenario design and add more edge cases
  - **Skill evaluation mode only:** boundary-negative scenario produces "do not use" ([critical] item 2 is ○) for **2 consecutive iterations**. This prevents false convergence from trigger bias by requiring both recall ([critical] 1) and precision ([critical] 2) to converge
- **Divergence (question the design):** If new unclear points do not decrease after 3+ iterations → the prompt's structural design itself may be wrong. Stop patching and rewrite from scratch
- **Resource cutoff:** Stop when the importance/improvement-cost ratio no longer makes sense (shipping at 80 points is a valid call)

## Presentation Format

Record and present to the user in the following format for each iteration:

```
## Iteration N

### Changes (diff from previous)
- <1-line description of the fix>

### Execution results (per scenario)
| Scenario | Pass/fail | Accuracy | steps | duration | retries |
|---|---|---|---|---|---|
| A | ○ | 90% | 4 | 20s | 0 |
| B | × | 60% | 9 | 41s | 2 |

### Unclear points (new this iteration)
- <Scenario B>: [critical] item N is × — <1-line reason for failure>   # always include on failure
- <Scenario B>: <other new finding>
- <Scenario A>: (none new)

### Discretionary fills (new this iteration)
- <Scenario B>: <fill content>

### Next fix
- <1-line minimum fix>

### Convergence judgment (this iteration)
| Condition | Previous → Current | Judgment |
|---|---|---|
| New unclear points: 0 | 2 → 0 | ✓ |
| Accuracy improvement ≤ 3pt | 70% → 75% (+5pt) | ✗ |
| Step count change ≤ ±10% | 6.5 → 6.5 (0%) | ✓ |
| Duration change ≤ ±15% | 30s → 30.5s (+2%) | ✓ |
| Boundary-negative [critical] 2 ○ (2 consecutive) ※ skill eval mode only | ✓ → ✓ | ✓ |

(Convergence: X consecutive / Y more iterations until stop condition)
(※ Include last row only in skill evaluation mode; omit in prompt evaluation mode)
```

## Red Flags

| Rationalization | Reality |
|---|---|
| "Re-reading myself has the same effect" | You cannot objectively re-read something you just wrote. Always dispatch a new subagent. |
| "1 scenario is enough" | 1 scenario over-fits. Minimum 2, ideally 3. |
| "Unclear points were 0 once, so we're done" | May be coincidence. Require 2 consecutive for a confirmed judgment. |
| "Let's fix all unclear points at once" | You won't know what worked. 1 theme per iteration. |
| "Related micro-fixes should each be a separate iteration" | The opposite trap. "1 theme" is a semantic unit. 2–3 related micro-fixes in 1 iteration is fine — over-splitting causes iteration count to explode. |
| "Metrics look good so ignore qualitative feedback" | Time reduction can also be a sign of over-thinning. Qualitative is primary. |
| "Rewriting from scratch is faster" | Correct after 3+ iterations with no decrease in unclear points. At earlier stages, it's avoidance. |
| "Reuse the same subagent" | It has learned from the prior improvement. Dispatch a new one every time. |

## Common Failures

- **Scenario too easy / too hard**: either produces no signal. Use 1 median real-world case + 1 edge
- **Only watching metrics**: chasing time alone strips out important instructions, making the prompt brittle
- **Too many changes per iteration**: "which of those changes worked?" becomes unanswerable. 1 fix per iteration
- **Tuning the scenario to match the fix**: makes unclear points seem resolved by simplifying the scenario — defeats the purpose

## Related

### Distinction from `skill-creator` (plugin)

| Situation | Right tool |
|---|---|
| Qualitative detection of ambiguity / contradictions / iterative improvement of instruction text | **dry-run-prompt** (this skill) |
| Objective scoring with assertions, pass_rate / token / duration variance analysis, blind A/B comparison of 2 versions, bulk trigger evaluation from description | **skill-creator** (plugin) |
| Unclear points not decreasing after 3 consecutive iterations with dry-run-prompt | Switch to structural rewrite or skill-creator's blind comparison |

**Flow integration:** After unclear points converge with dry-run-prompt, use skill-creator's evaluation pipeline to verify reproducibility and variance. The natural order is: "eliminate instruction ambiguity" with dry-run-prompt → "confirm with objective metrics via A/B" with skill-creator.
