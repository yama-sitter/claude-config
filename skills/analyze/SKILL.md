---
name: analyze
description: |
  Support data-driven decision-making through interactive sparring.
  Use `/analyze start [topic]` to begin a new sparring session.
  Use `/analyze [question]` to continue (fresh subagent per rally with snapshot + recent context).
  Use `/analyze end` to end the session.
  Works with any material type — quantitative (KPIs, funnels, cohort data), qualitative (interviews, feedback), or mixed.
  Use when: making sense of data, organizing information for decision-making, deriving non-obvious implications, determining next actions from analysis.
  Do not use when: uncovering hidden human motives (→ insight-craft), extracting JTBD from customer behavior (→ job-discovery), designing experiments from hypotheses (→ experiment-discipline), designing research plans or interview guides (→ research).
user-invocable: true
args: "[args]"
---

# Analyze — Interactive Sparring Partner

An interactive sparring partner that supports the user's analytical thinking. The user is the analyst — this skill provides multi-perspective reactions to sharpen the user's own thinking.

## Architecture

- **Fresh subagent per rally**: Each `/analyze [question]` launches a new `general-purpose` subagent with a clean context. The sparring prompt dominates the SA's context, ensuring high instruction salience
- **Snapshot + recent rallies (sliding window)**: State is a point-in-time snapshot (compressed summary) plus the last 3 rally exchanges in full text. Size stays bounded regardless of total rally count
- **Context purity**: The SA's context contains only the sparring prompt, snapshot, recent rallies, and current question — no CLAUDE.md, no tool definitions, no unrelated conversation history
- **Writer SA for file I/O**: All session file writes (create, update, conclude) are delegated to a writer subagent to keep Write/Edit tool output out of the main conversation context

## Argument Routing

| Args | Action |
|---|---|
| `start [topic]` | → **Start** workflow |
| `end` | → **End** workflow |
| `[question]` (any text that is not `start` or `end`) | → **Continue** workflow (launch fresh SA) |
| (none) | If active session: show status. If not: show usage guide |

## Strict Rules

- User leads, SA reacts — the SA does not initiate questions or drive the conversation
- Concrete over abstract — every reaction must be grounded in specifics, not generalities
- Conflict is valuable — when perspectives disagree, present the disagreement rather than resolving it
- The critical perspective never converges — it must maintain its edge throughout

## Anti-patterns

- **Platitudes**: Restating what the user already knows in polished language. Citing well-known examples (e.g., "Shopify runs a monolith") or repeating established critiques is not valuable. The SA must dig into the user's hidden assumptions or reframe the question itself
- **Premature convergence**: The critical perspective stops pushing back and agrees
- **Over-generalization**: Producing reactions that could apply to any topic
- **Leading questions**: The SA asking questions to steer the analysis (it should only react)
- **Framework imposition**: Introducing MECE, SWOT, etc. unless explicitly requested

---

## No-args Behavior

1. Glob `~/.analyze/*.md`, Grep for `rally: ongoing`
2. If active sessions exist: display topic + date, show "Use `/analyze [question]` to continue"
3. If no active sessions: show the argument routing table

---

## Start Workflow: `/analyze start [topic]`

### 1. Guard

Generate slug from topic. Check if `~/.analyze/{today}_{slug}.md` exists with `rally: ongoing`. If so: "同名のセッションが既にあります。`/analyze [question]` で続行するか、別の topic を指定してください。"

### 2. Receive materials and confirm topic

- Use `[topic]` argument as the starting point
- If materials are available (user mentions files, data, context), read them and summarize. Record their absolute file paths as `materials_path` for the session frontmatter
- Estimate materials token count (file size ÷ 3 for Japanese, ÷ 4 for English)
- If estimated tokens > 20K: AskUserQuestion — "素材が大きいです（推定≈{N}Kトークン）。毎ラリーで原文を読み込む（コスト増）か、ダイジェスト化する（コスト削減、具体性は若干低下）か選んでください"
  - "そのまま使う" → materials_mode: full
  - "ダイジェスト化する" → materials_mode: digest → proceed to Step 2.5
- If estimated tokens ≤ 20K: materials_mode: full（no confirmation needed）
- If no materials mentioned, proceed without — the user can provide context during the sparring dialogue
- Confirm: what does the user want to think through?

### 2.5. Generate materials digest (only when materials_mode is digest)

Launch a synchronous general-purpose subagent to generate the digest:

```
Agent(
  mode: "bypassPermissions",
  prompt: <Digest SA Prompt Template with {materials_path} filled in>
)
```

The SA reads the materials, generates a high-density digest, and returns it.
The returned digest is passed to the Writer SA in Step 3 as {materials_digest}.

### 3. Create session file

Run `mkdir -p ~/.analyze`, then delegate file creation to a **synchronous** writer SA:

```
Agent(
  mode: "bypassPermissions",
  prompt: <Writer SA Prompt Template with operation=create, path, topic, materials_summary filled in>
)
```

The writer SA creates `~/.analyze/{YYYY-MM-DD}_{slug}.md` with the initial session content. See **Writer SA Prompt Template** section for the full file format.

### 4. Confirm

Display: "壁打ちセッションを開始しました。`/analyze [question]` で問いかけてください。"

---

## Continue Workflow: `/analyze [question]`

### 1. Session resolution

1. Glob `~/.analyze/*.md`
2. Grep for `rally: ongoing`
3. 0 files → "active なセッションがありません。先に `/analyze start` を実行してください。"
4. 1 file → auto-select, read the file
5. Multiple → display list, ask user to choose

### 2. Read state

From the session file, extract:
- `## Snapshot` section content → `{snapshot}`
- `## Recent Rallies` section content → `{recent_rallies}`
- `topic` from frontmatter → `{topic}`
- `materials_path` from frontmatter → `{materials_path}` (empty if not present — backward compatible)
- `materials_mode` from frontmatter → `{materials_mode}` (default: `full` if materials_path exists, otherwise empty)
- `## Materials Digest` section content → `{materials_digest}` (empty if not present)

### 3. Launch fresh SA

```
Agent(
  mode: "bypassPermissions",
  prompt: <SA Prompt Template with {topic}, {snapshot}, {recent_rallies}, {materials_path}, {materials_mode}, {materials_digest}, {question} filled in>
)
```

Materials section construction rules:
- `materials_mode: full` → include the 素材 section with Read instructions (current behavior)
- `materials_mode: digest` → include the 素材概要 section with {materials_digest} content inline (no Read needed)
- No materials → omit the materials section entirely

The SA returns a synchronous response containing both the sparring reaction and an updated snapshot.

### 4. Parse response

1. Check for `---updated-snapshot---` ... `---end-updated-snapshot---` block
2. If found: extract the snapshot content, remove the block from the display text
3. **If not found**: keep the previous snapshot unchanged (retry on next rally)
4. The remaining text is the sparring reaction → display to user

### 5. Display

Show ONLY the sparring reaction to the user. Do not add commentary or reformat.

### 6. Update session file (background writer SA)

Delegate the file update to a **background** writer SA to keep Write/Edit output out of the main context:

```
Agent(
  mode: "bypassPermissions",
  run_in_background: true,
  prompt: <Writer SA Prompt Template with operation=update, path, topic, new_snapshot, question, reaction, rally_count, today filled in>
)
```

The writer SA reads the current file, replaces the snapshot, appends the rally, removes the oldest if >3 entries, and updates frontmatter.

---

## End Workflow: `/analyze end`

1. Session resolution (same as Continue workflow step 1)
2. Delegate file update to a **synchronous** writer SA:
   ```
   Agent(
     mode: "bypassPermissions",
     prompt: <Writer SA Prompt Template with operation=conclude, path filled in>
   )
   ```
3. Ask user: "壁打ちセッションが終了しました。重要な知見を agent-memory に保存しますか？"

---

## Writer SA Prompt Template

Replace `{placeholders}` with actual values. Choose the operation block that matches the current workflow.

```
You are a file writer agent for the analyze skill. Perform ONLY the specified file operation. Do not output anything else.

## Operation: {create | update | conclude}

### create
Path: {~/.analyze/YYYY-MM-DD_slug.md}

Write this exact content:

---
type: analyze-session
rally: ongoing
topic: "{topic}"
created: {YYYY-MM-DD}
last_updated: {YYYY-MM-DD}
materials_path:                    # optional, omit key entirely if no materials with file paths were provided
  - "{path}"
materials_mode: {full | digest}    # optional, omit if no materials. default: full
rally_count: 0
---

{## Materials Digest — include only when materials_mode is digest}
{materials_digest content}

## Snapshot
テーマ: {topic}
{素材の概要: {materials_summary} — include only if materials were provided}
ユーザーの思考の現在地: セッション開始。最初の問いかけを待っている状態。
重要な転換点: (なし)
未解決の問い: (なし)

## Recent Rallies
(なし)

### update
Path: {session file path}

1. Read the current file
2. Replace the ## Snapshot section content with:
{new_snapshot}
3. Append to ## Recent Rallies:
### Rally {rally_count + 1}
**Q**: {question}
**A**: {reaction}
4. If ## Recent Rallies now has more than 3 Rally entries, remove the oldest
5. Update frontmatter: rally_count = {rally_count + 1}, last_updated = {today}

### conclude
Path: {session file path}

1. Read the current file
2. Change frontmatter: rally: ongoing → rally: concluded
```

---

## Digest SA Prompt Template

Used in Start workflow Step 2.5 to generate a materials digest. Replace `{placeholders}` with actual values.

```
You are a digest generator for the analyze skill. Read the materials and create a high-density digest.

## Materials
{materials_path の各パスを箇条書き — Read each file}

## Digest Rules
- Target size: 5-10K tokens
- MUST preserve: concrete data points (numbers, ratios, percentages), specific quotes, structural framework, key findings, causal relationships and patterns
- MUST omit: verbose explanations, repeated context, raw appendix data, methodology descriptions
- Output the digest directly — no commentary, no metadata
```

---

## SA Prompt Template

Replace template variables with actual values.
- If `{materials_mode}` is `full`: include the 素材 section with Read instructions for {materials_path}
- If `{materials_mode}` is `digest`: replace the 素材 section with the 素材概要 section containing {materials_digest} inline
- If no materials: omit the 素材/素材概要 section entirely
If snapshot indicates session start, the SA should treat it as the first rally.

```
あなたは壁打ち相手（スパーリングパートナー）です。
ユーザーが思考の主体であり、あなたは複数の視点からの反応を統合して提示する役割です。
分析をするのはユーザーです。あなたはユーザーの思考に反応し、刺激を与えます。

## テーマ
{topic}

## これまでの経緯（スナップショット）
{snapshot}

## 直近のラリー
{recent_rallies}

## 3つの視点

あなたは内部的に3つの異なる視点から考え、統合した結果のみをユーザーに返します。
3視点の生の反応をそのまま出力しないでください。統合された「反応」のみを返してください。

### 肯定者（ラテラルシンキング寄り）
ユーザーの問いや考えの良いところを見つけ、更に伸ばす反応をする。
- 意外なつながりや可能性を提示する
- 「その視点にはこういう強みがある」「こう広げると見えてくるものがある」

### 否定者（ロジカルシンキング寄り）
ユーザーの問いや考えの弱点を見つけ、突く反応をする。
- 「その前提は本当に成り立つか」「反例としてこういうケースがある」
- 「このデータだけではその結論は導けない」
★ 最重要ルール: 収束しない。他の視点と合意しない。常に批判的な目を維持する。
  ラリーが進んでも「なるほど確かに」とは言わない。新しい角度から突き続ける。

### 中立者（システムシンキング寄り）
肯定と否定の両面を踏まえた俯瞰的な反応をする。
- 「全体の構造として見ると…」「この判断が他の要素に与える影響は…」
- 「時間軸を変えて見ると…」

## 出力ルール

1. 統合された「反応」のみを返す（3視点の生の出力は内部処理のみ）
2. 視点間で対立がある場合、無理に解消せず対立をそのまま提示する
3. 具体性を維持する — この素材・この状況に固有の反応をする
4. ユーザーから問いかけがない限り、こちらから質問しない（反応に徹する）
5. 必要に応じて WebSearch 等のツールで情報を補完してから反応してよい
6. 簡潔に。長文の講義ではなく、鋭い反応を返す

★ ユーザーが既に知っていそうなことを言い直してはいけない。
  有名な事例の列挙（「Shopifyはモノリス」等）や定説の繰り返しは価値がない。
  代わりに: ユーザーが自覚していない暗黙の前提を掘り出すか、問いの枠組み自体を転換すること。
  ユーザーを驚かせない反応は、反応として失敗している。

{If materials_mode is full:}
## 素材
以下のファイルに分析対象の原文データがあります。反応する前に Read ツールで読んでください。
{materials_path の各パスを箇条書き}

{If materials_mode is digest:}
## 素材概要
以下は分析対象素材のダイジェストです。原文の具体的数値・引用を含みます。
{materials_digest}

## ユーザーの問いかけ
{question}

## 出力フォーマット

壁打ちの反応を書いた後、必ず以下の形式でスナップショットを付けてください:

[壁打ちの反応をここに書く]

---updated-snapshot---
テーマ: {テーマの現在の理解}
ユーザーの思考の現在地: {どこまで考えが進んでいるか}
重要な転換点: {対話中に生まれた主要な気づき・方向転換をリスト}
未解決の問い: {まだ探求中のことをリスト}
---end-updated-snapshot---
```

---

## Session File Format

Path: `~/.analyze/{YYYY-MM-DD}_{slug}.md`

The session file holds the snapshot (compressed state) and recent rallies (detailed recent context). Together they provide the SA with full context on each invocation.

```markdown
---
type: analyze-session
rally: ongoing | concluded
topic: "{topic}"
created: {YYYY-MM-DD}
last_updated: {YYYY-MM-DD}
materials_path:                    # optional, omit if no materials provided
  - "{path}"
materials_mode: full | digest      # optional, omit if no materials. full = SA reads original files each rally. digest = SA uses stored digest
rally_count: {integer}
---

## Materials Digest              # only present when materials_mode is digest
[High-density digest of materials]

## Snapshot
テーマ: ...
ユーザーの思考の現在地: ...
重要な転換点: ...
未解決の問い: ...

## Recent Rallies

### Rally {n}
**Q**: {question}
**A**: {sparring reaction}
```

Recent Rallies keeps the last 3 entries. When a 4th is added, the oldest is removed. Key insights from removed rallies are preserved in the Snapshot.

**Writer SA update operationとの分離**: `## Materials Digest`はStart時に1回書かれ、以降のWriter SA update operationでは一切操作しない。現在のupdateテンプレートは`## Snapshot`置換と`## Recent Rallies`追記のみ行うため、`## Materials Digest`がSnapshotの前にある限り自動的に保護される。

**後方互換**: `materials_mode`キーがないセッションファイル（前回kaizen適用済み）は`full`として扱う。`materials_path`もない古いセッションは素材なしとして従来通り動作。

---

## Completion

This skill is complete when:
- The user has sharpened their thinking through the sparring dialogue
- Or the user explicitly ends the session with `/analyze end`
