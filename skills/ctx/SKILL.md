---
name: ctx
description: |
  Extract common contexts from qualitative data (interviews, feedback, behavior logs) using 5W1H structured description.
  Use when the user provides raw qualitative data and wants to discover shared situational patterns across cases.
  Framework-agnostic: output can feed into JTBD, persona analysis, customer journey mapping, or other analytical frameworks.
  Do not use when the user wants to analyze demand forces (Push/Pull/Anxiety/Habit) — use dex instead.
  Do not use when the user already has structured contexts and wants to interpret Why / So what.
  Subcommands: setup, extract, organize. No args = progress check.
user-invocable: true
---

# Ctx — Context Extraction

Extract common contexts from raw qualitative data by structuring facts into 5W1H dimensions and finding cross-case patterns.

## Prerequisites

- Qualitative data (interview logs, behavior data, feedback) is accessible
- This skill produces structured descriptions only — Why / So what interpretation is the human's job

## Argument Routing

| Args        | Action                                                                                                                       |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------- |
| (none)      | Progress check: detect report → show filled/unfilled placeholders → suggest next subcommand                                  |
| `setup`     | Define research starting point (focus, cases, frame awareness) → create report files. → [setup-workflow.md](references/setup-workflow.md) |
| `extract`   | Extract facts and organize chronologically. → [extract-workflow.md](references/extract-workflow.md)                           |
| `organize`  | Structure facts into 5W1H contexts (per-case) → cross-case comparison → common context extraction. → [organize-workflow.md](references/organize-workflow.md) |

Read the linked workflow file and follow its instructions.

## Report Discovery

When any subcommand other than `setup` is invoked, locate the active report:

1. Search: `ls ~/.agent-memory/*/ctx-report.md`
2. If exactly one report found → use it. The appendix file (`ctx-appendix.md`) is always in the same directory
3. If multiple found → list each report's title line (`# Ctx: ...`) and whether it has unfilled placeholders (in-progress). Prioritize in-progress reports. Ask the user to choose
4. If none found → tell the user to run `/ctx setup` first

When passing file paths to subagents, always pass both the main report path and the appendix path.

## Prerequisite Check

On subcommand start, verify that the prerequisite placeholders are all replaced (no `{{` remaining for those placeholders). If unmet, inform the user which prior subcommand to run.

| Subcommand | Prerequisite placeholders that must be filled                                                                   | Check file |
| ---------- | --------------------------------------------------------------------------------------------------------------- | ---------- |
| `setup`    | (none)                                                                                                          | —          |
| `extract`  | `{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`, `{{FRAME_AWARENESS}}` | 本体       |
| `organize` | `{{FACT_TABLES}}`, `{{BACKGROUND_EVENTS}}`                                                                      | 付録       |

## Progress Check (default)

When invoked with no arguments:

1. Run Report Discovery
2. If no report found → display: "分析がまだ開始されていません。`/ctx setup` で開始してください"
3. If report found → run `grep '{{' <report-path> <appendix-path>` to find unfilled placeholders across both files
4. Map unfilled placeholders to subcommands and display progress:

```
## 進捗: <レポートタイトル>

✅ setup — セットアップ
✅ extract — ファクト抽出・時系列整理
⬜ organize — 構造化・共通コンテキスト抽出

→ 次のステップ: `/ctx organize`
```

Next-step suggestion logic:

- setup incomplete → `setup`
- extract incomplete → `extract`
- organize incomplete → `organize`

Placeholder → subcommand mapping:

| Placeholder pattern                                                                                             | Subcommand | File |
| --------------------------------------------------------------------------------------------------------------- | ---------- | ---- |
| `{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`, `{{FRAME_AWARENESS}}` | setup      | 本体 |
| `{{FACT_TABLES}}`, `{{BACKGROUND_EVENTS}}`                                                                      | extract    | 付録 |
| `{{CONTEXT_DESCRIPTIONS}}`                                                                                      | organize   | 付録 |
| `{{COMMON_CONTEXTS}}`                                                                                           | organize   | 本体 |

## Data Flow

The `setup` subcommand creates two files from the report template ([report-template.md](references/report-template.md)):

- **ctx-report.md** (main report): Analysis results — common contexts
- **ctx-appendix.md** (appendix): Raw data — fact tables, chronological organization, per-case context descriptions

Each subsequent subcommand replaces its placeholders (`{{XXX}}`) in the appropriate file after user confirmation. When all subcommands complete, the two files together form the finished deliverable.

- **Read from appendix, write to both**: `organize` reads fact data from the appendix, writes per-case descriptions to the appendix (`{{CONTEXT_DESCRIPTIONS}}`), and writes cross-case common contexts to the main report (`{{COMMON_CONTEXTS}}`).
- **Replace after confirm**: Each subcommand's output replaces its placeholder(s) after user approval at the confirmation gate. Content is wrapped in HTML comment boundary markers (`<!-- BEGIN XXX -->...<!-- END XXX -->`) for re-replacement if the user requests revisions.
- **Atomic replacement**: When a subcommand has multiple placeholders, all are replaced together after the confirmation gate. No partial replacement state.
- **Re-replacement**: If the user requests a revision after confirmation, locate the content between `<!-- BEGIN XXX -->` and `<!-- END XXX -->` markers and replace it with the revised content.
- **Temporary files**: `organize` uses temporary files for intermediate subagent outputs. These are deleted after the confirmation gate.
  - Scaffolded route (11+ cases): `_describe_tmp.md` (Phase A per-case outputs) + `_compare_tmp.md` (Phase B cross-case output)
  - Direct route (2–10 cases): `_compare_tmp.md` only (Phase B output contains both per-case groupings and cross-case comparison)

### Section Dependency Map

Cross-section dependencies. Consult this when manually editing or re-running subcommands to identify downstream impact.

| Changed section        | Affected downstream sections          |
| ---------------------- | ------------------------------------- |
| FACT_TABLES            | BACKGROUND_EVENTS, organize           |
| BACKGROUND_EVENTS      | organize                              |
| CONTEXT_DESCRIPTIONS   | COMMON_CONTEXTS (both generated simultaneously in Direct route) |
| COMMON_CONTEXTS        | No downstream                         |

### Re-run for Case Addition

To add cases to an existing analysis, re-run subcommands in this order:

1. `extract`: Append new case's fact table and Background/Events
2. `organize`: Re-determine route based on updated case count. If route changes (e.g., 9→11 cases crosses threshold), re-run from the new route's starting point.
   - Direct route: Re-run Phase B with all cases
   - Scaffolded route: Run Phase A for new case only → Re-run Phase B with all cases (re-replacement)

### Post-hoc Correction

When a missed pattern or error is discovered after a confirmation gate:

**Small correction (no CC-* ID additions/deletions/renames)**:

- Edit the affected section directly (re-replace)
- Consult the dependency map above and verify consistency in **only the downstream sections that reference the changed content**

**Large correction (CC-* IDs added/deleted/renamed)**:

- Re-run the affected subcommand (re-replacement) rather than manual patching
- Manual patching across multiple sections with ID changes is error-prone

### Re-replacement Consistency Rule

- ALWAYS: After any re-replacement or manual edit, consult the dependency map and verify consistency in **only the downstream sections that reference the modified content**
- Verification items: (a) any CC-* added or changed in the edit exists and is correctly referenced downstream, (b) quantitative phrases like "N社に共通する" match the actual case count
- If inconsistencies are found, re-replace the downstream sections as well

Report paths: `~/.agent-memory/<scope>/<date>_<topic>/ctx-report.md` and `ctx-appendix.md`

## Output Language Rules

- All user-facing output (table headers, section titles, labels) must be written in Japanese
- 5W1H axis labels (What, When, Where, Who, How) may be used in English as column headers for readability
- English terminology may be used as-is in subagent prompts for analysis accuracy
- Established loanwords whose original meaning would be lost in Japanese translation (e.g., コンテキスト) should remain as-is

## Strict Rules

- Do not write Why or So what — this skill extracts observable contexts only. Causal interpretation is the human's job
- Do not propose or suggest solutions
- Do not skip from facts to context organization without data
- Do not proceed past a confirmation gate (→) without user approval
- Do not treat customer opinions or stated preferences as behavioral facts
- Do not score, rank, or prioritize
- NEVER ask the user to verify completeness — always perform self-review against the source material before presenting results at any confirmation gate
- RQ is the starting point for analysis, not a filter. Fact extraction is RQ-independent — every observable behavior and verbatim quote must be recorded regardless of apparent relevance to the RQ
- Inference permissions:
  - extract: No inference. Observable behavior and verbatim quotes only.
  - organize per-case grouping (Phase A in Scaffolded route / Step 0 in Direct route): No inference. Observable behavior, verbatim quotes, and observable attitudes (backed by verbatim quotes) only.
  - organize cross-case comparison (Phase B Step 1–3): Abstraction permitted (grouping concrete instances under a common label). Causal interpretation is NOT permitted.
- Output written to the report or appendix (subagent output and integration results) must NOT contain file paths, plan references, or any external file references — the report must be a self-contained deliverable

## Completion

This skill is complete when all conditions are met:

- All subcommands' placeholders are filled in both the main report and appendix files
- The user has approved each confirmation gate
- The user confirms analysis is complete, or directs additional investigation
