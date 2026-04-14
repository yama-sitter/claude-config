# Synthesis Workflow

## Prerequisites

`{{COMMON_PATTERNS}}` is replaced in the main report file (i.e., `context` subcommand is complete).

## Owned Placeholders

`{{RQ_CONTRAST}}`, `{{PATTERN_CONNECTIONS}}`, `{{COMMON_NARRATIVE}}`

## Workflow

Integrate the patterns extracted by `context` into a coherent whole: contrast findings against initial assumptions, trace connections between phases, and synthesize a common narrative.

**Input from report**: Frame Awareness (from header), Phase Definitions, Common Patterns (Section 1).

**Inference permissions**:

- RQ contrast: Compare frame awareness assumptions against findings — factual comparison, not interpretation
- Pattern connections: "A was observed before B" — temporal connections, not causal claims
- Common narrative: Connect patterns and Purpose changes into readable prose — no interpretation of motives or dynamics

### Step 1: RQ Contrast

Compare the Frame Awareness notes (defined in `brief`) against the actual findings from Section 1.

Output format:

```
| 観点 | RQが前提としていたこと | データが示したこと | 差分 |
|---|---|---|---|
| [Frame Awareness の各項目] | [RQの暗黙の前提] | [実際の発見] | [支持 / 反証 / 想定外] |
```

For each Frame Awareness item:

- **支持**: The data confirms the RQ's assumption
- **反証**: The data contradicts the RQ's assumption
- **想定外**: The data reveals something the RQ did not anticipate at all

After the table, write a **発見のハイライト** paragraph (1 paragraph) summarizing the most significant gap(s) between assumptions and findings.

### Step 2: Pattern Connections

Trace how patterns in one phase connect to patterns in the next phase.

Output format (repeat for each phase transition):

```
#### P{n} → P{n+1} の接続

P{n}-S{x}（...）→ P{n+1}-S{y}（...）
- 観察: [何の後に何が起きたか — 時系列的な記述]
- 該当ケース: A, B, C, E
- 逸脱: [ケース固有の逸脱があれば。例: Case D は P{n}-S{x} を経ずに P{n+1} に移行]
```

Rules:

- Describe as **temporal connections** ("A was observed before B"), NOT causal claims ("A caused B")
- Use P\*-S\* / P\*-St\* identifiers to reference patterns
- **Purpose divergence points**: If Purpose entries diverge at a phase transition (cases split into different trajectories), highlight this connection explicitly
- **Case-specific deviations**: If a case skips a connection, follows a different path, or reverses the order, note this explicitly
- Connections must be traceable to specific Facts

### Step 3: Common Narrative

Write a prose summary of the common flow across all phases:

- Connect the patterns from Step 2 into readable prose
- Track Purpose changes across phases (how what people are trying to achieve evolves)
- Note case-specific deviations as inline annotations (e.g., "ただし Case D では...")
- Keep the narrative grounded in observable patterns — every claim must trace back to P\*-S\*/P\*-St\* identifiers

**Prohibited**:

- Do NOT speculate on motives ("they did X because they felt Y")
- Do NOT interpret dynamics ("the underlying force driving this was...")
- Do NOT propose solutions or recommendations
- Do NOT introduce new patterns not already in Section 1

The narrative synthesizes what was already extracted — it does not add new analysis.

## Confirmation Gate

Present all three sections (RQ Contrast table + Pattern Connections + Common Narrative) together for user review.

After approval, replace all three placeholders simultaneously in the main report:

1. `{{RQ_CONTRAST}}` ← Step 1 output
2. `{{PATTERN_CONNECTIONS}}` ← Step 2 output
3. `{{COMMON_NARRATIVE}}` ← Step 3 output

All three are replaced atomically — no partial replacement state.
