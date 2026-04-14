# Phases Workflow

## Prerequisites

Header placeholders are all replaced in the main report file (`brief` completed).

This workflow reads Background/Events from the appendix file. If `{{BACKGROUND_EVENTS}}` is still a placeholder, inform the user to run `/ctx facts` first.

## Owned Placeholders

`{{PHASE_DEFINITIONS}}`

## Workflow

Define the analysis phases interactively with the user. Phases segment the timeline of each case into meaningful stages, enabling cross-case comparison within each stage.

**Input from appendix**: Background/Events for all cases. Read from the appendix file.
**Input from report**: Frame Awareness (for bias awareness during clustering).

### Step 1: State-transition-based Clustering (LLM proposes)

Read Background/Events for all cases from the appendix file.

1. **Extract state-transition events**: For each case, identify points where an observable state changes to a different state. A state transition is a shift in conditions, behavior, or circumstances — NOT an internal feeling or intention.
   - Good: "Started using service X" (observable behavior change)
   - Good: "Shifted from ad-hoc hiring to planned staffing" (observable operational change)
   - Bad: "Felt dissatisfied" (internal state, not observable)
   - Bad: "Decided to try something new" (intention, not observable)

2. **Cross-case alignment**: Map similar state transitions across cases. Identify clusters where the majority of cases (more than half) share a similar type of transition.

3. **Propose phase candidates**: For each cluster with sufficient cross-case support, propose a phase candidate.

**Proposal format** — present each candidate as:

```
### フェーズ候補 P{n}: {仮名称}

- **開始条件**: [観察可能な状態遷移 — 第三者が確認できるレベルで記述]
- **このフェーズで解決される問い**: [このフェーズの行動を理解するための核心の問い]
- **各ケースの該当イベント**:
  - Case A: [F-XX — 具体的な出来事]
  - Case B: [F-XX — 具体的な出来事]
  - Case C: [F-XX — 具体的な出来事]
- **境界が曖昧なケース**: [あれば。どのケースで、なぜ曖昧か]
```

Rules for proposal:

- Each phase's start condition must be described as an observable state that a third party could verify
- Do NOT include emotions, intentions, or interpretations in phase definitions
- Phases should represent qualitatively different stages, not just temporal divisions
- If a case does not fit a proposed phase (skips it, or has a unique path), note this explicitly

### Step 2: User Dialogue

Present the phase candidates and engage the user in refining them:

- **Split**: Should a proposed phase be divided into two distinct stages?
- **Merge**: Should two proposed phases be combined because they represent the same stage?
- **Rename**: Does the phase name accurately capture what's happening?
- **Boundary adjustment**: Where exactly does one phase end and another begin?
- **Independence check**: "Is this phase truly a distinct stage, or a sub-stage of another?"
- **Case-specific deviations**: How to handle cases that skip a phase or follow a different order

Continue the dialogue until the user is satisfied with the phase definitions.

### Step 3: Confirmation Gate

**Design constraints** (enforce before presenting for confirmation):

- **Maximum 6 phases**: If more than 6 are proposed, discuss with the user which to merge
- **Observable start conditions**: Every start condition must pass the test: "Could a third party verify this condition occurred?"
- **No emotions/intentions/interpretations**: Phase definitions describe what happened, not why

Present the confirmed phase definitions in table format:

```
| Phase | 名称 | 開始条件 | 核心の問い |
|---|---|---|---|
| P1 | ... | ... | ... |
| P2 | ... | ... | ... |
| P3 | ... | ... | ... |
```

After user approval, replace `{{PHASE_DEFINITIONS}}` in the main report file with the phase definition table.

## Single-case Behavior

When only one case exists, propose phases based on that single case's state transitions. Note that phase definitions may be revised when additional cases are added. The user can run `/ctx phases` again after adding cases to re-evaluate.

## Re-evaluation

When phases are re-evaluated (e.g., after adding cases):

1. Read the existing phase definitions from the main report
2. Read Background/Events for all cases (including new ones)
3. Assess whether existing phases still hold with the new data
4. Propose adjustments if needed (new phases, merged phases, boundary shifts)
5. Present as a diff against the current definitions
6. After approval, re-replace `{{PHASE_DEFINITIONS}}` in the main report
