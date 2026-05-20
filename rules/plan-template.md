# Plan Template

## When

Use this template when writing plans in Plan Mode.

## Writing Style

- Use concrete, specific language. No vague expressions
- One idea per sentence. Keep sentences short
- State what you will do, not what you will "consider" or "handle appropriately"

Prohibited expressions and their replacements:

```
❌ "既存のインターフェースとの整合性を考慮した上で、適切なエラーハンドリングを実装する"
✅ "getUserById が null を返したら 404 を返す。例外は投げない"

❌ "パフォーマンスを意識した効率的なデータ取得を行う"
✅ "N+1 を避けるため、JOIN で1回のクエリにまとめる"

❌ "堅牢なバリデーションロジックを導入する"
✅ "name は空文字禁止、email は @ を含むことを確認する。不正なら 400 を返す"
```

## Required Sections

### 1. Goal

What this plan achieves. 1-3 lines. Separate from Context (why) — Goal defines the target state.

### 2. Context

Why this change is needed — the problem, what prompted it, and the intended outcome.

### 3. Approach

How the goal will be achieved. Summarize the strategy so that the reader understands "what will be done" without reading the full change list.

Use a table when there are multiple components to the approach. Column headers should fit the content (e.g., Layer/Phase/Step | Target | Description).

Optional sub-item: "Conditions for this plan to hold" — include only when preconditions are non-obvious (e.g., specific version dependency, another team's work must be completed first).

### 4. Changes

#### Summary table

| Operation            | File           | What changes    | Why                    |
| -------------------- | -------------- | --------------- | ---------------------- |
| Create/Modify/Delete | `path/to/file` | Specific change | Reason for this change |

#### Affected surrounding areas

| File           | Impact                                                         |
| -------------- | -------------------------------------------------------------- |
| `path/to/file` | How this file is affected (no change needed, but worth noting) |

#### Not changing

| Target              | Reason                   |
| ------------------- | ------------------------ |
| `component/feature` | Why this is out of scope |

### 5. Verification

Define acceptance criteria as a table. A separate evaluator (`/verify`) uses this table to confirm the implementation.

| #   | Criterion        | Command                 | Expected                  |
| --- | ---------------- | ----------------------- | ------------------------- |
| 1   | [What to verify] | `[command]` or `Manual` | [What success looks like] |

- At least 2 criteria required, at least 1 must have an automated command
- Commands must be runnable from the project root
- Expected results must be concrete enough for an independent evaluator to judge pass/fail

### 6. Risks and Mitigations (table, optional)

| Risk                | Mitigation        |
| ------------------- | ----------------- |
| What could go wrong | How to address it |

Omit this section if there are no meaningful risks.

#### Failure Pattern Self-Check

Before finalizing Risks, check whether the design matches any of these common failure patterns. If a concern applies, transfer it to the Risks table above.

- **早すぎる抽象化**: Is abstraction being introduced when only one use case exists?
- **制約の後付け**: Are known constraints already baked into the Approach?
- **隣を見ない再実装**: Have you verified no equivalent exists in adjacent code or dependencies?
- **見切り発車**: Are you proceeding to implementation while high-uncertainty assumptions remain?
- **砂上の依存**: Are you relying on dependencies whose reliability is unverified?
- **牛刀をもって鶏を割く**: Is the tooling overkill for the problem scale?

Full pattern list and the 8 evaluation axes: `docs/design-decision-guide.md`

### 7. Investigation Scope

#### Files read

| File           | Description                           |
| -------------- | ------------------------------------- |
| `path/to/file` | What this file is and why it was read |

#### Files not read but potentially affected

| File           | Potential impact         | Action needed | Reason                        |
| -------------- | ------------------------ | ------------- | ----------------------------- |
| `path/to/file` | How it might be affected | Yes/No        | Why action is or isn't needed |

- Catch-all entries ("other files", "remaining modules", etc.) are prohibited. List specific file paths

### 8. Change Details

Detailed breakdown per file: specific changes, reference patterns, and ordering constraints (only when order matters).

This section supplements the summary table. Place it after Investigation Scope to keep the main plan scannable.

## Self-Containment Rule

- NEVER reference a research/analysis/test-plan custom ID (e.g. `U\d+`, `S-?\d+`, `RQ\d+`, `X-?\d+`, `i-?\d+`, `Y-?\w+`) without including its body text in the same plan file. Reason: the plan file must be independently understandable after the originating conversation is compacted or lost.
  - Bad: "観点 A 対応 Unknown: U11, U13, U14, U15" (本文なし)
  - Good: 同じ plan file 内に「## Unknowns」セクションを設け、U11/U13/U14/U15 の本文を列挙
- ALWAYS expand all such ID references inline before saving the plan to agent-memory. Reason: agent-memory 経由保存後は会話履歴を参照できない。

### Out of scope

- Code identifiers (e.g. function names like `useFoo`, class names like `Builder`)
- File paths (e.g. `src/features/...`)
- External IDs (e.g. Notion ID, GitHub issue number, Linear ticket) — cite URL alongside instead

## Scaling

- 3 or fewer files changed AND following existing patterns → Context, Summary table, and Verification only. Other sections may be omitted
- All other cases → all sections required
