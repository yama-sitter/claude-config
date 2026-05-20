# Feedback Taxonomy

Subagent reference for classifying PR review comments into one of 8 categories (C1-C8). Used by the Classify phase of `/pr-feedback-kaizen`.

## Decision order (first match wins)

Walk the comment text through these checks in order. Stop at the first match. Do not try to optimize for "best fit" — the order encodes the priority.

```
C7 nit / typo
  → C8 question / unresolved discussion
    → C5 team coordination
      → C3 policy / decision record
        → C2 domain knowledge
          → C6 bug
            → C1 codifiable rule
              → C4 design judgment (catch-all for substantive comments)
```

The catch-all is C4, not "Unknown". A comment that reached the bottom of the cascade is a context-bound design call.

## Category definitions

### C1 — Codifiable rule

Comments expressible as a one-liner of the form "always do X" / "never do Y" with a concrete code example. Routable to `~/.claude/rules/` or project `CLAUDE.md`.

Trigger phrases (case-insensitive):

- `should be` / `must be` / `please use X instead of Y`
- `consistent with` / `same shape as` / `align with the other`
- `prefer X over Y` / `replace X with Y`
- mentions a specific lint-able pattern: `flatMap`, `map().filter()`, `useCallback`, function signature shapes, naming patterns

Sniff test: if you can write the rule as `forbid: <pattern>; suggest: <replacement>` it is C1.

PR #6573 examples:

- "`new()` と同じく `option` オブジェクトに統一" → C1 (API consistency rule)
- "フォルダ構造を反映した別名を検討" → C1 (naming rule)
- "`.map(...).filter()` → `.flatMap(...)`" → C1 (style rule)

### C2 — Domain knowledge

Comments that require external context (specs, business rules, screen distinctions) the codebase alone does not encode. Goes to `~/.agent-memory/` so future Claude can look it up on demand without bloating the always-loaded prompt.

Trigger phrases:

- references an internal URL (Notion, internal wiki, design doc)
- mentions an OB/OG / 常用 / 特例 distinction
- explains _why_ a URL / parameter / flow exists

Sniff test: if a new engineer would need to read a doc to evaluate the comment, it is C2.

PR #6573 examples:

- "URL 設計の背景説明（Notion 参照を促す）" → C2
- "OB/OG 画面と通常画面の実装の区別" → C2

### C3 — Policy / decision record

Comments that pin down a _time-bound_ decision: "for now we do X, will unify in PR Z" or "this is the agreed approach until <event>". Goes to agent-memory because rules want timeless statements and these decisions will be revisited.

Trigger phrases:

- `for now` / `until` / `tracked in <PR/issue>` / `will be unified in`
- `TODO` / `FIXME` references in the comment

PR #6573 examples:

- "dual handling は PR 4 で統合予定" → C3

### C4 — Design judgment

Substantive feedback that is not codifiable as a simple rule and not just domain knowledge — a context-dependent design call. Goes to agent-memory only. **Never** auto-promoted to rules; a single instance does not justify a global rule (over-generalization risk).

Trigger phrases:

- proposes a different decomposition (`extract`, `inline`, `move into`)
- discusses trade-offs of two approaches without declaring a universal winner
- mentions readability / simplicity / minimality as the rationale rather than a hard convention

PR #6573 examples:

- "shallow routing のロジック簡潔化（`delete nextQuery.confirm` で済む）" → C4

### C5 — Team coordination

Comments that ask the author to talk to someone, watch another PR, or sync with a stakeholder. Not implementable as harness changes. Surfaced to the user as advisory, not stored.

Trigger phrases:

- `cc @<user>` / `@<user> please look`
- mentions another PR number with `competing`, `will conflict`, `coordinate`, `merge order`

PR #6573 examples:

- "#6580 との競合予測。取り込み内容の確認" → C5

### C6 — Bug

Comments pointing out a code defect: wrong condition, missing case, off-by-one, leaked promise, etc. Routing follows the harness-catalog flowchart: deterministically detectable → hooks; pattern-detectable in lint → rules; otherwise → agent-memory note + manual follow-up.

Trigger phrases:

- `this throws` / `this returns undefined` / `crash` / `null` / `race condition`
- `does not handle` / `missing case` / `off-by-one`

PR #6573 examples: none. (The PR's substantive comments are all design / quality / knowledge.)

### C7 — Nit / typo

Self-labeled trivial comments. Skipped from implementation; counted in the summary.

Trigger:

- comment body starts with one of (case-insensitive): `nit:`, `nits:`, `typo:`, `minor:`, `ultra-nit:`, `super-nit:`, `nitpick:`
- comment body is a single-character or whitespace-only change request (e.g. fix a stray comma)

If `nit:` is followed by a substantive multi-paragraph argument, treat as nit anyway — the reviewer self-classified it.

### C8 — Question / unresolved discussion

The comment asks a question rather than requests a change. Skipped from implementation; counted in the summary. For merged PRs the answer is typically in the thread reply, so surface a one-line digest of the reply if present.

Trigger:

- comment body ends with `?`
- comment is a top-level discussion that received `+1` / agreement reactions rather than a code change
- comment starts with `Question:` / `q:` / `❓`

## Conflicts and edge cases

- **Reply chains**: only classify the _original_ comment. Replies that quote the parent then add a tiny correction (typo style) do not promote the parent to C7.
- **Multiple sentences, multiple categories**: split into the strongest single category by the decision order above. Do not produce two insights from one comment.
- **Bot comments** (`coderabbitai`, `dependabot[bot]`, `github-actions[bot]`): include them. Treat exactly the same as a human comment — the rules above apply to the _text_, not the author.

## Sensitive-information detection

When the comment body contains any of the following, do **not** transcribe the URL or proper noun into `~/.claude/rules/` or any file that ships with the claude-config repo. Keep it only in agent-memory `related:` and replace it in rule text with the literal string `internal spec reference`:

- Hostnames matching `*.notion.so`, `*.atlassian.net`, `*.slack.com`, `*.coda.io`, `*.confluence.com`, `*.lark*`, `*.kibe.la`, `*.docbase.io`
- Internal-looking subdomains: anything under `*.<company>.internal`, `*.<company>.local`, or matching the host of the repository's organization domain (resolve from `gh repo view --json owner` if needed)
- Personal names that appear nowhere in `gh pr view --json author,assignees,reviewRequests` — these are likely external stakeholders

The same applies to file paths under `secret`, `credential`, or `*.env*` even if quoted in a comment.

## Golden set — PR #6573

Acceptance check for taxonomy changes. After editing this file, the diagnose run on `https://github.com/Taimee/timee-client-web/pull/6573` must produce exactly this mapping. Any deviation is a taxonomy bug.

| #   | Subject (one-liner)                       | Expected | Rationale                                           |
| --- | ----------------------------------------- | -------- | --------------------------------------------------- |
| 1   | URL 設計の背景説明（Notion 参照を促す）   | C2       | references external spec → domain knowledge         |
| 2   | OB/OG 画面と通常画面の実装の区別          | C2       | requires business-rule context                      |
| 3   | dual handling は PR 4 で統合予定          | C3       | time-bound decision record                          |
| 4   | shallow routing のロジック簡潔化          | C4       | readability-driven design call, no general rule     |
| 5   | `confirmMode()` を option 引数に統一      | C1       | "consistent with new()" — codifiable signature rule |
| 6   | `useMultipleWorkDates` フック名の重複回避 | C1       | naming-convention rule                              |
| 7   | `.map().filter()` → `.flatMap()`          | C1       | lintable style rule                                 |
| 8   | #6580 との競合予測                        | C5       | coordination ask, no harness change                 |

If a single row of this table disagrees with the subagent output, the taxonomy or the prompt is wrong, not the reviewer.
