# Report Template

Template for the dex report. Step 0 copies this template to create two files: a main report file and an appendix file. Each subsequent Step replaces its placeholders with actual data after user confirmation.

<!--
Design principles (apply when writing content into placeholders):

- No JTBD jargon without explanation: Annotate Hire, Re-hire, Push, Pull, etc. with plain-language descriptions on first use
- Conclusion first: Common situations (most abstract) → supporting forces → detailed data
- Traceability throughout: All sections use H-S*/H-St*/R-S*/R-St*/CF-*/F-XX identifiers as plain text
- Hide internal process: No Step numbers, subagent names, or skill-internal terminology in any section
- List formatting in tables: Use comma-separated format "A: x, B: y, C: z" for Notion compatibility. Do NOT use <br> tags
-->

## Placeholder Reference

| Step      | Placeholder                                                                                                     | File | Section                |
| --------- | --------------------------------------------------------------------------------------------------------------- | ---- | ---------------------- |
| brief     | `{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`, `{{FRAME_AWARENESS}}` | 本体 | Header                 |
| facts 1   | `{{FACT_TABLES}}`                                                                                               | 付録 | ファクトテーブル       |
| facts 2   | `{{BACKGROUND_EVENTS}}`                                                                                         | 付録 | ケースごとのストーリー |
| context   | `{{COMMON_CONTEXT_HIRE}}`, `{{COMMON_CONTEXT_REHIRE}}`                                                          | 本体 | Section 1              |
| forces 4a | `{{PERCASE_FORCES}}`                                                                                            | 付録 | ケースごとの力学分析   |
| forces 4b | `{{CROSS_FORCES_HIRE}}`, `{{CROSS_FORCES_REHIRE}}`                                                              | 本体 | Section 2              |

## Document Skeleton

Two files are created from the skeletons below. The `--- appendix ---` separator marks the boundary between the main report and the appendix file.

### Main Report (dex-report.md)

The content below (after the `---` separator) is copied as-is to create the main report file. Lines starting with `>` in the skeleton are not Markdown blockquotes — they are literal content.

---

<!-- BEGIN TITLE -->

# Dex: {{TITLE}}

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

## 1. 共通の状況

### Hire の状況（需要の急性化 + 手段選択の条件）

<!-- BEGIN COMMON_CONTEXT_HIRE -->

{{COMMON_CONTEXT_HIRE}}

<!-- END COMMON_CONTEXT_HIRE -->

### Re-hire の状況（継続の条件）

<!-- BEGIN COMMON_CONTEXT_REHIRE -->

{{COMMON_CONTEXT_REHIRE}}

<!-- END COMMON_CONTEXT_REHIRE -->

---

## 2. 共通する意思決定の力学

### Hire 時

<!-- BEGIN CROSS_FORCES_HIRE -->

{{CROSS_FORCES_HIRE}}

<!-- END CROSS_FORCES_HIRE -->

### Re-hire 時

<!-- BEGIN CROSS_FORCES_REHIRE -->

{{CROSS_FORCES_REHIRE}}

<!-- END CROSS_FORCES_REHIRE -->

--- appendix ---

### Appendix (dex-appendix.md)

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

## ケースごとの力学分析

<!-- BEGIN PERCASE_FORCES -->

{{PERCASE_FORCES}}

<!-- END PERCASE_FORCES -->
