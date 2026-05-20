---
name: pr-feedback-kaizen
description: |
  Convert PR review feedback into systemic harness improvements and persistent learning.
  Use when: A PR has merged with non-trivial review comments that should not recur.
  Invoke with `/pr-feedback-kaizen <pr-url>` (URL only, not PR number).
  Do not use when:
    - Live failure analysis in current conversation (use /kaizen)
    - Single-shot rule registration from explicit user instruction (use /hookify)
    - Open PR with unresolved reviews (resolve first, then run)
  Subcommands (mirror /kaizen):
    - (default) `<pr-url>`: Run diagnose -> save plan -> apply in the same session (shortcut)
    - `diagnose <pr-url>`: Fetch and classify only. Print analysis report. No file writes.
    - `plan <pr-url>`: Run diagnose then persist analysis to `~/.agent-memory/<repo>/<date>_pr-<n>-feedback/plan.md`. Returns the path for later `apply`.
    - `apply <plan-md-path>`: Read the saved plan.md, present analysis-report, get approval, implement insights, then save each as agent-memory entries. Idempotent: skips insights whose status is already `applied`.
    - `commit`: Commit pending harness changes (under `~/.claude/`) to the claude-config repository. Delegates to `/kaizen commit` since the commit logic is identical.
user-invocable: true
---

# PR Feedback Kaizen

Capture PR review feedback as durable learning instead of letting the same pattern of comments recur. The skill mirrors `/kaizen` in interface (`diagnose` / `plan` / `apply`) but takes its input from external reviewers via `gh` CLI rather than the current conversation.

## Differentiation

- `/kaizen` — derives improvements from failures inside the current conversation
- `/hookify` — turns explicit user instructions into immediate hook-based blocks
- `/pr-feedback-kaizen` (this) — turns reviewer comments on a merged PR into harness changes (rules / CLAUDE.md / hooks / agent-memory)

## Phases

| Phase                  | Driver                       | Action                                                                                                                                                                                                                                                                                                                                                                                |
| ---------------------- | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1. Fetch               | main                         | Run `gh auth status` first; fail fast on auth error. Then collect both `gh api repos/<o>/<r>/pulls/<n>/comments` (inline review comments) and `gh pr view <n> --comments` (issue-level discussion). Also pull `gh pr view <n> --json title,body,baseRefName,headRefName,files` for metadata. Structure all comments into a single list with author / body / file / line / URL fields. |
| 2. Classify & Generate | subagent (`general-purpose`) | The subagent reads `references/feedback-taxonomy.md`, `references/target-routing.md`, and `~/.claude/skills/kaizen/references/harness-catalog.md` §3 (Failure Pattern → Target Mapping). For each comment it picks one of C1-C8 using the deterministic priority order `C7 → C8 → C5 → C3 → C2 → C6 → C1 → C4` (first match wins), then proposes a concrete implementation target.    |
| 2.5. Plan Save         | main                         | At the end of `diagnose` and as a checkpoint inside `(default)`, write the analysis to `~/.agent-memory/<repo>/<date>_pr-<n>-feedback/plan.md` using `templates/plan-record.md` shape. This is the entry point for a later `apply`.                                                                                                                                                   |
| 3. Approval            | main                         | Inside `apply`, re-read `plan.md`, render `templates/analysis-report.md` and gate with `AskUserQuestion (multiSelect)`. Default selection covers every non-skipped insight.                                                                                                                                                                                                           |
| 4. Implement           | subagent (`general-purpose`) | The subagent implements only approved insights. For C1 it merges into existing rules when topic names match (see `references/target-routing.md`). For C2/C3/C4 it writes new insight files under the topic directory. For C6 it consults the harness-catalog §1 flowchart.                                                                                                            |
| 5. Record              | main                         | Save each insight via `agent-memory save` (delegated to a `general-purpose` subagent per the agent-memory skill contract). Write a `summary.md` index inside the topic directory. Update `plan.md` with `status: applied` and `applied_at: <date>`, and flip per-insight `Status` cells to `applied` so re-running `apply` is a no-op.                                                |

## Inputs and outputs

- Input: A single PR URL such as `https://github.com/<owner>/<repo>/pull/<n>`. Bare numbers are rejected.
- Output directory: `~/.agent-memory/<repo>/<YYYY-MM-DD>_pr-<n>-feedback/` containing `plan.md`, `summary.md`, and per-insight files (`c2-<slug>.md`, `c3-<slug>.md`, `c4-<slug>.md`, …). C1 outputs land in `~/.claude/rules/<topic>.md` or the project `CLAUDE.md`.
- agent-memory frontmatter follows the contract in `~/.claude/skills/agent-memory/SKILL.md`. Do not add custom top-level fields; put any extra references inside the `related:` list.

## Citation discipline

When transcribing a reviewer comment into rules or CLAUDE.md, follow `~/.claude/rules/citation-discipline.md`. If the exact substring + locator cannot be re-grepped from the gh output captured in this session, downgrade to a paraphrase and put the comment URL in `related:`. Never invent a "verbatim quote" that was not re-verified in the current run.

## Sensitive information

If a comment cites an internal URL (Notion, internal wiki, social-engineered domain), the rule transcribed into `~/.claude/rules/` must abstract the URL as "internal spec reference" and keep the actual URL only in `related:` inside agent-memory (gitignored). The detection rule is fixed in `references/feedback-taxonomy.md`.

## Skipped categories

C7 (nits / typos) and C8 (questions / unresolved discussion) are fetched but not turned into changes. They appear as counts in the analysis report. This satisfies the "analyze all feedback" requirement while keeping the implementation focused on actionable patterns.

## Failure modes (operator-facing)

- `gh auth status` fails → Stop. Tell the user to authenticate; do not fall back to local data.
- `~/.claude/skills/kaizen/references/harness-catalog.md` missing → Stop. The catalog is the routing source of truth; do not improvise.
- Classification produces a category that is not C1-C8 → Treat as a taxonomy bug. Print the offending comment and the chosen label, ask the user to update `feedback-taxonomy.md`, do not write anything.
- `apply` invoked on a plan with `status: applied` → Re-display the report and exit without writes (idempotent).

## Commit and cleanup

`commit` subcommand delegates to `/kaizen commit`. The two skills share the same target (the claude-config repository at `~/.claude/`), so the commit logic is not duplicated. `apply` itself never commits — the user runs `commit` separately after reviewing the diff. The agent-memory directory under `~/.agent-memory/` is gitignored and stays local; it is not touched by `commit`.
