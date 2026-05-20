# フィードバック分類体系（日本語ミラー）

> **このファイルは人間用のミラーです。** Claude は英語正本 (`feedback-taxonomy.md`) を読みます。

## 判定順序（先勝ち）

```
C7 nit / typo
  → C8 質問 / 未解決議論
    → C5 チーム連携
      → C3 方針記録
        → C2 ドメイン知識
          → C6 バグ
            → C1 規約化可能
              → C4 設計判断（substantive コメントの catch-all）
```

> **Rationale**: 先勝ち（first-match）を採用したのは、レビューコメントが複数カテゴリの境界に位置することが多く、「best fit を探す」とブレが大きくなるため。優先度の高い判定（明示的な `nit:` / `?` で終わる質問）を先に切り捨てることで subagent の出力を安定させる。catch-all を C4（設計判断）にしているのは「分類不能」を生まないため。

## 8 カテゴリ

### C1 — 規約化可能

「常に X する」「Y は禁止」と一文で表現でき、コード例で示せるコメント。`~/.claude/rules/` または `CLAUDE.md` 行き。

判定キーワード:

- `should be` / `must be` / `please use X instead of Y`
- `consistent with` / `same shape as` / `align with`
- 具体的な lint パターン（`flatMap`、関数シグネチャ等）への言及

PR #6573 例: #5 (option 引数統一), #6 (フック名), #7 (flatMap)

### C2 — ドメイン知識

外部仕様（社内 doc、業務ルール、画面区別）が必要なコメント。`~/.agent-memory/` 行き。

判定キーワード:

- 社内 URL（Notion 等）への言及
- OB/OG / 常用 / 特例 などの業務概念
- 「なぜそうなっているか」の説明

PR #6573 例: #1 (URL 設計背景), #2 (OB/OG 区別)

> **Rationale**: rules は常にロードされプロンプト容量を圧迫する。ドメイン知識を rules に入れると bloat する一方、必要なときしか使わないので agent-memory で `/agent-memory search` 経由の JIT 取得が適切。

### C3 — 方針記録

時限的決定（「今は X、PR Z で統合予定」）。agent-memory 行き。

判定キーワード: `for now` / `until` / `tracked in` / `will be unified in` / `TODO`

PR #6573 例: #3 (dual handling 統合予定)

> **Rationale**: rules は timeless ルールを書く場所。時限的な方針は将来必ず変わるため、rules ではなく agent-memory に置いて「いつまで有効か」をフロントマターに記録する。

### C4 — 設計判断

文脈依存の設計判断。普遍的な勝者を宣言できないトレードオフ。agent-memory のみ、**rules 化禁止**。

判定キーワード:

- `extract` / `inline` / `move into` などの分解提案
- 2 案のトレードオフ議論
- readability / simplicity を rationale にする提案

PR #6573 例: #4 (shallow routing 簡潔化)

> **Rationale**: C4 を rules 化すると過剰一般化リスクが極端に高い。1 PR の文脈で正しい設計判断が別 PR では間違いになる。永久に agent-memory に閉じることで、似た状況で `/agent-memory search` から参照できる状態を保つ。

### C5 — チーム連携

他人 / 他 PR / ステークホルダーへの連絡を求めるコメント。harness 化不能。analysis report で advisory 表示のみ、ファイル書き込みなし。

判定キーワード: `cc @<user>` / 他 PR 番号 + `competing` / `coordinate`

PR #6573 例: #8 (#6580 競合)

### C6 — バグ

コード欠陥の指摘。ルーティングは harness-catalog §1 のフローチャートに従う（決定的に検知可 → hooks、それ以外 → agent-memory + 手動 fix）。

PR #6573 例: なし

### C7 — nits / typo

自己ラベル trivial（`nit:`, `typo:`, `minor:` 等で開始）。skip。

> **Rationale**: レビュアー自身が「trivial」と宣言しているものを harness 化対象にすると過敏すぎる。件数のみサマリーに残す。

### C8 — 質問 / 未解決議論

`?` で終わる、または質問形式のコメント。skip。スレッド返信に解決があれば 1 行要約のみ surface。

## 衝突・エッジケース

- **返信チェイン**: original コメントのみ分類。返信は元コメントを補強しても元の分類を変えない
- **複数文・複数カテゴリ**: 判定順序に従い最も上位の単一カテゴリに振る。1 コメント = 1 insight
- **Bot コメント**（coderabbitai, dependabot[bot] 等）: 含める。判定ルールは「テキスト」に対するもので、author に依存しない

## 機微情報検知

以下が含まれる場合、URL や固有名詞を rules / CLAUDE.md に転記してはならず、`internal spec reference` に抽象化する。実物は agent-memory の `related:` にのみ残す。

- ホスト名: `*.notion.so`, `*.atlassian.net`, `*.slack.com`, `*.coda.io`, `*.confluence.com`, `*.lark*`, `*.kibe.la`, `*.docbase.io`
- 社内サブドメイン: `*.<company>.internal`, `*.<company>.local`, リポジトリ組織ドメイン配下
- `gh pr view --json author,assignees,reviewRequests` に登場しない人名（社外ステークホルダーの可能性）
- `secret`, `credential`, `*.env*` 配下のパス

> **Rationale**: rules は claude-config リポジトリで公開される。社内 URL や個人名を含めると情報流出になる。agent-memory（gitignored）に閉じることで、Claude が `/agent-memory search` から参照可能な状態を保ちつつ公開を防ぐ。

## ゴールデンセット — PR #6573

taxonomy 変更時の回帰確認用。`diagnose https://github.com/Taimee/timee-client-web/pull/6573` の出力がこの表と完全一致しない場合、taxonomy にバグがある。

| #   | 一言要約                          | 期待カテゴリ | 根拠                          |
| --- | --------------------------------- | ------------ | ----------------------------- |
| 1   | URL 設計の背景説明（Notion 参照） | C2           | 外部 spec 参照                |
| 2   | OB/OG 画面と通常画面の区別        | C2           | 業務ルール文脈                |
| 3   | dual handling は PR 4 で統合予定  | C3           | 時限的決定                    |
| 4   | shallow routing 簡潔化            | C4           | readability-driven 設計判断   |
| 5   | confirmMode を option 引数に統一  | C1           | 「new() と consistent」= 規約 |
| 6   | useMultipleWorkDates 命名重複回避 | C1           | 命名規約                      |
| 7   | map().filter() → flatMap          | C1           | lint パターン                 |
| 8   | #6580 競合予測                    | C5           | 連携 ask                      |

> **Rationale**: 単体テスト的役割。taxonomy を更新するたびにこの表で回帰確認できる。1 件でも不一致なら taxonomy か prompt が間違っており、レビュアーは間違っていない（外部視点を信頼）。
