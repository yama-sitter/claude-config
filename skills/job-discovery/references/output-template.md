# Output Subcommand (`/job-discovery output`)

Generate a shareable Markdown document from the completed analysis worklog.

### Prerequisites

- `job-discovery-worklog.md` exists in agent-memory and contains a Step 5 section
- The worklog path is specified by the user or detected from conversation context
- If the worklog is not found or Step 5 section is missing, display: **「worklogが見つからない、またはStep 5が完了していません。分析を先に完了してください」** and stop

### Implementation

1. Locate the worklog file (`job-discovery-worklog.md`) in agent-memory
2. Read the worklog and verify all Step sections (0-5) exist
3. Extract data from each Step section and reformat into the output template below
4. Write `job-discovery-report.md` to the user-specified directory (or the same agent-memory directory)

**Data source**: Read ALL data from the worklog file. Do NOT rely on conversation context for any analysis data.

**Design principles**:

- **No JTBD jargon without explanation**: Annotate Hire, Re-hire, Push, Pull, etc. with plain-language descriptions on first use
- **Conclusion first**: Job hypotheses (most abstract) → supporting patterns → detailed data
- **Traceability throughout**: All sections use P*-S*/P*-St*/CF-\*/F-XX identifiers. Include a legend at the top
- **Hide internal process**: No lens names, Step numbers, or skill-internal terminology
- **Appendix is collapsible**: Use `<details>` tags for raw data
- **List formatting in tables**: When listing multiple items per case (e.g., "A: x / B: y / C: z"), use comma-separated format `A: x, B: y, C: z` for Notion compatibility. Do NOT use `<br>` tags.

**Document template**:

```markdown
# Job Discovery: [1-line summary of the analysis focus]

- **分析対象**: [source material description]
- **焦点**: [analysis focus from Step 0]

| ケース                  | 企業 | 事業 | 体制 | トリガー | 現在の位置づけ |
| ----------------------- | ---- | ---- | ---- | -------- | -------------- |
| [Case rows from Step 0] |

> **識別子の読み方**
>
> - `P1-S1` 等: フェーズ1の共通状況パターン（下記「共通する行動パターン」で定義）
> - `P1-St1` 等: フェーズ1の共通の構え（下記「共通する行動パターン」で定義）
> - `CF-Push1` 等: 3社に共通する意思決定の力（下記「共通する力学」で定義）
> - `F-A1` 等: 個別ケースの発言・行動記録（付録「ファクトテーブル」で参照可能）

---

## 1. 発見されたジョブ仮説

「顧客がこのサービスを使う理由」の仮説候補。
確定版ではなく、議論・検証のための叩き台として複数の視点から生成しています。

### [Phase label]のジョブ（[plain-language question]）

#### 候補N: [short label]

| 句               | 内容                | 根拠        | 出典      |
| ---------------- | ------------------- | ----------- | --------- |
| **どんな時に**   | [situation]         | Ctx-_, CF-_ | F-XX, ... |
| **何をしたいか** | [motivation]        | Ctx-_, CF-_ | F-XX, ... |
| **そうすれば**   | [expected progress] | Ctx-_, CF-_ | F-XX, ... |

- 💡 **説明できること**: [unique explanatory power]
- 🔍 **さらに検討が必要な点**: [blind spots]
- 🗣️ **代表的な声**: _"[verbatim quote]"（[Case]）_

この仮説の限界・前提: [constraints]

_(Repeat for each candidate per phase)_

---

## 2. 3社に共通する行動パターン

### フェーズ1: [phase name]

#### 共通状況

| P1-S# | パターン | 3社での現れ方 | 出典 |
| ----- | -------- | ------------- | ---- |

#### 共通の構え

| P1-St# | 構え | 由来する状況 | 出典 |
| ------ | ---- | ------------ | ---- |

### フェーズ2: [phase name]

#### 共通状況

| P2-S# | 変化タグ | パターン | 3社での現れ方 | 出典 |
| ----- | -------- | -------- | ------------- | ---- |

(変化タグ: 継続 / 変化 / 新規)

#### 共通の構え

| P2-St# | 変化タグ | 構え | 由来する状況 | 出典 |
| ------ | -------- | ---- | ------------ | ---- |

_(Repeat for each additional phase)_

---

## 3. 共通する意思決定の力学

### [Phase]時

| CF-# | 力  | 共通の力学 | ケース間の違い | 出典 |
| ---- | --- | ---------- | -------------- | ---- |

**最も強い力**: [summary]

### 共通ナラティブ

**[Phase 1]の共通因果フロー**:

- [sentence 1]
- [sentence 2]
- ...

**[Phase 2]の共通因果フロー**:

- [sentence 1]
- [sentence 2]
- ...

---

## 付録

<details>
<summary>ファクトテーブル（生データ）</summary>

[Step 1 full Fact Tables per case]

</details>

<details>
<summary>ケースごとのストーリー（時系列）</summary>

Per case:

**前提条件**: List format, one condition per line with F-XX identifiers

**時系列の出来事**: Table format:

| # | フェーズ | 出来事 | 出典 |

[Step 2 Background + Events per case]

</details>

<details>
<summary>ケースごとの力学分析</summary>

Per case, per phase: summary line + table format:

| 力 | 強さ | 内容 |

[Step 4a per-case Forces data]

</details>
```

**→ Save the document to agent-memory and display the saved path to the user.**
