# Linkify Workflow

Post-process an existing report to add in-page anchor links to all identifier definition and reference sites.

## Prerequisites

A report file exists with at least `{{STEP1_FACT_TABLES}}` replaced. The more sections are filled, the more identifiers can be linked.

## Report Discovery

Use the same report discovery logic as other subcommands (see SKILL.md).

## Algorithm

Process the report in three sequential passes. Each pass operates on `<!-- BEGIN/END -->` sections for precise targeting.

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

Process sections in this order to avoid partial matches: P*-St* → P*-S* → CF-* → Fact.

For each section of the report (outside definition sites from Pass 2):

**P*-St* references**: Replace `P\d+-St\d+` with `[P1-St1](#P1-St1)` (only if in inventory).

**P*-S* references**: Replace `P\d+-S\d+` with `[P1-S1](#P1-S1)` (only if in inventory, and not already part of a P*-St* that was just linked).

**CF-* references**: Replace `CF-[A-Za-z]+\d+` with `[CF-Push1](#CF-Push1)` (only if in inventory).

**Fact references** (most care needed due to short identifiers): Only link in these contexts:

- **Comma-separated lists in table cells**: `A3-A5, B7, C12` → `[A3](#A3)-[A5](#A5), [B7](#B7), [C12](#C12)`
- **Parenthesized citations**: `(A8)` → `([A8](#A8))`, `(A2-A5)` → `([A2](#A2)-[A5](#A5))`
- **Range references**: `A3-A5` → `[A3](#A3)-[A5](#A5)` (link start and end)
- Only match identifiers that exist in the Pass 1 inventory

**Idempotency**: If text is already in `[...](#...)` format, skip it. If text is inside a `<span id=...>` tag, skip it.

## Confirmation Gate

After processing, present the user with a summary:

- Number of anchors added (Pass 2)
- Number of links added (Pass 3)
- Any identifiers in the inventory that could not be linked (e.g., referenced but not defined)

Ask for confirmation before writing the updated report.

## Known Limitations

- Anchors inside collapsed `<details>` sections may not auto-expand on click in some Markdown renderers (GitHub, Notion). The links still work when sections are manually expanded.
- Bare Fact identifiers (`A1`) are short and may appear in non-identifier contexts. The context restriction (table cells, parentheses only) minimizes false matches, but manual review is recommended after linkification.
