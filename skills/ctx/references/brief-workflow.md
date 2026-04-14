# Brief Workflow

## Prerequisites

None. This is the first subcommand in the workflow.

## Owned Placeholders

`{{TITLE}}`, `{{SOURCE_MATERIAL}}`, `{{ANALYSIS_FOCUS}}`, `{{CASE_TABLE}}`, `{{LEGEND}}`, `{{FRAME_AWARENESS}}`

## Workflow

Confirm the prerequisites for the analysis.

1. **分析対象の素材**: What source material to analyze (interview transcripts, feedback logs, behavior data, etc.)
2. **ケース一覧**: Who are the cases? (Name, business type, role, or other identifying attributes)
3. **分析の焦点（Research Question）**: What are we analyzing, from what angle?
   - Examples: "導入から定着までの行動変化", "利用を止めた経緯", "意思決定プロセスの比較", "業務課題への対応パターン"
   - The RQ defines the starting direction, not the expected findings. Analysis may reveal patterns outside the RQ's scope
4. **フレーム認識**: What does this RQ assume? What might it NOT ask?
   - Note the implicit assumptions in the RQ's framing (e.g., assuming a linear progression, assuming a single motivation, assuming all cases share the same context)
   - Record the RQ's implicit assumptions as personal bias awareness notes. These help the analyst stay open to findings that don't match initial expectations
   - The analysis should answer the RQ, but remain open to patterns the RQ does not anticipate. If the data reveals purposes, segments, or dynamics outside the RQ's frame, capture them
   - Frame awareness is critical — it is the primary defense against confirmation bias throughout the analysis
5. **注目したい観点**（任意）: Any specific aspects the user wants to explore

## Confirmation Gate

Confirm the setup with the user before proceeding. After approval:

1. Copy [report-template.md](report-template.md) to create two files at `~/.agent-memory/<scope>/<date>_<topic>/`:
   - `ctx-report.md` (main report — from the main report skeleton)
   - `ctx-appendix.md` (appendix — from the appendix skeleton)
2. Replace the header placeholders in the main report with confirmed data, including `{{FRAME_AWARENESS}}` with the frame awareness notes. Replace `{{TITLE}}` in the appendix file as well
3. Generate the `{{LEGEND}}` content dynamically based on the number of cases (e.g., '3社に共通する' for 3 cases, 'N社に共通する' for N cases)
