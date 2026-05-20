# Target Routing

Subagent reference for choosing the implementation target after a comment has been classified into C1-C8 by `feedback-taxonomy.md`. Mirrors `~/.claude/skills/kaizen/references/harness-catalog.md` §3 (Failure Pattern → Target Mapping) but specialized to review-feedback inputs.

## Mapping table

| Category | Target                                         | Path / location                                                                                                                      | Rationale                                                        |
| -------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------- |
| C1       | rules (merge) or CLAUDE.md                     | `~/.claude/rules/<topic>.md` if a matching file exists, else project `CLAUDE.md`. Never a brand-new rules file from a single insight | harness-catalog §3 "Repeated judgment errors → rules/"           |
| C2       | agent-memory insight                           | `~/.agent-memory/<repo>/<YYYY-MM-DD>_pr-<n>-feedback/c2-<slug>.md`                                                                   | harness-catalog §3 "Cross-session knowledge loss → agent-memory" |
| C3       | agent-memory insight                           | `~/.agent-memory/<repo>/<YYYY-MM-DD>_pr-<n>-feedback/c3-<slug>.md`                                                                   | Time-bound; rules want timeless statements                       |
| C4       | agent-memory insight only                      | `~/.agent-memory/<repo>/<YYYY-MM-DD>_pr-<n>-feedback/c4-<slug>.md`                                                                   | Over-generalization risk; never auto-promote to rules            |
| C5       | none (advisory only)                           | Print to user in the analysis report; no file write                                                                                  | Harness cannot enforce cross-PR coordination                     |
| C6       | depends on detectability (see flowchart below) | varies                                                                                                                               | Use harness-catalog §1 Target Selection Flow                     |
| C7       | none (skip)                                    | Count in summary                                                                                                                     | Self-classified trivial                                          |
| C8       | none (skip)                                    | One-line digest in summary if a reply resolved it                                                                                    | Discussion, not change                                           |

## Topic directory layout

One PR produces one topic directory. Insights live as siblings inside it:

```
~/.agent-memory/<repo>/<YYYY-MM-DD>_pr-<n>-feedback/
├── plan.md                # diagnose/plan output, apply input
├── summary.md             # index over the insights in this directory
├── c2-url-design-background.md
├── c2-ob-og-screen-distinction.md
├── c3-dual-handling-merge-pr-4.md
└── c4-shallow-routing-simplification.md
```

`<slug>` is kebab-case derived from the comment subject (drop articles, max 5 words, ASCII-only). Each file is a single topic — the `agent-memory` rule "one topic per file" still holds because the _directory_ groups by PR while each file inside it is independent.

## C6 (bug) routing — follow harness-catalog flowchart

For bugs, defer to `~/.claude/skills/kaizen/references/harness-catalog.md` §1 verbatim:

```
Can this failure be deterministically blocked/verified?
  → Yes → hooks
  → No → Should the operation be physically prohibited?
        → Yes → permissions
        → No → Is process structuring needed?
              → Yes → skills
              → No → Global? → rules/ ; Project-specific? → CLAUDE.md
```

A reviewer-reported bug normally lands as either a hook (when lint or a shell test can detect the pattern) or an agent-memory note + manual fix (when the bug is one-off).

## Merge decision for C1

Before creating a new file under `~/.claude/rules/`, run this check. The default bias is to **not** create a new rules file. Only the explicit merge-or-promote paths produce a rules write.

1. **Exact topic match exists.** If `~/.claude/rules/<topic>.md` already exists with the same kebab-case topic name → merge the new line into it. Done.
2. **Same-shape rule exists.** Grep existing rules for a regex matching the new rule's forbid/suggest pair (e.g. existing rule already forbids `map().filter()` and suggests `flatMap`) → merge as an additional example bullet. Done.
3. **Neither matches.** Do **not** create a new rules file. Save the insight to agent-memory as if it were C2 (use `c1-pending-<slug>.md` so the promotion candidate is greppable). Surface to the user only after **three** independent agent-memory insights with the same shape have accumulated; at that point propose promoting them into a single new rules file with all three as examples.

The 3-strike threshold is a guardrail against one PR's stylistic complaint becoming a global rule. The reviewer's voice matters, but a sample size of 1 is not enough signal to commit a global instruction.

## CLAUDE.md fallback

When step 3 of the merge decision applies but the rule is **project-specific** (mentions a path under `src/features/`, a Next.js / Tailwind / pnpm-specific behavior, or a project-internal naming convention), bypass the agent-memory holding pen and propose writing it into the project's own `CLAUDE.md` instead of `~/.claude/rules/`. Reason: harness-catalog §2 — project-specific instructions belong in `CLAUDE.md`, global ones in `rules/`.

Detection heuristic: if the comment cites a path that exists in the _current_ repo but not in `~/.claude/`, treat it as project-specific.

## Idempotency contract

Every write target on this page must support being skipped if the insight has already been applied. The `apply` subcommand reads each insight's `Status` cell in `plan.md`:

- `Status: applied` → skip this insight, do not re-write
- `Status: proposed` → write; on success flip to `applied` and set `applied_at: <date>` on the file's frontmatter where applicable

The implementing subagent must therefore treat "already exists with the same content" as success, not as a conflict.

## Out of scope for this skill

- Pushing commits or PRs (use `/kaizen commit` to land the harness changes; this skill never invokes `git push`)
- Modifying `~/.claude/settings.json` (hooks landed via C6 are written by the subagent as a _suggestion patch_, not auto-applied)
- Cross-PR aggregation across separate runs. Each run acts only on the current PR's plan. Past insights for other PRs remain in agent-memory and can be browsed with `/agent-memory search` directly when needed.
