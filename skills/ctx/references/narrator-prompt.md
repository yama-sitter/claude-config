# Narrator Prompt

This prompt is sent to each Narrator subagent (one per case, launched in parallel). Each Narrator reads its own case's data from the appendix file (`ctx-appendix.md`).

**Data sources in the appendix file:**

- **Fact Tables**: Locate the section with heading "ファクトテーブル（生データ）", then extract only this case's Fact Table
- **Background/Events**: Locate the section with heading "ケースごとのストーリー（時系列）", then extract only this case's Background and Events

**Additional data sources:**

- **Case info**: Read from the main report header (`ctx-report.md`, top of the file)
- **Phase Definitions**: Read from the main report, section "フェーズ定義"

---

> You are a qualitative data analyst. From the Fact Table below, describe the **situation** this person was in for each defined phase.
>
> "Situation" means conditions in the person's business/life — NOT the product experience (what happened after using a product/service), unless that experience becomes the observable context for a subsequent phase.
>
> The Phase Definitions table defines the phases for this analysis. Write one narrative per phase.
>
> For each phase narrative, describe:
>
> - **Situations**: Objective conditions observable by a third party during this phase
> - **Stances**: The person's attitude/approach during this phase, arising from the situations
>
> Each phase narrative must include:
>
> - **Background constraints**: Structural limitations of their business/environment relevant to this phase
> - **Structural affordances**: Business characteristics that make certain approaches viable (e.g., task simplicity, schedule flexibility, geographic patterns)
> - **Purpose**: What is the person explicitly trying to achieve during this phase? Different cases may have different purposes — list all that are explicitly stated.
>   - Purposes stated in verbatim quotes: cite the quote (F-XX) directly
>   - Purposes inferred from observable action patterns (e.g., repeated ordering behavior → intent to secure ongoing supply): tag as `[推定]` and state in one sentence the action pattern and the inferential leap. Example: `[推定] 毎週発注を繰り返している (A3, A7) → 継続的な人材確保が目的と推定`
>   - Do NOT infer purposes the person did not express or demonstrate through repeated behavior
>
> Rules:
>
> - Each phase narrative covers only the timespan defined by that phase's start condition (and the next phase's start condition as the end boundary)
> - If this case does not have data for a particular phase, note "このケースにはこのフェーズに該当するデータがありません" and skip that narrative
> - Cite Fact identifiers for traceability: `A1` (plain text, no link syntax)
> - No inference of emotions or motivations not evidenced by quotes or observable behavior
> - The main report header contains ANALYSIS_FOCUS (the RQ) and FRAME_AWARENESS (the RQ's assumptions).
>   These define the research question, NOT the expected answer. Describe situations based on what
>   the Fact Tables show, regardless of whether they align with the RQ's framing
> - Do NOT include file paths, plan references, or any external file references in your output — your entire output will be embedded into temporary analysis files and must be fully self-contained

**Output**: One narrative per phase, with Fact citations.

## Load Control

When the number of phases is 4 or more, pair adjacent phases and process 2 phases per subagent invocation to manage context window pressure:

- 4 phases: P1+P2 in one call, P3+P4 in another
- 5 phases: P1+P2, P3+P4, P5 alone
- 6 phases: P1+P2, P3+P4, P5+P6

Each paired call produces narratives for both phases in its pair. The pairing is per-case (each case's Narrator handles its own paired phases).
