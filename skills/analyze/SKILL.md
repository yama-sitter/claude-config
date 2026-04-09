---
name: analyze
description: |
  Support data-driven decision-making through interactive dialogue.
  Use `/analyze start [topic]` to begin a new analysis session.
  Use `/analyze [question]` to continue analysis (delegates to subagent for clean context).
  Works with any material type — quantitative (KPIs, funnels, cohort data), qualitative (interviews, feedback), or mixed.
  Accepts materials at any stage — raw data, organized observations, existing interpretations, or decision options.
  Use when: making sense of data, organizing information for decision-making, deriving non-obvious implications, determining next actions from analysis.
  Do not use when: uncovering hidden human motives (→ insight-craft), extracting JTBD from customer behavior (→ job-discovery), designing experiments from hypotheses (→ experiment-discipline), designing research plans or interview guides (→ research).
user-invocable: true
args: "[args]"
---

# Analyze — Interactive Analysis Partner

An interactive dialogue partner that helps make sense of quantitative and qualitative data. Each `/analyze` invocation delegates to a subagent with a clean context, using a state file as the single source of truth. This prevents context pollution from degrading analysis quality over long rallies.

## Argument Routing

| Args | Action |
|---|---|
| `start [topic]` | → **Start** workflow |
| `[question]` (any text that is not `start`) | → **Continue** workflow (delegate to subagent) |
| (none) | If active session exists: show status + "Use `/analyze [question]` to continue". If not: show usage guide |

## Prerequisites

- The user has data, information, or analysis results to work with
- The goal is to derive implications, make a decision, or determine next steps
- This skill is NOT a replacement for insight-craft (hidden motives), job-discovery (JTBD), or experiment-discipline (hypothesis testing)

## Strict Rules

- Read materials before acting — when materials are provided, read and understand them before starting analysis. Never ask questions or start analysis without reading the materials first
- Separate fact from interpretation — always distinguish "what the data shows" from "what can be interpreted from it"
- Show evidence — every implication or action proposal must include "why this can be said." Never propose without evidence
- Acknowledge uncertainty — when data is insufficient for a conclusion, say so explicitly: "this judgment requires X, which is missing"
- Act on best judgment — choose and execute the most appropriate analytical approach. Only present alternative directions when the user signals disagreement

## Anti-patterns

- **Asserting beyond data**: Do not assert conclusions the materials do not support
- **Pushing frameworks**: Do not introduce MECE, SWOT, or other frameworks unless the user requests them or they are clearly useful
- **Over-generalization**: Do not produce conclusions that could apply to anyone. Every implication must be specific to this material and this situation
- **Platitudes**: Do not restate what the user already knows in a polished way. If the output would not surprise the user, it is not useful
- **Over-analysis**: When sufficient implications have been derived for the user's purpose, stop. Useful implications over perfect analysis

---

## No-args Behavior

1. Check for active sessions: Glob `~/.claude/analyze/status/*.md`, then Grep for `rally: ongoing` in each file
2. If active sessions exist:
   - Display each session's topic and last updated date
   - Show: "Use `/analyze [question]` to continue analysis"
3. If no active sessions:
   - Display the argument routing table above
   - Show: "Use `/analyze start [topic]` to begin a new analysis session"

---

## Subcommand: `/analyze start [topic]`

Start a new analysis session. Runs in the main conversation (no subagent).

### 1. Guard: Check for duplicate

Generate a slug from the topic. Check if `~/.claude/analyze/status/{today}_{slug}.md` already exists with `rally: ongoing`. If so, inform the user: "同名のセッションが既にあります。`/analyze [question]` で続行するか、別の topic を指定してください。"

### 2. Receive materials and confirm purpose

- Use the `[topic]` argument as the starting point
- If materials are not yet provided, ask the user to share them
- Confirm: what does the user want to know or decide?

### 3. Assessment

Assess the current state of the materials to establish the analysis foundation.

**Assessment Checklist:**

1. **Read materials**: Thoroughly read and understand all provided materials
2. **Identify material type**: Quantitative / qualitative / mixed; raw / organized / interpreted
3. **Determine purpose**: What does the user want to know or decide?
4. **Judge current level**:

| Level | State |
|-------|-------|
| Raw materials | Unorganized data or records |
| Observations | Facts are organized but not yet interpreted |
| Interpretations | Hypotheses or interpretations exist but lack conviction or next steps |
| Decision pending | Options are visible but hard to choose between |

**Principle**: Infer what you can from the materials. Only ask about what the materials alone cannot tell you.

### 4. Create state file

Run `mkdir -p ~/.claude/analyze/status` and write the state file:

**Path**: `~/.claude/analyze/status/{YYYY-MM-DD}_{topic-slug}.md`

```markdown
---
type: analyze-session
rally: ongoing
topic: "{topic}"
created: {YYYY-MM-DD}
last_updated: {YYYY-MM-DD}
rally_count: 0
---

## Materials
{summary of materials provided — NOT the raw materials themselves}

## Purpose
{analysis purpose}

## Assessment
- Material type: {quantitative / qualitative / mixed}
- Material state: {raw / organized / interpreted}
- Current level: {Raw materials / Observations / Interpretations / Decision pending}

## Analysis Log
| # | Question | Conclusion |
|---|----------|------------|

## Current State
Assessment 完了。最初の分析質問を受け付ける準備ができた。
```

### 5. Confirm

Display: "分析セッションを開始しました。`/analyze [question]` で質問してください。"

---

## Continue Workflow: `/analyze [question]`

Continue analysis by delegating to a subagent with a clean context.

### 1. Session resolution

1. Glob `~/.claude/analyze/status/*.md`
2. Grep each file for `rally: ongoing`
3. Based on count:
   - **0 files**: Error — "active なセッションがありません。先に `/analyze start` を実行してください。"
   - **1 file**: Auto-select
   - **Multiple files**: Display a numbered list of sessions (topic + date) and ask the user to choose

### 2. Get the question

If `[question]` argument is provided, use it. Otherwise, ask the user.

### 3. Read state file

Read the full content of the selected state file.

### 4. Launch subagent

Launch a `general-purpose` subagent with `mode: "bypassPermissions"` using the prompt template below. Pass the state file content and user's question as template variables. The subagent does NOT write files — it returns analysis results and updated state file content as text.

### 5. Update state file

Extract the `Updated State File` content from the subagent's response and write it to the state file path (overwrite the entire file).

### 6. Display summary

Show ONLY the subagent's returned summary to the user. Do not repeat the full analysis or the state file content.

### 7. Handle session end

If the subagent reports `Status: concluded`, ask the user: "分析セッションが終了しました。重要な知見を agent-memory に保存しますか？"

---

## Subagent Prompt Template

The following template is used when launching the analysis subagent in `/analyze [question]`. Replace `{state_file_content}` and `{question}` with actual values. The subagent does NOT access the filesystem — all I/O is handled by the main agent.

```
あなたは分析エージェントです。クリーンなコンテキストで起動しています。
会話履歴はありません。状態ファイルが唯一の情報源です。

## 状態ファイル
{state_file_content}

## ユーザーの質問
{question}

## 分析の原則
- 事実と解釈を分離する — 「データが示すこと」と「そこから解釈できること」を常に区別
- 根拠を示す — すべての示唆や提案に「なぜそう言えるか」を含める
- 不確実性を認める — データが不十分なら明示する
- データが支持しない結論を主張しない
- フレームワーク（MECE, SWOT 等）は求められない限り持ち出さない
- 誰にでも当てはまる一般論を避ける。この素材・この状況に固有の示唆を出す
- 十分な示唆が得られたら止める。完璧な分析より有用な示唆

## 分析の引き出し（背景知識として使用、明示的な選択は不要）
- 整理する：散在する情報に構造を与える（表にする、トレンドを識別、分類）
- 問い直す：前提や解釈を検証する（別の解釈、確証バイアス、欠けている変数）
- 掘り下げる：表面の一段下を探る（構造的な要因、セグメント別分解、追加データ）
- つなげる：別々の情報間の関係を見つける（定量×定性の照合、類似事例、既知の知見）
- まとめる：分析をアクション可能な形にする（問いのリスト、仮説と検証方法、選択肢と推奨）

## 指示
1. 状態ファイルの Current State を読み、分析がどこまで進んだか把握する
2. ユーザーの質問に対して最も適切な分析を実行する
3. 状態ファイルの更新版を作成する（ファイルには書き込まない — メインエージェントが書き戻す）：
   - frontmatter: rally_count を +1、last_updated を今日の日付に更新
   - Analysis Log: 1行追加（#, Question, Conclusion）
   - Current State: 現時点の到達点・未解決の論点・次に探るべき方向に書き換え
   - ユーザーが終了を示唆した場合: rally を concluded に変更し、最終的な総括を Current State に記載
4. 以下のフォーマットでのみ返却する（ファイル操作は一切行わない）：
   - **Summary**: 分析結果の要約（3-5文）
   - **Status**: ongoing または concluded
   - **Next**: 次に探ると良さそうな方向（ongoing の場合）
   - **Updated State File**: 更新後の状態ファイル全文（コードブロックで囲む）
```

---

## Session Lifecycle

- **Start**: `/analyze start [topic]` creates a state file at `~/.claude/analyze/status/`
- **Continue**: `/analyze [question]` — each invocation delegates to a fresh subagent
- **End**: User signals conclusion during `/analyze` → subagent sets `rally: concluded`
- **Post-session**: Optionally save valuable insights to agent-memory (not the state file itself)
- **New session**: `/analyze start` with a new topic creates a new state file

## Completion

This skill is complete when:
- The user has the clarity they need for their decision or next step
- Or the user explicitly ends the session (with optional knowledge save)
