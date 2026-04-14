# Report Template

Template for the ctx report. The `brief` subcommand copies this template to create two files: a main report file and an appendix file. Each subsequent subcommand replaces its placeholders with actual data after user confirmation.

<!--
Design principles (apply when writing content into placeholders):

- Framework-agnostic: No JTBD, persona, or other framework-specific jargon
- Structure first, synthesis later: Section 1 (phase-specific patterns, most concrete) → Section 2 (integration across phases)
- Traceability throughout: All sections use P*-S*/P*-St*/F-XX identifiers as plain text
- Hide internal process: No subcommand names, subagent names, or skill-internal terminology in any section
- List formatting in tables: Use comma-separated format "A: x, B: y, C: z" for Notion compatibility. Do NOT use <br> tags
- No interpretation: Report observable patterns and their connections only. Do not explain "why" people acted as they did
-->

## Placeholder Reference

| Subcommand | Placeholder                                                                                                     | File | Section                          |
| ---------- | --------------------------------------------------------------------------------------------------------------- | ---- | -------------------------------- |
| brief      | `{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`, `{{FRAME_AWARENESS}}` | 本体 | Header                           |
| facts 1    | `{{FACT_TABLES}}`                                                                                               | 付録 | ファクトテーブル                 |
| facts 2    | `{{BACKGROUND_EVENTS}}`                                                                                         | 付録 | ケースごとのストーリー           |
| phases     | `{{PHASE_DEFINITIONS}}`                                                                                         | 本体 | フェーズ定義                     |
| context    | `{{COMMON_PATTERNS}}`                                                                                           | 本体 | Section 1                        |
| context    | `{{CASE_NARRATIVES}}`                                                                                           | 付録 | ケースごとのフェーズ別ナラティブ |
| synthesis  | `{{RQ_CONTRAST}}`, `{{PATTERN_CONNECTIONS}}`, `{{COMMON_NARRATIVE}}`                                            | 本体 | Section 2                        |

## Document Skeleton

Two files are created from the skeletons below. The `--- appendix ---` separator marks the boundary between the main report and the appendix file.

### Main Report (ctx-report.md)

The content below (after the `---` separator) is copied as-is to create the main report file. Lines starting with `>` in the skeleton are not Markdown blockquotes — they are literal content.

---

<!-- BEGIN TITLE -->

# Ctx: {{TITLE}}

<!-- END TITLE -->

<!-- BEGIN SOURCE_MATERIAL -->

- **分析対象**: {{SOURCE_MATERIAL}}
  <!-- END SOURCE_MATERIAL -->
  <!-- BEGIN ANALYSIS_FOCUS -->
- **焦点**: {{ANALYSIS_FOCUS}}
<!-- END ANALYSIS_FOCUS -->

<!-- BEGIN CASE_TABLE -->

{{CASE_TABLE}}

<!-- END CASE_TABLE -->

<!-- BEGIN LEGEND -->

{{LEGEND}}

<!-- END LEGEND -->

<!-- BEGIN FRAME_AWARENESS -->

{{FRAME_AWARENESS}}

<!-- END FRAME_AWARENESS -->

---

## フェーズ定義

<!-- BEGIN PHASE_DEFINITIONS -->

{{PHASE_DEFINITIONS}}

<!-- END PHASE_DEFINITIONS -->

---

## 1. N社に共通する行動パターン

<!-- BEGIN COMMON_PATTERNS -->

{{COMMON_PATTERNS}}

<!-- END COMMON_PATTERNS -->

---

## 2. 統合

### RQ コントラスト

<!-- BEGIN RQ_CONTRAST -->

{{RQ_CONTRAST}}

<!-- END RQ_CONTRAST -->

### パターン接続

<!-- BEGIN PATTERN_CONNECTIONS -->

{{PATTERN_CONNECTIONS}}

<!-- END PATTERN_CONNECTIONS -->

### 共通ナラティブ

<!-- BEGIN COMMON_NARRATIVE -->

{{COMMON_NARRATIVE}}

<!-- END COMMON_NARRATIVE -->

--- appendix ---

### Appendix (ctx-appendix.md)

The content below (after the `---` separator) is copied as-is to create the appendix file.

---

<!-- BEGIN TITLE -->

# 付録: {{TITLE}}

<!-- END TITLE -->

## ファクトテーブル（生データ）

<!-- BEGIN FACT_TABLES -->

{{FACT_TABLES}}

<!-- END FACT_TABLES -->

## ケースごとのストーリー（時系列）

<!-- BEGIN BACKGROUND_EVENTS -->

{{BACKGROUND_EVENTS}}

<!-- END BACKGROUND_EVENTS -->

## ケースごとのフェーズ別ナラティブ

<!-- BEGIN CASE_NARRATIVES -->

{{CASE_NARRATIVES}}

<!-- END CASE_NARRATIVES -->
