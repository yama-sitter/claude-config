# 出力先ルーティング（日本語ミラー）

> **このファイルは人間用のミラーです。** Claude は英語正本 (`target-routing.md`) を読みます。

## マッピング表

| カテゴリ | 出力先                     | パス / 場所                                                                                                      | 根拠                                                              |
| -------- | -------------------------- | ---------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| C1       | rules（merge）or CLAUDE.md | `~/.claude/rules/<topic>.md` 既存マッチ時のみ、それ以外は CLAUDE.md。**単一指摘で新規 rules ファイルは作らない** | harness-catalog §3「Repeated judgment errors → rules/」           |
| C2       | agent-memory insight       | `~/.agent-memory/<repo>/<date>_pr-<n>-feedback/c2-<slug>.md`                                                     | harness-catalog §3「Cross-session knowledge loss → agent-memory」 |
| C3       | agent-memory insight       | `~/.agent-memory/<repo>/<date>_pr-<n>-feedback/c3-<slug>.md`                                                     | 時限的方針                                                        |
| C4       | agent-memory insight only  | `~/.agent-memory/<repo>/<date>_pr-<n>-feedback/c4-<slug>.md`                                                     | rules 化は永久禁止                                                |
| C5       | なし（advisory のみ）      | 報告のみ。ファイル書き込みなし                                                                                   | harness で enforce 不可                                           |
| C6       | 検知可能性に依存           | varies                                                                                                           | harness-catalog §1 フローチャート                                 |
| C7       | skip                       | サマリーに件数のみ                                                                                               | 自己ラベル trivial                                                |
| C8       | skip                       | 返信解決時のみ 1 行要約                                                                                          | 議論であり change ではない                                        |

## トピックディレクトリ構造

1 PR = 1 ディレクトリ。insight は配下に並列配置。

```
~/.agent-memory/<repo>/<date>_pr-<n>-feedback/
├── plan.md
├── summary.md
├── c2-url-design-background.md
├── c2-ob-og-screen-distinction.md
├── c3-dual-handling-merge-pr-4.md
└── c4-shallow-routing-simplification.md
```

`<slug>` は kebab-case、5 単語以下、ASCII のみ。

> **Rationale**: agent-memory 規約「1 topic per file」は守りつつ、PR 単位の文脈をディレクトリでグループ化。複数 insight が同じ PR の異なる側面を捉えるため、ディレクトリ集約のほうが後から `/agent-memory search` で引いたときに文脈復元しやすい。

## C6（バグ）のルーティング

harness-catalog §1 を verbatim で参照:

```
決定的に block / verify 可能か?
  → Yes → hooks
  → No → 物理的に prohibit すべきか?
        → Yes → permissions
        → No → プロセス構造化（multi-step workflow）が必要か?
              → Yes → skills
              → No → Global? → rules/ ; Project-specific? → CLAUDE.md
```

レビュアー報告のバグは通常 hooks（lint や shell test で検知可能なパターン）か、agent-memory note + 手動修正（one-off）に着地する。

## C1 の Merge 判定

新規 `~/.claude/rules/` ファイル作成前に以下を実行。デフォルトバイアスは **新規作成しない**。明示的な merge/promote パスのみ rules 書き込みを発生させる。

1. **完全一致 topic**: `~/.claude/rules/<topic>.md` が既存で topic 名が一致 → merge して終了
2. **同型ルール**: 既存 rules に同じ forbid/suggest パターンが存在 → 追加例として merge して終了
3. **どちらも一致しない**: 新規 rules ファイルを**作らない**。`c1-pending-<slug>.md` として agent-memory に保存し、3 件以上累積した時点で rules 昇格を提案

> **Rationale**: 3-strike 閾値はガードレール。1 PR の stylistic complaint で global rule を作ると過剰一般化リスクが高い。複数 PR・複数レビュアーから同種指摘が出た時点で「再現性のあるパターン」として昇格判定する。

## CLAUDE.md フォールバック

Step 3 の状態で、ルールが **プロジェクト固有** の場合（`src/features/` のパス、Next.js / Tailwind / pnpm 固有挙動、プロジェクト内命名規約）、agent-memory holding pen を経由せず CLAUDE.md に直接書く。

検知ヒューリスティック: 現リポジトリには存在するが `~/.claude/` には存在しないパスを引用しているコメントはプロジェクト固有。

> **Rationale**: harness-catalog §2「project-specific は CLAUDE.md、global は rules/」に従う。プロジェクト固有を rules に書くと、別プロジェクトで作業時にノイズになる。

## 冪等性契約

すべての書き込みターゲットは「すでに適用済みなら skip」をサポートする。`apply` は plan.md の各 insight `Status` セルを読む:

- `Status: applied` → skip、再書き込みなし
- `Status: proposed` → 書き込み。成功時 `applied` にフリップし、insight ファイルの frontmatter `applied_at:` を設定

実装する subagent は「同内容で既に存在」を success として扱う（conflict ではない）。

> **Rationale**: ネットワーク失敗や部分失敗時、`apply` を再実行できる安全性を保つ。冪等性がないと「中途半端な状態を手で修復」が必要になり運用負荷が高い。

## スコープ外

- commit / push（`/kaizen commit` を案内）
- `~/.claude/settings.json` の直接変更（C6 で hooks を提案する場合も _patch 提案_ に留め auto-apply しない）
- 別実行間の横断集計。各実行は現 PR の plan にのみ作用する。他 PR の過去 insight は agent-memory に残り、必要なら `/agent-memory search` で直接引ける
