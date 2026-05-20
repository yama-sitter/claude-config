# PR Feedback Kaizen（日本語ミラー）

> **このファイルは人間用のミラーです。** Claude は英語正本 (`SKILL.md`) を読みます。

## いつ使うか

マージ済み PR で受けた指摘の対応自体は完了しているが、同じパターンが再発しないように学習・harness 化したい時に使う。

呼び出し: `/pr-feedback-kaizen <pr-url>`（URL のみ、PR 番号は受け付けない）

## 使わない場面

- 会話中の失敗を起点とした分析 → `/kaizen` を使う
- ユーザーからの明示指示で即座にブロックを作りたい → `/hookify` を使う
- レビューが未解決のオープン PR → 先にレビューを resolve してから

## kaizen / hookify との差別化

| スキル                | 入力源                                    | 粒度                                     |
| --------------------- | ----------------------------------------- | ---------------------------------------- |
| `/kaizen`             | 会話内の失敗                              | harness 全般                             |
| `/hookify`            | 明示指示                                  | 即時ブロック・hook                       |
| `/pr-feedback-kaizen` | 外部レビュアーのコメント（マージ済み PR） | rules / CLAUDE.md / hooks / agent-memory |

> **Rationale**: PR レビューは「外部の客観的視点」が入る貴重なフィードバック源。会話内 failure や明示指示とは性質が異なるため独立スキルにした。

## ワークフロー（6 フェーズ）

| Phase                  | 主体                         | 動作                                                                                                       |
| ---------------------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------- |
| 1. Fetch               | main                         | `gh auth status` 確認 → `gh api .../comments` (inline) と `gh pr view --comments` (issue) で全コメント取得 |
| 2. Classify & Generate | subagent (`general-purpose`) | feedback-taxonomy.md / target-routing.md / kaizen の harness-catalog.md §3 を参照し C1-C8 に分類           |
| 2.5. Plan Save         | main                         | `diagnose` 完了時に `~/.agent-memory/<repo>/<date>_pr-<n>-feedback/plan.md` に書き出す                     |
| 3. Approval            | main                         | `apply` 実行時に plan.md を再表示し AskUserQuestion (multiSelect) で承認                                   |
| 4. Implement           | subagent (`general-purpose`) | 承認された insight を出力先ごとに実装                                                                      |
| 5. Record              | main                         | agent-memory `save` 経由で各 insight を保存。plan.md の `status: applied` / `applied_at:` を更新           |

## サブコマンド（kaizen と対称）

- `(default) <pr-url>`: diagnose → plan 保存 → apply を同セッションで連続実行
- `diagnose <pr-url>`: 分類のみ。ファイル書き込みなし
- `plan <pr-url>`: 分類 → plan.md 保存。`apply` への入り口
- `apply <plan-md-path>`: plan.md を読み込んで承認 → 実装 → 記録。冪等
- `commit`: `~/.claude/` 配下の harness 変更を claude-config リポジトリに commit。`/kaizen commit` に委譲（commit ロジックは共通のため重複実装しない）

> **Rationale**: kaizen と同じインターフェースに揃えることで、ユーザーが新規操作を覚え直す必要をなくす。`(default)` は 3 段ショートカット。

## 過剰一般化の回避

- C1（規約化可能）のみ rules 化対象。C2-C4 は agent-memory のみ
- 1 指摘 = 1 ルール禁止。既存 rules への merge を優先
- 同種が 3 件以上 agent-memory に蓄積された時点で rules 昇格を提案（3-strike 閾値）
- C4（設計判断）は永久に rules 化しない

> **Rationale**: レビューコメント 1 件で global rule を作ると過剰一般化リスクが高い。3-strike 閾値で「複数 PR にまたがる繰り返しパターン」を確認してから昇格する。

## 機微情報の扱い

- 社内 URL（Notion / Atlassian / Slack 等）は `~/.claude/rules/` に転記しない
- agent-memory の `related:` にのみ保持（`~/.agent-memory/` は gitignored）
- rules 内では `internal spec reference` に抽象化

> **Rationale**: rules は claude-config リポジトリにコミットされる公開ファイル。社内固有情報を保護しつつ、Claude が必要時に都度引ける状態を保つ。

## Citation Discipline

`citation-discipline.md` に従い、verbatim 引用は Verified tier のみ。要件を満たせない場合は paraphrase + コメント URL を `related:` に。捏造引用を生まないことが優先。

## Commit と cleanup

- `commit` サブコマンドは `/kaizen commit` に委譲する。対象は `~/.claude/` 配下の harness 変更で、kaizen と pr-feedback-kaizen の成果物を一括で commit できる
- `apply` 自体は commit しない。ユーザーが diff を確認したあとで `commit` を実行する
- `~/.agent-memory/` は gitignored なので commit 対象外。ローカルに留まる

> **Rationale**: commit ロジックを kaizen と共通化することで DRY 原則を守りつつ、サブコマンド構造は kaizen と対称にしてユーザーが覚えやすい状態を保つ。
