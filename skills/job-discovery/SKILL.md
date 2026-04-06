---
name: job-discovery
description: |
  Discover Jobs-to-be-Done from customer behavior facts, interview logs, or feedback data.
  Use when the user provides raw customer data and wants to discover the underlying demand structure and generate Job hypotheses.
  Do not use when the user already has a clear hypothesis and wants to design experiments.
  Do not use when the user wants to brainstorm or evaluate solutions.
  Subcommands: scope, facts, context, forces, jobs. No args = progress check.
user-invocable: true
---

# Job Discovery

Discover Jobs-to-be-Done from raw customer data by climbing the Ladder of Inference one rung at a time.

## Prerequisites

- Customer interview logs, behavior data, or feedback are accessible
- This skill produces demand-side analysis only — output feeds into experiment design

## Argument Routing

| Args      | Action                                                                                                                      |
| --------- | --------------------------------------------------------------------------------------------------------------------------- |
| (none)    | Progress check: detect report → show filled/unfilled placeholders → suggest next subcommand                                 |
| `scope`   | 分析の枠組み定義（焦点、ケース、フェーズ）→ レポートファイル作成。→ [scope-workflow.md](references/scope-workflow.md)        |
| `facts`   | ソース素材からの事実抽出・時系列整理。→ [facts-workflow.md](references/facts-workflow.md)                                    |
| `context` | ケース横断の共通コンテキスト抽出（Narrator→Analyst-Critic→Integration）。→ [context-workflow.md](references/context-workflow.md) |
| `forces`  | 意思決定の力学分析（Push/Pull/Anxiety/Habit）。context との順序は任意。→ [forces-workflow.md](references/forces-workflow.md) |
| `jobs`    | ジョブ仮説の生成・フィルタリング・提示。→ [jobs-workflow.md](references/jobs-workflow.md)                                    |

Read the linked workflow file and follow its instructions.

## Report Discovery

When any subcommand other than `scope` is invoked, locate the active report:

1. Search: `ls ~/.agent-memory/*/job-discovery-report.md`
2. If exactly one report found → use it
3. If multiple found → list each report's title line (`# Job Discovery: ...`) and whether it has unfilled placeholders (in-progress). Prioritize in-progress reports. Ask the user to choose
4. If none found → tell the user to run `/job-discovery scope` first

## Prerequisite Check

On subcommand start, verify that the prerequisite placeholders are all replaced (no `{{` remaining for those placeholders). If unmet, inform the user which prior subcommand to run.

| Subcommand | Prerequisite placeholders that must be filled                                       |
| ---------- | ----------------------------------------------------------------------------------- |
| `scope`    | (none)                                                                              |
| `facts`    | `{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}` |
| `context`  | `{{STEP1_FACT_TABLES}}`, `{{STEP2_BACKGROUND_EVENTS}}`                              |
| `forces`   | `{{STEP1_FACT_TABLES}}`, `{{STEP2_BACKGROUND_EVENTS}}`                              |
| `jobs`     | `{{STEP3_COMMON_PATTERNS}}`, `{{STEP4_CROSS_FORCES}}`, `{{STEP4_COMMON_NARRATIVE}}` |

Note: `context` and `forces` share the same prerequisites and can be executed in either order. `jobs` requires both to be complete.

## Progress Check (default)

When invoked with no arguments:

1. Run Report Discovery
2. If no report found → display: "分析がまだ開始されていません。`/job-discovery scope` で開始してください"
3. If report found → run `grep '{{' <report-path>` to find unfilled placeholders
4. Map unfilled placeholders to subcommands and display progress:

```
## 進捗: <レポートタイトル>

✅ scope — 枠組み定義
✅ facts — 事実抽出・整理
⬜ context — 共通コンテキスト抽出
⬜ forces — 力学分析
⬜ jobs — ジョブ検出

→ 次のステップ: `/job-discovery context` または `/job-discovery forces`
```

Next-step suggestion logic:

- scope incomplete → `scope`
- facts incomplete → `facts`
- both context and forces incomplete → suggest both (user chooses order)
- one of context/forces incomplete → suggest the incomplete one
- jobs incomplete (context and forces complete) → `jobs`

Placeholder → subcommand mapping:

| Placeholder pattern                                                                  | Subcommand |
| ------------------------------------------------------------------------------------ | ---------- |
| `{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}` | scope      |
| `{{STEP1_FACT_TABLES}}`, `{{STEP2_BACKGROUND_EVENTS}}`                               | facts      |
| `{{STEP3A_NARRATOR_OUTPUTS}}`, `{{STEP3B_ANALYST_CRITIC_OUTPUT}}`, `{{STEP3_COMMON_PATTERNS}}` | context |
| `{{STEP4_PERCASE_FORCES}}`, `{{STEP4_CROSS_FORCES}}`, `{{STEP4_COMMON_NARRATIVE}}`   | forces     |
| `{{STEP5_SUMMARY_INTRO}}`, `{{STEP5_JOB_HYPOTHESES}}`                               | jobs       |

## Data Flow

The `scope` subcommand creates `job-discovery-report.md` from the report template ([report-template.md](references/report-template.md)). Each subsequent subcommand replaces its placeholders (`{{XXX}}`) in the report file with actual data after user confirmation. When all subcommands complete, the report is the finished deliverable.

- **job-discovery-report.md**: Single source of truth. The report file is both the analysis record and the final deliverable.
- **Read before execute**: Each subcommand reads the relevant filled sections from the report before starting. Subagents locate sections by heading text (e.g., "ファクトテーブル（生データ）"), not by line number.
- **Replace after confirm**: Each subcommand's output replaces its placeholder(s) after user approval at the confirmation gate. Content is wrapped in HTML comment boundary markers (`<!-- BEGIN XXX -->...<!-- END XXX -->`) for re-replacement if the user requests revisions.
- **Atomic replacement**: When a subcommand has multiple placeholders, all are replaced together after the confirmation gate. No partial replacement state.
- **Re-replacement**: If the user requests a revision after confirmation, locate the content between `<!-- BEGIN XXX -->` and `<!-- END XXX -->` markers and replace it with the revised content.

Report path: `~/.agent-memory/<scope>/<date>_<topic>/job-discovery-report.md`

## Output Language Rules

- All user-facing output (table headers, section titles, labels) must be written in Japanese
- Annotate Hire (= the decision to "hire" a solution) and Re-hire (= the decision to "hire" the same solution again) on first use; use Hire/Re-hire as-is thereafter
- JTBD terminology (Push, Pull, Anxiety, Habit, Forces, Job) must include a Japanese translation on first use; abbreviations may be used thereafter
- Strength levels must be written in Japanese: 強/中/弱
- Job Statement syntax (When / I want to / so that) must use a bilingual English + Japanese format
- English terminology may be used as-is in subagent prompts for analysis accuracy
- Established loanwords whose original meaning would be lost in Japanese translation (e.g., エビデンス) should remain in English

## Strict Rules

- Do not propose or suggest solutions — this skill is demand-side analysis only
- Do not skip from facts to job definition
- Do not proceed past a confirmation gate (→) without user approval
- Do not treat customer opinions or stated preferences as behavioral facts
- Do not score, rank, or prioritize — that belongs to experiment design
- NEVER ask the user to verify completeness — always perform self-review against the source material before presenting results at any confirmation gate
- Inference permissions follow the epistemological ladder:
  - scope, facts, context: No inference. Observable behavior and verbatim quotes only. Exception: context Narrator Purpose allows action-pattern-based inference tagged as `[推定]` (see Narrator prompt).
  - forces: Fact-grounded interpretation permitted (Forces analysis — inferring demand dynamics from observed contexts).
  - jobs: Hypothesis synthesis permitted (Job definition — generating candidate Job Statements through multiple analytical lenses, filtering for quality, and presenting as discussion material for user selection).

## Completion

This skill is complete when all conditions are met:

- All subcommands' placeholders are filled in the report file
- Job Statement candidates have been generated through multiple lenses, quality-filtered, and presented to the user
- The user has selected, combined, or modified candidates to define the final Job Statement(s)
- The final statement is traceable to common contexts (P*-S*/P*-St*) and Common Forces (CF-_), with Facts (F-_) as supporting evidence
- The user confirms analysis is complete, or directs additional investigation
