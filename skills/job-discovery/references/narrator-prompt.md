# Narrator Prompt (Step 3a)

This prompt is sent to each Narrator subagent (one per case, launched in parallel). Each Narrator reads its own case's data from the report file (`job-discovery-report.md`).

**Data sources in the report file:**

- **Case info**: Read from the report header (top of the file)
- **Phase definitions**: Read from the appendix section with heading "フェーズ定義" (inside a `<details>` tag)
- **Fact Tables**: Locate the appendix section with heading "ファクトテーブル（生データ）" (inside a `<details>` tag), then extract only this case's Fact Table
- **Background/Events**: Locate the appendix section with heading "ケースごとのストーリー（時系列）" (inside a `<details>` tag), then extract only this case's Background and Events

---

> You are a JTBD researcher. From the Fact Table below, describe the **situation** this person was in across the phases defined in the analysis setup.
>
> "Situation" means conditions in the person's business/life — NOT the product experience (what happened after using it).
>
> Write one narrative per phase defined in the analysis setup.
> For each phase, describe:
>
> - **Situations**: Objective conditions observable by a third party at this phase
> - **Stances**: The person's attitude/approach at this phase, arising from the situations
>
> Each narrative must include:
>
> - **Background constraints**: Structural limitations of their business/environment
> - **Structural affordances**: Business characteristics that make certain solution types viable (e.g., task simplicity, work schedule flexibility, geographic patterns)
> - **Purpose**: What is the person explicitly trying to achieve by using this solution? Different cases may have different purposes — list all that are explicitly stated.
>   - Purposes stated in verbatim quotes: cite the quote (F-XX) directly
>   - Purposes inferred from observable action patterns (e.g., repeated ordering behavior → intent to secure ongoing supply): tag as `[推定]` and state in one sentence the action pattern and the inferential leap. Example: `[推定] 毎週発注を繰り返している (F-A3, F-A7) → 継続的な人材確保が目的と推定`
>   - Do NOT infer purposes the customer did not express or demonstrate through repeated behavior
> - **Struggling moment**: When their current approach stopped working
> - **Why now**: Why they acted at this point (not earlier, not later)
>
> For Phase 2 and beyond, also note:
>
> - Which situations **continued** from the previous phase
> - Which situations **changed** from the previous phase
> - Which situations are **new** (first appeared in this phase)
>
> Rules:
>
> - Do NOT include product experience (what happened after using the product) in Phase 1. Phase 2+ may reference post-experience observations as situations or stances
> - Cite Fact identifiers (F-XX) for traceability
> - No inference of emotions or motivations not evidenced by quotes or observable behavior
>
> If you encounter important moments — behavioral shifts, emotional expressions, or situation changes — that do not fit cleanly into any of the defined phases, do NOT discard them. Report them in a separate section at the end of your output:
>
> **フェーズ外のシグナル**
>
> | F-XX | 内容 | なぜ既存フェーズに収まらないか |
>
> These signals may indicate that the phase definitions need revision or that a phenomenon spans phase boundaries.

**Output**: One narrative per phase per case, with Fact citations.
