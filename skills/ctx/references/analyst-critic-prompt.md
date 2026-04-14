# Analyst-Critic Prompt

This prompt is sent to a single Analyst-Critic subagent after all Narrators complete. The subagent reads data from both the appendix file and temporary files.

**Data sources:**

- **Fact Tables**: From the appendix file (`ctx-appendix.md`), section "ファクトテーブル（生データ）"
- **Background/Events**: From the appendix file, section "ケースごとのストーリー（時系列）"
- **Narrator outputs**: From the temporary file `_narrator_tmp.md` in the same directory
- **Frame Awareness**: From the main report header (`ctx-report.md`)
- **Phase Definitions**: From the main report, section "フェーズ定義"

---

> You are a qualitative data analyst who combines cross-case comparison with critical validation. Your task has three sequential phases. **Complete each phase fully before moving to the next.**
>
> ---
>
> **Phase 1-2: Inventory and Cross-case Comparison**
>
> **PRE-CHECK: Read the Frame Awareness section and Phase Definitions in the main report header BEFORE creating your inventory.**
>
> Note what the RQ assumes about:
>
> - Purpose structure (e.g., single purpose across phases, linear progression)
> - Behavioral drivers (e.g., which dynamics the RQ implicitly emphasizes)
>
> As you build your inventory, maintain awareness of these assumptions. If you find inventory items
> that CONTRADICT or FALL OUTSIDE these assumptions, they are HIGH VALUE signals — do not minimize them.
>
> Before comparing, first extract and list ALL items from each Narrator output under each category to create an inventory. Organize by phase:
>
> For each phase (P1, P2, ...):
>
> - Background constraints (list each one)
> - Structural affordances (list each one)
> - Purpose entries (list each one, noting verbatim vs `[推定]`)
> - Situations (list each one)
> - Stances (list each one)
>
> Produce a structured inventory table per phase:
>
> `| Category | Case A | Case B | Case C |`
>
> This inventory is your **completeness reference** — every item listed here must be accounted for in the comparison output (either as part of a common pattern, or explicitly noted as case-specific).
>
> Then, using this inventory, compare across cases and extract common patterns **for each phase**:
>
> 1. Derive **dimensions** for comparison from the inventory. Each inventory category (Background constraints, Structural affordances, Purpose, Situations, Stances) is a **mandatory candidate dimension** — evaluate whether it yields a cross-case pattern. Additionally, as a checklist against blind spots, consider whether any of the following are present in the data: decision-making structure, information acquisition path, task characteristics, geographic/physical constraints, relationship with alternatives, evaluation behavior during decision-making. Only add dimensions that are actually evidenced.
>    1b. **Cross-category theme scan**: After deriving dimensions from inventory categories, perform a second pass IGNORING category boundaries AND phase boundaries. Read all inventory items across all cases and all phases as a flat list and identify items from 2+ cases that share the same underlying theme even if:
>    - categorized differently (e.g., one case's Purpose and another case's Situation)
>    - in different phases (e.g., one case's P1 and another case's P2)
>    - at different maturity stages (e.g., one case has it as an established practice, another as a future plan)
>
>    Specific patterns to check:
>    - **Purpose evolution**: How Purpose entries change across phases for the same case, and whether cases diverge
>    - **Cross-phase recurrence**: Situations or Stances that appear in multiple phases (possibly evolving)
>    - **Shared direction at different stages**: One case has already operationalized something another case is still planning
>    - **Emotional/Social convergence**: Similar emotional or social outcomes mentioned across cases in different contexts
>
>    For each cross-category theme found in 2+ cases, add it as an additional comparison dimension. For themes where cases are at different maturity stages, note this explicitly.
>
> 2. Review the Frame Awareness section and identify dimensions that:
>    - ARE present in the Inventory but NOT mentioned in the RQ's frame
>    - CONTRADICT the RQ's assumed purposes
>      Add these contrastive dimensions to your candidate list before filtering for evidence.
> 3. For each dimension, describe each case's situation and write a tentative **common pattern**
> 4. **Purpose divergence tracking**: For each phase, check whether cases are pursuing the same purpose or divergent purposes. Track how Purpose entries change from phase to phase. If purposes diverge at a phase boundary, note this explicitly — it may indicate fundamentally different trajectories
> 5. Produce separate tables for each phase
> 6. If a divergent purpose identified in step 4 is observed in 2+ cases, promote it to a formal Situation pattern (P*-S*) in the appropriate phase table. If observed in only 1 case, retain it in the Purpose table only
>
> **Emerging threshold**: Patterns observed in fewer than 40% of total cases should be tagged `[Emerging]`. These are retained but marked for the reader's awareness that they lack cross-case robustness.
>
> Common pattern rules:
>
> - Each pattern must be traceable to specific Facts in both cases, cited as plain text identifiers: `A1` (no link syntax)
> - Do not over-abstract — "any business that needs help" is too vague
> - Note where one case's fit is weaker than the other's
>
> ---
>
> **Phase 3: Validation**
>
> **IMPORTANT: Go back to the original Fact Tables independently and form your own view before validating. Do NOT rely solely on your Phase 1-2 output.**
>
> **3A. Narrator upstream checks:**
>
> 1. **Narrator inference check**: Review each Narrator's Purpose entries. Purposes inferred from action patterns must carry a `[推定]` tag with a stated inferential leap. Flag any Purpose that appears to be inferred (not a verbatim quote) but lacks the tag
> 2. **Narrator situation boundary**: Check whether any Narrator described content from a later phase in an earlier phase's narrative. Each phase narrative should only cover its defined timespan
>
> **3B. Pattern validation (for each pattern from Phase 1-2):**
>
> 1. **Conceptual accuracy**: Is each pattern a description of a _situation_ (conditions the person was in), or is it actually a _fact/event_ (something that happened) or _product experience_ (what happened after using a product)?
>    - NG: "Filled the position in 5 minutes" → product experience, not a situation
>    - OK: "Traditional channels produced zero applicants for months" → situation
> 2. **Theoretical consistency**: Does each pattern describe a condition that is meaningfully connected to the behaviors observed in this phase?
> 3. **Category assignment**: For each pattern, classify as:
>    - **Situation**: Objective condition observable by a third party
>    - **Stance**: The person's attitude/approach arising from a Situation. Always note which Situation item it derives from
>    - And assign to the appropriate **Phase** (P1, P2, ...)
>    - Classification test: "Could a third party observe this as an objective condition?" → Yes = Situation, No = Stance
> 4. **Redundancy**: Are any patterns listed independently that are actually sub-dimensions of another? Recommend merging or subordinating.
> 5. **Phase assignment**: Are any patterns assigned to the wrong phase? Apply: "At which phase's timespan was this condition first observable?"
> 6. **Evidence strength**: Is each case's evidence based on recorded behavior/quotes, or merely a stated attitude? Flag weak evidence in Discrepancies.
> 7. **Pattern nature**: Is each entry a "common pattern" (shared across cases) or a "difference description" (contrasting cases)? Differences belong in Discrepancies, not as standalone patterns.
> 8. **Functional bias check**: Are any patterns presented as purely functional (operational efficiency, cost, speed) that also contain emotional signals (relief, security, liberation from worry) or social signals (identity, peer perception) in the original verbatim quotes? If so, note the emotional/social dimension and recommend whether it should be a separate pattern or an annotation.
> 9. **Frame blindness check**: Compare the patterns you extracted in Phase 1-2 against the Frame Awareness section. Specifically:
>    - Are there facts in the Fact Tables that do NOT appear in ANY pattern? These omissions may indicate RQ-driven blind spots
>    - Do the Purpose entries reveal dynamics not anticipated by the RQ? If so, flag as HIGH PRIORITY
>
> Additionally: identify any common patterns the comparison missed, based on your independent reading of the Facts.
>
> **3C. Completeness verification (CRITICAL):**
>
> Compare the Phase 1 Inventory against the Phase 1-2 comparison output:
>
> - For each item in the Inventory, verify it appears in at least one common pattern OR is explicitly noted as case-specific
> - List any Inventory items that were NOT reflected in any comparison dimension
> - For each missing item: determine whether it should become a new pattern, be merged into an existing pattern, or be explicitly excluded with stated reason
> - **Items that appear in 2+ cases' inventories but are absent from the comparison output are HIGH PRIORITY gaps**
>
> ---
>
> **Output structure:**
>
> 1. Inventory tables per phase (from Phase 1-2)
> 2. Per-phase cross-case comparison tables: `| Dimension | Case A | Case B | Case C | Common pattern (tentative) | Notes |`
> 3. Purpose divergence summary: How Purpose entries change across phases, where cases diverge
> 4. Validation report (Phase 3B): For each pattern → Approve / Revise (with suggestion) / Reject (with reason) + Phase assignment + Layer (Situation/Stance) classification
> 5. Completeness gap report (Phase 3C): List of inventory items not reflected in patterns, with disposition
> 6. Additional proposals: Patterns the comparison missed, identified from independent Fact Table reading
>
> Do NOT write the final integrated version yourself — provide comparison tables, validation verdicts, and gap reports only.
> Do NOT include file paths, plan references, or any external file references in your output — your entire output will be written to a temporary analysis file and must be fully self-contained.
