# Report Template

Template for the job-discovery report file. Step 0 copies this template to create the report file, then each Step replaces its placeholders with actual data after user confirmation.

<!--
Design principles (apply when writing content into placeholders):

- No JTBD jargon without explanation: Annotate Hire, Re-hire, Push, Pull, etc. with plain-language descriptions on first use
- Conclusion first: Job hypotheses (most abstract) → supporting patterns → detailed data
- Traceability throughout: All sections use P*-S*/P*-St*/CF-*/F-XX identifiers
- Hide internal process: No lens names, Step numbers, or skill-internal terminology in main sections
- Appendix is collapsible: Use <details> tags for raw data
- List formatting in tables: Use comma-separated format "A: x, B: y, C: z" for Notion compatibility. Do NOT use <br> tags
- Anchor formatting (in-page links for traceability):
  - Definition (identifier first appears in a table's first column): `<span id="ID">ID</span>`
  - Reference (根拠/出典 columns, parenthesized citations, causal chain prose): `[ID](#ID)`
  - Range references: `[A3](#A3)-[A5](#A5)` (link start and end points)
  - Causal chain prose: `[P1-S1](#P1-S1)（description）→ [P1-St1](#P1-St1)（description）`
-->

## Placeholder Reference

| Step | Placeholder | Section |
|------|-------------|---------|
| brief | `{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`, `{{FRAME_AWARENESS}}` | Header |
| facts 1 | `{{STEP1_FACT_TABLES}}` | Appendix |
| facts 2 | `{{STEP2_BACKGROUND_EVENTS}}` | Appendix |
| facts 3 | `{{STEP2B_PHASE_DEFINITIONS}}` | Appendix |
| 3a | `{{STEP3A_NARRATOR_OUTPUTS}}` | Appendix |
| 3b | `{{STEP3B_ANALYST_CRITIC_OUTPUT}}` | Appendix |
| 3c | `{{STEP3_COMMON_PATTERNS}}` | Section 2 (includes section heading) |
| 4a | `{{STEP4_PERCASE_FORCES}}` | Appendix |
| 4b | `{{STEP4_CROSS_FORCES}}`, `{{STEP4_COMMON_NARRATIVE}}` | Section 3 |
| 5 | `{{STEP5_SUMMARY_INTRO}}`, `{{STEP5_JOB_HYPOTHESES}}`, `{{STEP5_RQ_CONTRAST}}` | Section 1 |

## Document Skeleton

The content below (after the `---` separator) is copied as-is to create the report file. Lines starting with `>` in the skeleton are not Markdown blockquotes — they are literal content.

---

<!-- BEGIN TITLE -->
# Job Discovery: {{TITLE}}
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

## 1. 発見されたジョブ仮説

「顧客がこのサービスを使う理由」の仮説候補。
確定版ではなく、議論・検証のための叩き台として複数の視点から生成しています。

<!-- BEGIN STEP5_SUMMARY_INTRO -->
{{STEP5_SUMMARY_INTRO}}
<!-- END STEP5_SUMMARY_INTRO -->

<!-- BEGIN STEP5_JOB_HYPOTHESES -->
{{STEP5_JOB_HYPOTHESES}}
<!-- END STEP5_JOB_HYPOTHESES -->

<!-- BEGIN STEP5_RQ_CONTRAST -->
{{STEP5_RQ_CONTRAST}}
<!-- END STEP5_RQ_CONTRAST -->

---

<!-- BEGIN STEP3_COMMON_PATTERNS -->
{{STEP3_COMMON_PATTERNS}}
<!-- END STEP3_COMMON_PATTERNS -->

---

## 3. 共通する意思決定の力学

<!-- BEGIN STEP4_CROSS_FORCES -->
{{STEP4_CROSS_FORCES}}
<!-- END STEP4_CROSS_FORCES -->

### 共通ナラティブ

<!-- BEGIN STEP4_COMMON_NARRATIVE -->
{{STEP4_COMMON_NARRATIVE}}
<!-- END STEP4_COMMON_NARRATIVE -->

---

## 付録

<details>
<summary>ファクトテーブル（生データ）</summary>

<!-- BEGIN STEP1_FACT_TABLES -->
{{STEP1_FACT_TABLES}}
<!-- END STEP1_FACT_TABLES -->

</details>

<details>
<summary>ケースごとのストーリー（時系列）</summary>

<!-- BEGIN STEP2_BACKGROUND_EVENTS -->
{{STEP2_BACKGROUND_EVENTS}}
<!-- END STEP2_BACKGROUND_EVENTS -->

</details>

<details>
<summary>フェーズ定義</summary>

<!-- BEGIN STEP2B_PHASE_DEFINITIONS -->
{{STEP2B_PHASE_DEFINITIONS}}
<!-- END STEP2B_PHASE_DEFINITIONS -->

</details>

<details>
<summary>ケースごとの状況分析（ナレーター）</summary>

<!-- BEGIN STEP3A_NARRATOR_OUTPUTS -->
{{STEP3A_NARRATOR_OUTPUTS}}
<!-- END STEP3A_NARRATOR_OUTPUTS -->

</details>

<details>
<summary>クロスケース比較・検証（アナリスト）</summary>

<!-- BEGIN STEP3B_ANALYST_CRITIC_OUTPUT -->
{{STEP3B_ANALYST_CRITIC_OUTPUT}}
<!-- END STEP3B_ANALYST_CRITIC_OUTPUT -->

</details>

<details>
<summary>ケースごとの力学分析</summary>

<!-- BEGIN STEP4_PERCASE_FORCES -->
{{STEP4_PERCASE_FORCES}}
<!-- END STEP4_PERCASE_FORCES -->

</details>
