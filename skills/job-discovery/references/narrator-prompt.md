# Narrator Prompt (Step 3a)

This prompt is sent to each Narrator subagent (one per case, launched in parallel). Each Narrator reads its own case's data from the appendix file (`job-discovery-appendix.md`).

**Data sources in the appendix file:**

- **Fact Tables**: Locate the section with heading "ファクトテーブル（生データ）", then extract only this case's Fact Table
- **Background/Events**: Locate the section with heading "ケースごとのストーリー（時系列）", then extract only this case's Background and Events

**Additional data source:**

- **Case info**: Read from the main report header (`job-discovery-report.md`, top of the file)

---

> You are a JTBD researcher. From the Fact Table below, describe the **situation** this person was in for two timepoints: before Hire and during Re-hire.
>
> "Situation" means conditions in the person's business/life — NOT the product experience (what happened after using it).
>
> Write two narratives: (1) **Hire前の状況** and (2) **Re-hireの状況**.
> For each narrative, describe:
>
> - **Situations**: Objective conditions observable by a third party at this timepoint
> - **Stances**: The person's attitude/approach at this timepoint, arising from the situations
>
> Each narrative must include:
>
> - **Background constraints**: Structural limitations of their business/environment
> - **Structural affordances**: Business characteristics that make certain solution types viable (e.g., task simplicity, work schedule flexibility, geographic patterns)
> - **Purpose**: What is the person explicitly trying to achieve by using this solution? Different cases may have different purposes — list all that are explicitly stated.
>   - Purposes stated in verbatim quotes: cite the quote (F-XX) directly
>   - Purposes inferred from observable action patterns (e.g., repeated ordering behavior → intent to secure ongoing supply): tag as `[推定]` and state in one sentence the action pattern and the inferential leap. Example: `[推定] 毎週発注を繰り返している (A3, A7) → 継続的な人材確保が目的と推定`
>   - Do NOT infer purposes the customer did not express or demonstrate through repeated behavior
> - **Struggling moment**: When their current approach stopped working
> - **Why now**: Why they acted at this point (not earlier, not later)
>
> Rules:
>
> - Do NOT include product experience (what happened after using the product) in Hire前の状況. Re-hireの状況 may reference post-experience observations as situations or stances
> - Cite Fact identifiers for traceability: `A1` (plain text, no link syntax)
> - No inference of emotions or motivations not evidenced by quotes or observable behavior
> - The main report header contains ANALYSIS_FOCUS (the RQ) and FRAME_AWARENESS (the RQ's assumptions).
>   These define the research question, NOT the expected answer. Describe situations based on what
>   the Fact Tables show, regardless of whether they align with the RQ's framing
> - Do NOT include file paths, plan references, or any external file references in your output — your entire output will be embedded into temporary analysis files and must be fully self-contained

**Output**: Two narratives per case (Hire / Re-hire), with Fact citations.
