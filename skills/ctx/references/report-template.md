# Report Template

Template for the ctx report. `setup` copies this template to create two files: a main report file and an appendix file. Each subsequent subcommand replaces its placeholders with actual data after user confirmation.

<!--
Design principles (apply when writing content into placeholders):

- Conclusion first: Common contexts (most abstract) → supporting per-case details
- Traceability throughout: All sections use CC-*/X-C* identifiers as plain text
- Hide internal process: No Phase numbers, subagent names, or skill-internal terminology in any section
- List formatting in tables: Use comma-separated format "A: x, B: y, C: z" for Notion compatibility. Do NOT use <br> tags
- No Why / So what: Descriptions must be observational — do not include causal interpretation or significance claims
-->

## Placeholder Reference

| Subcommand | Placeholder                                                                                                     | File | Section                    |
| ---------- | --------------------------------------------------------------------------------------------------------------- | ---- | -------------------------- |
| setup      | `{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`, `{{FRAME_AWARENESS}}` | 本体 | Header                     |
| ext 1      | `{{FACT_TABLES}}`                                                                                               | 付録 | ファクトテーブル           |
| ext 2      | `{{BACKGROUND_EVENTS}}`                                                                                         | 付録 | 時系列整理                 |
| organize A | `{{CONTEXT_DESCRIPTIONS}}`                                                                                      | 付録 | ケースごとのコンテキスト   |
| organize B | `{{COMMON_CONTEXTS}}`                                                                                           | 本体 | 共通コンテキスト           |

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

## 共通コンテキスト

<!-- BEGIN COMMON_CONTEXTS -->

{{COMMON_CONTEXTS}}

<!-- END COMMON_CONTEXTS -->

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

## 時系列整理（Background / Events）

<!-- BEGIN BACKGROUND_EVENTS -->

{{BACKGROUND_EVENTS}}

<!-- END BACKGROUND_EVENTS -->

## ケースごとのコンテキスト記述

<!-- BEGIN CONTEXT_DESCRIPTIONS -->

{{CONTEXT_DESCRIPTIONS}}

<!-- END CONTEXT_DESCRIPTIONS -->
