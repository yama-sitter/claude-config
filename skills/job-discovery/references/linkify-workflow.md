# Linkify Workflow

Post-process an existing report to add in-page anchor links to all identifier definition and reference sites.

## Prerequisites

A report file exists with at least `{{STEP1_FACT_TABLES}}` replaced. The more sections are filled, the more identifiers can be linked.

## Report Discovery

Use the same report discovery logic as other subcommands (see SKILL.md).

## Algorithm

Process the report in four sequential passes. Each pass operates on `<!-- BEGIN/END -->` sections for precise targeting.

### Pass 1: Build Identifier Inventory

Scan the report and collect all identifiers that exist:

1. **Fact identifiers**: Inside `<!-- BEGIN STEP1_FACT_TABLES -->` ... `<!-- END STEP1_FACT_TABLES -->`, extract the first column of each table row. Expect bare format (`A1`, `B7`) or prefixed format (`F-A1`). Record the canonical form (bare).
2. **P*-S* / P*-St* identifiers**: Inside `<!-- BEGIN STEP3_COMMON_PATTERNS -->` ... `<!-- END STEP3_COMMON_PATTERNS -->`, extract the first column matching `P\d+-S\d+` or `P\d+-St\d+`.
3. **CF-* identifiers**: Inside `<!-- BEGIN STEP4_CROSS_FORCES -->` ... `<!-- END STEP4_CROSS_FORCES -->`, extract the first column matching `CF-[A-Za-z]+\d+`.

The inventory is the set of known identifiers. Only these will be linked.

### Pass 2: Add Anchors at Definition Sites

For each identifier in the inventory, wrap its first-column occurrence with `<span id="ID">ID</span>`:

- Fact table: `| A1 |` → `| <span id="A1">A1</span> |`
- P*-S*/P*-St* table: `| P1-S1 |` → `| <span id="P1-S1">P1-S1</span> |`
- CF-* table: `| CF-Push1 |` → `| <span id="CF-Push1">CF-Push1</span> |`

**Idempotency**: If a cell already contains `<span id=`, skip it.

### Pass 3: Add Links at Reference Sites

**Processing granularity**: Process each identifier token individually within each cell/parenthesized group. Do NOT apply line-level regex — this causes the primary failure mode where mixed linked/unlinked identifiers in the same cell are skipped.

**Processing order** (longest patterns first to avoid partial matches): P*-St* → P*-S* → CF-* → Fact.

**Skip conditions** (check per-token, not per-line):
- Token is already in `[...](#...)` format → skip that token
- Token is inside a `<span id=...>` tag → skip that token
- Token is not in Pass 1 inventory → skip that token

#### P*-St*, P*-S*, CF-* references

These patterns are sufficiently unique. Replace every bare occurrence with `[ID](#ID)` across the entire report.

- `P2-St1` → `[P2-St1](#P2-St1)`
- `P1-S1` → `[P1-S1](#P1-S1)` (but NOT if part of an already-linked `P*-St*`)
- `CF-Push1` → `[CF-Push1](#CF-Push1)`

#### Fact references (short identifiers — extra care required)

Fact identifiers are short (`A1`, `B7`) and risk false matches. Only link in these contexts:

| Context | Example before | Example after |
|---|---|---|
| 出典/根拠 column cells | `A3-A5, B7` | `[A3](#A3)-[A5](#A5), [B7](#B7)` |
| 4社での現れ方 column — parenthesized citations | `時間コスト大([A3](#A3))` already linked, but `応募ゼロ(B7)` unlinked | `応募ゼロ([B7](#B7))` |
| Inline parenthesized citations in prose | `(A8)` | `([A8](#A8))` |
| Range references | `A3-A5` | `[A3](#A3)-[A5](#A5)` |

**Cell-by-cell procedure**:

1. For each target cell, scan left-to-right for inventory identifiers
2. For each found identifier, check if it is already wrapped in `[...](#...)` — if yes, skip; if no, wrap it
3. The presence of already-linked identifiers in the same cell must NOT cause unlinked identifiers to be skipped

**Example — mixed-state cell** (the #1 failure mode in practice):

Before: `[A3](#A3)-A5, B7, [C12](#C12)`
After:  `[A3](#A3)-[A5](#A5), [B7](#B7), [C12](#C12)`

A3 and C12 are already linked → skip. A5 and B7 are bare → link them.

### Pass 4: Self-Verification

Before presenting results, run these checks:

1. **Unlinked reference scan**: Search for bare inventory identifiers that appear outside `<span>` tags and `[...](#...)` links. Use grep patterns:
   - P*-S*/P*-St*: `grep -nP '(?<!\[)P\d+-S(t)?\d+(?![\w>])' FILE | grep -v 'span id'`
   - CF-*: `grep -nP '(?<!\[)CF-[A-Za-z]+\d+(?![\w>])' FILE | grep -v 'span id'`
   - Fact IDs: For each case letter in inventory, check table cells and parenthesized groups for bare references
2. **Broken link scan**: For every unique `[ID](#ID)` target, verify a matching `<span id="ID">` exists.

If unlinked references are found (count > 0), fix them and re-run the scan once. If issues persist after the fix pass, report the remaining count and locations to the user — do NOT silently skip them.

## Confirmation Gate

After processing, present the user with a summary:

- Number of anchors added (Pass 2)
- Number of links added (Pass 3)
- Any identifiers in the inventory that could not be linked (e.g., referenced but not defined)

Ask for confirmation before writing the updated report.

## Known Limitations

- Anchors inside collapsed `<details>` sections may not auto-expand on click in some Markdown renderers (GitHub, Notion). The links still work when sections are manually expanded.
- Bare Fact identifiers (`A1`) are short and may appear in non-identifier contexts. The context restriction (table cells, parentheses only) minimizes false matches, but manual review is recommended after linkification.
