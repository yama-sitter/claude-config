# Brief Workflow

## Prerequisites

None. This is the first subcommand in the workflow.

## Owned Placeholders

`{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`, `{{FRAME_AWARENESS}}`

## Workflow

Confirm the prerequisites for the analysis.

1. **分析対象の素材**: What source material to analyze (interview transcripts, feedback logs, etc.)
2. **ケース一覧**: Who are the cases? (Name, business type, role)
3. **分析の焦点（Research Question）**: What decision (Hire) are we analyzing, from what angle?
   - Examples: "初回利用→継続利用の流れ", "チャーンの経緯", "新規獲得の経路"
   - Note: The current skill is optimized for Hire → Re-hire analysis. Other focus types require Narrator prompt adjustments.
4. **フレーム認識**: What does this RQ assume? What might it NOT ask?
   - Note the implicit assumptions in the RQ's framing (e.g., "re-hire" assumes a single purpose for hiring)
   - Record the RQ's implicit phase assumptions (e.g., "re-hire" assumes a linear "try then repeat" journey). These assumptions become the contrast frame for phase definition (in facts Step 3) and RQ contrast (in jobs Step 5f)
   - The analysis should answer the RQ, but remain open to demand structures the RQ does not anticipate. If the data reveals purposes, segments, or dynamics outside the RQ's frame, capture them
5. **注目したい観点**（任意）: Any specific aspects the user wants to explore

## Confirmation Gate

Confirm the setup with the user before proceeding. After approval:

1. Copy [report-template.md](report-template.md) to create `job-discovery-report.md` at `~/.agent-memory/<scope>/<date>_<topic>/job-discovery-report.md`
2. Replace the header placeholders with confirmed data, including `{{FRAME_AWARENESS}}` with the frame awareness notes
3. Generate the `{{LEGEND}}` content dynamically based on the number of cases (e.g., '3社に共通する' for 3 cases, 'N社に共通する' for N cases)
