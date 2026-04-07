# Step 3c Integration Rules and Output Format

After receiving the Analyst-Critic's output, integrate in the main conversation following these steps:

## Integration Steps

1. Review the Analyst-Critic's completeness gap report first: incorporate any HIGH PRIORITY gaps as new patterns
2. Reflect the Analyst-Critic's validation report: apply revisions, remove rejected patterns, add proposed patterns
3. Apply Phase × Layer (Situation/Stance) classification
4. Compose the final tables per phase (including Purpose comparison tables — see output format below)
5. Write a **causal chain** connecting patterns across phases
6. **Causal chain self-verification**: After composing the causal chain, verify: (a) every pattern (P\*-S\*, P\*-St\*) participates in at least one chain, (b) each arrow's causal claim is supported by Fact Table evidence, (c) any isolated pattern (belongs to no chain) is truly independent or should be merged

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

> ### フェーズ1: [phase name]
>
> #### 共通状況
>
> | P1-S# | パターン | 3社での現れ方 | 出典 |
>
> #### 共通の構え
>
> | P1-St# | 構え | 由来する状況 | 出典 |
>
> ### フェーズ2: [phase name]
>
> #### 共通状況
>
> | P2-S# | 変化タグ | パターン | 3社での現れ方 | 出典 |
>
> (変化タグ: 継続 / 変化 / 新規)
>
> #### 共通の構え
>
> | P2-St# | 変化タグ | 構え | 由来する状況 | 出典 |
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
> Describe the causal relationships between patterns using the following notation:
>
> - `→`: A situation/stance generates another stance
> - `×`: Multiple conditions combine to produce a stance
> - `※`: Annotate a pattern's analytical role (前提条件 = precondition that made this solution viable / 促進条件 = accelerant that enabled quick action)
> - Use block headings to label demand structure phases (e.g., Hire需要の形成 / 体験による需要構造の変化 / Re-hire需要の構造)
- If Narrator out-of-phase signals were validated by the Analyst-Critic, annotate them in the causal chain with `※ フェーズ外:` prefix
> - For Purpose divergence: Include a 1-line summary in the relevant block heading (e.g., "Purpose divergence: A=量的確保, B=スカウト+休息, C=休息+拡張"). Single-case purposes that were not promoted to P*-S* should be noted as `※ Purpose [Case]: [description] (1ケースのみ。[Emerging]信号としてStep 5に渡す)`
>
> Every pattern must participate in at least one chain. If a pattern is isolated (belongs to no chain), reconsider whether it is truly independent or should be merged.
>
> **Note**: The Narrator's Purpose entries and Analyst-Critic's Purpose divergence analysis are intermediate artifacts that inform the Purpose comparison table and causal chain. Purposes that are common across 2+ cases should be promoted to P*-S* patterns. Single-case purposes are captured in the causal chain annotations.
