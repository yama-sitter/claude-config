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

| Operation | File | What changes | Why |
|---|---|---|---|
| Create/Modify/Delete | `path/to/file` | Specific change | Reason for this change |

#### Affected surrounding areas

| File | Impact |
|------|--------|
| `path/to/file` | How this file is affected (no change needed, but worth noting) |

#### Not changing

| Target | Reason |
|--------|--------|
| `component/feature` | Why this is out of scope |

### 5. Verification

Define acceptance criteria as a table. A separate evaluator (`/verify`) uses this table to confirm the implementation.

| # | Criterion | Command | Expected |
|---|-----------|---------|----------|
| 1 | [What to verify] | `[command]` or `Manual` | [What success looks like] |

- At least 2 criteria required, at least 1 must have an automated command
- Commands must be runnable from the project root
- Expected results must be concrete enough for an independent evaluator to judge pass/fail

### 6. Risks and Mitigations (table, optional)

| Risk | Mitigation |
|------|------------|
| What could go wrong | How to address it |

Omit this section if there are no meaningful risks.

### 7. Investigation Scope

#### Files read

| File | Description |
|------|-------------|
| `path/to/file` | What this file is and why it was read |

#### Files not read but potentially affected

| File | Potential impact | Action needed | Reason |
|------|-----------------|---------------|--------|
| `path/to/file` | How it might be affected | Yes/No | Why action is or isn't needed |

- Catch-all entries ("other files", "remaining modules", etc.) are prohibited. List specific file paths

### 8. Change Details

Detailed breakdown per file: specific changes, reference patterns, and ordering constraints (only when order matters).

This section supplements the summary table. Place it after Investigation Scope to keep the main plan scannable.

## Scaling

- 3 or fewer files changed AND following existing patterns → Context, Summary table, and Verification only. Other sections may be omitted
- All other cases → all sections required
