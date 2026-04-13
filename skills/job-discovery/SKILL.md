---
name: job-discovery
description: |
  Discover Jobs-to-be-Done from customer behavior facts, interview logs, or feedback data.
  Use when the user provides raw customer data and wants to discover the underlying demand structure.
  Do not use when the user already has a clear hypothesis and wants to design experiments.
  Do not use when the user wants to brainstorm or evaluate solutions.
  Subcommands: brief, facts, situations, forces. No args = progress check.
user-invocable: true
---

# Job Discovery

Discover Jobs-to-be-Done from raw customer data by climbing the Ladder of Inference one rung at a time.

## Prerequisites

- Customer interview logs, behavior data, or feedback are accessible
- This skill produces demand-side analysis only — output feeds into experiment design

## Argument Routing

| Args         | Action                                                                                                                                          |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| (none)       | Progress check: detect report → show filled/unfilled placeholders → suggest next subcommand                                                     |
| `brief`      | Define research starting point (focus, cases, frame awareness) → create report files. → [brief-workflow.md](references/brief-workflow.md)       |
| `facts`      | Extract facts and organize chronologically. → [facts-workflow.md](references/facts-workflow.md)                                                 |
| `situations` | Extract common situations across cases (Narrator → Analyst-Critic → Integration). → [situations-workflow.md](references/situations-workflow.md) |
| `forces`     | Analyze demand forces (Push/Pull/Anxiety/Habit). Order with situations is flexible. → [forces-workflow.md](references/forces-workflow.md)       |

Read the linked workflow file and follow its instructions.

## Report Discovery

When any subcommand other than `brief` is invoked, locate the active report:

1. Search: `ls ~/.agent-memory/*/job-discovery-report.md`
2. If exactly one report found → use it. The appendix file (`job-discovery-appendix.md`) is always in the same directory
3. If multiple found → list each report's title line (`# Job Discovery: ...`) and whether it has unfilled placeholders (in-progress). Prioritize in-progress reports. Ask the user to choose
4. If none found → tell the user to run `/job-discovery brief` first

When passing file paths to subagents, always pass both the main report path and the appendix path.

## Prerequisite Check

On subcommand start, verify that the prerequisite placeholders are all replaced (no `{{` remaining for those placeholders). If unmet, inform the user which prior subcommand to run.

| Subcommand   | Prerequisite placeholders that must be filled                                                                   | Check file |
| ------------ | --------------------------------------------------------------------------------------------------------------- | ---------- |
| `brief`      | (none)                                                                                                          | —          |
| `facts`      | `{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`, `{{FRAME_AWARENESS}}` | 本体       |
| `situations` | `{{FACT_TABLES}}`, `{{BACKGROUND_EVENTS}}`                                                                      | 付録       |
| `forces`     | `{{FACT_TABLES}}`, `{{BACKGROUND_EVENTS}}`                                                                      | 付録       |

Note: `situations` and `forces` share the same prerequisites and can run in either order or in parallel.

## Progress Check (default)

When invoked with no arguments:

1. Run Report Discovery
2. If no report found → display: "分析がまだ開始されていません。`/job-discovery brief` で開始してください"
3. If report found → run `grep '{{' <report-path> <appendix-path>` to find unfilled placeholders across both files
4. Map unfilled placeholders to subcommands and display progress:

```
## 進捗: <レポートタイトル>

✅ brief — リサーチブリーフ
✅ facts — 事実抽出・整理
⬜ situations — 共通状況抽出
⬜ forces — 力学分析

→ 次のステップ: `/job-discovery situations` または `/job-discovery forces`
```

Next-step suggestion logic:

- brief incomplete → `brief`
- facts incomplete → `facts`
- both situations and forces incomplete → suggest both (user chooses order)
- one of situations/forces incomplete → suggest the incomplete one

Placeholder → subcommand mapping:

| Placeholder pattern                                                                                             | Subcommand | File      |
| --------------------------------------------------------------------------------------------------------------- | ---------- | --------- |
| `{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`, `{{FRAME_AWARENESS}}` | brief      | 本体      |
| `{{FACT_TABLES}}`, `{{BACKGROUND_EVENTS}}`                                                                      | facts      | 付録      |
| `{{COMMON_SITUATIONS_HIRE}}`, `{{COMMON_SITUATIONS_REHIRE}}`                                                    | situations | 本体      |
| `{{PERCASE_FORCES}}`, `{{CROSS_FORCES_HIRE}}`, `{{CROSS_FORCES_REHIRE}}`                                        | forces     | 本体+付録 |

## Data Flow

The `brief` subcommand creates two files from the report template ([report-template.md](references/report-template.md)):

- **job-discovery-report.md** (main report): Analysis results — common situations and common forces
- **job-discovery-appendix.md** (appendix): Raw data — fact tables, case stories, per-case forces

Each subsequent subcommand replaces its placeholders (`{{XXX}}`) in the appropriate file after user confirmation. When all subcommands complete, the two files together form the finished deliverable.

- **Read from appendix, write to main report**: `situations` and `forces` read fact data from the appendix, then write their cross-case analysis results to the main report. `forces` also writes per-case analysis to the appendix.
- **Replace after confirm**: Each subcommand's output replaces its placeholder(s) after user approval at the confirmation gate. Content is wrapped in HTML comment boundary markers (`<!-- BEGIN XXX -->...<!-- END XXX -->`) for re-replacement if the user requests revisions.
- **Atomic replacement**: When a subcommand has multiple placeholders, all are replaced together after the confirmation gate. No partial replacement state.
- **Re-replacement**: If the user requests a revision after confirmation, locate the content between `<!-- BEGIN XXX -->` and `<!-- END XXX -->` markers and replace it with the revised content.
- **Temporary files**: `situations` uses temporary files (`_narrator_tmp.md`, `_analyst_tmp.md`) for intermediate subagent outputs. These are deleted after the confirmation gate.

### Section Dependency Map

Cross-section dependencies. Consult this when manually editing or re-running subcommands to identify downstream impact.

| Changed section      | Affected downstream sections                     |
| -------------------- | ------------------------------------------------ |
| FACT_TABLES          | BACKGROUND_EVENTS, situations, forces            |
| BACKGROUND_EVENTS    | situations, forces                               |
| COMMON*SITUATIONS*\* | CROSS*FORCES*\* (forces 4b references Section 1) |
| CROSS*FORCES*\*      | No downstream                                    |

### Re-run for Case Addition

To add cases to an existing analysis, re-run subcommands in this order:

1. `facts`: Append new case's fact table and Background/Events
2. `situations`: Run Narrator for new case only (append to temporary file) → Re-run Analyst-Critic and Integration with all cases (re-replacement)
3. `forces`: Run per-case forces (4a) for new case only (append) → Re-run cross-case (4b) with all cases (re-replacement)

`situations` (2) and `forces` (3) may run in parallel.

### Post-hoc Correction

When a missed pattern or error is discovered after a confirmation gate:

**Small correction (no pattern ID additions/deletions/renames)**:

- Edit the affected section directly (re-replace)
- Consult the dependency map above and verify consistency in **only the downstream sections that reference the changed content**
- Example: Adding B44 to H-S1's case manifestation column → verify that forces (4b) CF-\* entries citing H-S1 are still consistent

**Large correction (pattern IDs added/deleted/renamed)**:

- Re-run the affected subcommand (re-replacement) rather than manual patching
- Manual patching across multiple sections with ID changes is error-prone

### Re-replacement Consistency Rule

- ALWAYS: After any re-replacement or manual edit, consult the dependency map and verify consistency in **only the downstream sections that reference the modified content**
- Verification items: (a) any H-S*/H-St*/R-S*/R-St*/CF-\* added or changed in the edit exists and is correctly referenced downstream, (b) quantitative phrases like "N cases" match the actual case count
- If inconsistencies are found, re-replace the downstream sections as well

Report paths: `~/.agent-memory/<scope>/<date>_<topic>/job-discovery-report.md` and `job-discovery-appendix.md`

## Output Language Rules

- All user-facing output (table headers, section titles, labels) must be written in Japanese
- Annotate Hire (= the decision to "hire" a solution) and Re-hire (= the decision to "hire" the same solution again) on first use; use Hire/Re-hire as-is thereafter
- JTBD terminology (Push, Pull, Anxiety, Habit, Forces, Job) must include a Japanese translation on first use; abbreviations may be used thereafter
- Strength levels must be written in Japanese: 強/中/弱
- English terminology may be used as-is in subagent prompts for analysis accuracy
- Established loanwords whose original meaning would be lost in Japanese translation (e.g., エビデンス) should remain in English

## Strict Rules

- Do not propose or suggest solutions — this skill is demand-side analysis only
- Do not skip from facts to force analysis without data
- Do not proceed past a confirmation gate (→) without user approval
- Do not treat customer opinions or stated preferences as behavioral facts
- Do not score, rank, or prioritize — that belongs to experiment design
- NEVER ask the user to verify completeness — always perform self-review against the source material before presenting results at any confirmation gate
- RQ is the starting point for analysis, not a filter. Fact extraction is RQ-independent — every observable behavior and verbatim quote must be recorded regardless of apparent relevance to the RQ
- Inference permissions follow the epistemological ladder:
  - facts: No inference. Observable behavior and verbatim quotes only.
  - situations: No inference (observable only). Exception: Narrator Purpose allows action-pattern-based inference tagged as `[推定]` (see Narrator prompt).
  - forces: Fact-grounded interpretation permitted (Forces analysis — inferring demand dynamics from observed situations).
- Output written to the report or appendix (subagent output and integration results) must NOT contain file paths, plan references, or any external file references — the report must be a self-contained deliverable

## Completion

This skill is complete when all conditions are met:

- All subcommands' placeholders are filled in both the main report and appendix files
- The user has approved each confirmation gate
- The user confirms analysis is complete, or directs additional investigation
