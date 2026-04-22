# arch-review レポートテンプレート

このファイルは **最終レポートの構造を示すガイド** です。parent Claude はこのテンプレートに従ってレポートを組み立ててコンソール出力します。

## 全体構造

```md
# arch-review レポート

## 対象

- base branch: <検出した base>
- 対象 diff: <引数なし (current branch) | PR #<N> | branch <name>>
- 変更ファイル数: <N>
- 総変更 LoC (insertions + deletions): <M>
- 評価モード: <fast path (1 subagent) | parallel (4 subagents) | 分割評価 (K groups)>
- 参照した規約: <ファイル一覧 | なし>

---

## 優先改善提案

<parent Claude が Step 12 の優先度付けルールに従って並べる。各 finding は 1 行要約 + `[P1-P4][軸][観点タグ][confidence][direction] <location>` のプレフィックスで。詳細は各軸セクションを参照>

### P1 — 最優先 (Must fix)

<confidence: high で 2 軸以上が同一 location を指摘しているもの。軸ごとに独立行で列挙>

- `[P1][凝集度][SRP][confidence: high][direction: add] src/features/foo/Foo.tsx` — 1 行要約 (詳細は凝集度セクション)
- `[P1][テスタビリティ][純粋関数分離][confidence: high][direction: add] src/features/foo/Foo.tsx` — 1 行要約 (詳細はテスタビリティセクション)

### P2 — 優先 (Should fix)

<confidence: high の単独軸 finding。direction: neutral は除外して P3 に送る>

- `[P2][シンプルさ][未使用export][confidence: high][direction: simplify] src/features/foo/utils.ts` — 1 行要約

### P3 — 推奨 (Nice to have)

<confidence: mid の全 finding + P2 から落ちた neutral: high>

- `[P3][結合度][import過多][confidence: mid][direction: simplify] src/features/bar/index.ts` — 1 行要約

### P4 — 判定保留 (要確認)

<confidence: low の全 finding。著者意図で OK の可能性。判定保留セクションと同じ内容を優先度観点で再提示>

- `[P4][凝集度][コロケーション][confidence: low][direction: add] src/features/baz/` — 1 行要約 + なぜ保留か (例: "フレームワーク制約の可能性")

該当が無いバケットは:

> 該当なし

---

## 凝集度 (Cohesion)

### findings

<confidence: high → mid → low の降順で列挙>

- `[凝集度][コロケーション][confidence: high][direction: add] src/features/foo/Foo.tsx` — 所見の 1-3 行 + 推奨アクション 1-2 行
- `[凝集度][SRP][confidence: mid][direction: simplify] src/features/foo/Foo.tsx:45-82` — 所見 + 推奨
- ...

### 軸サマリ (1-3 文)

<凝集度から見た全体所感。特に高 confidence で拾った点や、複数 finding のパターン>

---

## 結合度 (Coupling)

### findings

...

### 軸サマリ

...

---

## シンプルさ (Simplicity)

### findings

...

### 軸サマリ

...

---

## テスタビリティ (Testability)

### findings

...

### 軸サマリ

...

---

## 軸間トレードオフ

<同一ファイル path に対し confidence: high の direction: add と direction: simplify が衝突している箇所。両 findings を参照できる形で列挙>

### 例

- `src/features/foo/useFoo.ts`
  - 凝集度 [direction: add]: 「hook 内部に計算ロジックが混在。純粋関数として切り出すと凝集が上がる」
  - シンプルさ [direction: simplify]: 「計算ロジックを切り出すと 1 箇所でしか使わない関数が増える。このケースでは inline のままで良い」
  - **判断の鍵**: 今後この計算ロジックが他でも使われる見通しがあれば切り出し、無ければ inline。著者の判断領域。

矛盾が無ければ:

> 軸間で矛盾する指摘はありません。

---

## 判定保留 (要確認)

<confidence: low の findings。著者の意図・ドメイン知識次第で OK の可能性が高いもの>

- `[軸][タグ][confidence: low][direction: ...] <location>` — 所見 + なぜ保留か (例: "フレームワーク制約の可能性")

該当が無ければ:

> 判定保留の指摘はありません。

---

## 全体総括 (可読性を含む)

<4 軸の結果を踏まえた、この diff の設計品質の総合コメント 3-6 行。
可読性はここで扱う (命名、構造、ドキュメント性などが 4 軸の結果としてどう総合されているか)。
「著者はここが既によくできている」「ここは今後の改善余地」を両面で書く。>
```

## 分割評価時の構造

変更ファイル数 > 20 の場合、グループ単位で評価してセクション分割する。上記テンプレを以下のようにラップする:

```md
# arch-review レポート (分割評価)

## 対象

...(共通情報)

## Group: src/features/foo/

<優先改善提案 (P1-P4) + 4 軸セクション + 軸間トレードオフ + 判定保留>

## Group: src/features/bar/

<優先改善提案 (P1-P4) + 4 軸セクション + 軸間トレードオフ + 判定保留>

## 全グループ横断の全体総括

<複数グループを俯瞰した総評。共通パターンの指摘、グループ間で矛盾する設計方針など。
P1 finding が複数グループに跨っている場合はここで俯瞰して flag する>
```

**分割評価時の優先改善提案の置き方**:

- 各 Group セクションの **冒頭** に「優先改善提案 (グループ内)」を置く。ランクルールは共通
- グループ横断の P1 (複数グループで同一観点が出ている) は「全グループ横断の全体総括」で俯瞰コメントとして追記する (各 Group 内にも残したまま、冗長化は許容)

## 整形ルール

- **優先改善提案セクション** (冒頭)
  - P1 → P2 → P3 → P4 の降順
  - 同一バケット内は **file path の辞書順** → 同一 path 内は **軸名の辞書順** (凝集度 → 結合度 → シンプルさ → テスタビリティ)
  - P1 は複数軸の findings を **軸ごとに独立行** で列挙 (まとめない)
  - プレフィックスは `[P1-P4][軸][観点タグ][confidence][direction]` の順
  - 本文は **1 行要約のみ** (詳細は軸セクション参照、重複記載は避ける)
- **各軸セクションの findings**
  - **confidence 降順**で列挙 (high → mid → low)
  - 同一 confidence 内では **file path の辞書順** (ユーザがナビゲートしやすくする)
  - 各 finding は **1 行のプレフィックス (タグ群) + location + 所見・推奨** の構造を厳守
  - **タグは `[軸][観点タグ][confidence: ...][direction: ...]`** の順で並べる (visual consistency)
- direction: neutral は軸間トレードオフに載せない
- 軸サマリは 1-3 文で簡潔に (長文化しない)

## subagent への指示 (参考)

この report.md の構造は parent Claude が最終組み立て時に参照するもの。subagent は自分の担当軸について、以下の形式で findings を出せば良い:

```md
### findings

- `[凝集度][コロケーション][confidence: high][direction: add] <location>` — 所見 + 推奨
- ...

### 軸サマリ

<1-3 文>
```

parent Claude がこれを受け取って全体レポートに merge する。
