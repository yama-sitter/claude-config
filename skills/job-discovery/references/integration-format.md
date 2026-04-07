# Step 3c Integration Rules and Output Format

After receiving the Analyst-Critic's output, integrate in the main conversation following these steps:

## Integration Steps

1. Review the Analyst-Critic's completeness gap report first: incorporate any HIGH PRIORITY gaps as new patterns
2. Reflect the Analyst-Critic's validation report: apply revisions, remove rejected patterns, add proposed patterns
3. Apply Phase × Layer (Situation/Stance) classification
4. Compose the final tables per phase (including Purpose comparison tables — see output format below)
5. Write a **causal chain** connecting patterns across phases
6. **Causal chain self-verification**: After composing the causal chain, verify: (a) every pattern (P\*-S\*, P\*-St\*) participates in at least one chain, (b) each arrow's causal claim is supported by Fact Table evidence, (c) any isolated pattern (belongs to no chain) is truly independent or should be merged, (d) **RQ-direction check**: if the causal chain follows the RQ's assumed phase progression exactly, verify this structure is grounded in cross-case data (not merely inherited from phase definitions). Check Narrator out-of-phase signals and Analyst-Critic Purpose divergence for evidence of alternative causal structures

## Rules

**Baseline conditions**: Conditions that persist unchanged across all phases (structural affordances, business characteristics) should be placed in Phase 1 as baseline conditions. They do not require a change tag in later phases unless they become relevant to a phase-specific pattern.

**Pattern descriptions must be observational only**: Describe what a third party could observe. Do NOT add interpretive conclusions (causes, effects, evaluations, significance). Interpretation belongs in the causal chain, not in the table.

- NG: "〜が脅かされている", "〜が確認される", "〜転換点となる", "〜コストが低下する"
- OK: "〜が発生している", "〜を上回っている", "〜が確立している", "〜が使われている"

**Change tags** (for Phase 2+ patterns):

- **Continued**: This pattern existed in the previous phase and remains essentially the same
- **Changed**: This pattern existed in the previous phase but its content or intensity has shifted
- **New**: This pattern first appeared in this phase

## Output Format

> Apply Anchor formatting from report-template.md: definition sites use `<span id="ID">ID</span>`, reference sites use `[ID](#ID)`.
>
> ### フェーズ1: [phase name]
>
> #### 共通状況
>
> | P1-S# | パターン | 3社での現れ方 | 出典 |
> | <span id="P1-S1">P1-S1</span> | ... | ... | [A3](#A3)-[A5](#A5), [B7](#B7) |
>
> #### 共通の構え
>
> | P1-St# | 構え | 由来する状況 | 出典 |
> | <span id="P1-St1">P1-St1</span> | ... | [P1-S1](#P1-S1) | [A6](#A6), [B4](#B4) |
>
> ### フェーズ2: [phase name]
>
> #### 共通状況
>
> | P2-S# | 変化タグ | パターン | 3社での現れ方 | 出典 |
> | <span id="P2-S1">P2-S1</span> | 新規 | ... | ... | [A14](#A14), [B18](#B18) |
>
> (変化タグ: 継続 / 変化 / 新規)
>
> #### 共通の構え
>
> | P2-St# | 変化タグ | 構え | 由来する状況 | 出典 |
> | <span id="P2-St1">P2-St1</span> | 変化 | ... | [P2-S1](#P2-S1) × [P1-St2](#P1-St2) | [A16](#A16), [B15](#B15) |
>
> _(Repeat for each additional phase)_
>
> ### Purpose（顧客が明示した利用目的）
>
> Per-phase Purpose comparison table:
>
> > | Case | 明示された目的 | 出典 |
> >
> > **Purpose divergence**: [分岐の要約]
>
> ### 因果チェーン
>
> Describe the causal relationships between patterns using the following notation. All pattern references in the causal chain must be linked: `[P1-S1](#P1-S1)（description）→ [P1-St1](#P1-St1)（description）`
>
> - `→`: A situation/stance generates another stance
> - `×`: Multiple conditions combine to produce a stance
> - `※`: Annotate a pattern's analytical role (前提条件 = precondition that made this solution viable / 促進条件 = accelerant that enabled quick action)
> - Use block headings to label demand structure phases (e.g., Hire需要の形成 / 体験による需要構造の変化 / Re-hire需要の構造)
- If Narrator out-of-phase signals were validated by the Analyst-Critic, annotate them in the causal chain with `※ フェーズ外:` prefix
> - For Purpose divergence: Include a 1-line summary in the relevant block heading (e.g., "Purpose divergence: A=量的確保, B=スカウト+休息, C=休息+拡張"). Single-case purposes that were not promoted to P*-S* should be noted as `※ Purpose [Case]: [description] (1ケースのみ)` — carry forward as an [Emerging] signal for Step 5
>
> Every pattern must participate in at least one chain. If a pattern is isolated (belongs to no chain), reconsider whether it is truly independent or should be merged.
>
> **Note**: The Narrator's Purpose entries and Analyst-Critic's Purpose divergence analysis are intermediate artifacts that inform the Purpose comparison table and causal chain. Purposes that are common across 2+ cases should be promoted to P*-S* patterns. Single-case purposes are captured in the causal chain annotations.
