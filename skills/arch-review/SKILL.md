---
name: arch-review
description: |
  設計品質を 4 軸 (凝集度 / 結合度 / シンプルさ / テスタビリティ) で深く評価する。
  current branch または PR の diff を対象に、軸ごとの並列サブエージェントが独立に分析し、confidence 付きのレポートに統合する。
  Use when: 設計レビュー / アーキテクチャ評価 / design review / arch review を行いたいとき。PR 前のセルフレビュー、他人の PR の設計面のレビューに向く。
  Do not use when: バグ検出・セキュリティ・規約違反の検出 (-> /review, /ultrareview)、既存コードの監査 (diff が無いと動かない)。
user-invocable: true
args: "[PR番号 | branch名]"
---

# arch-review — 設計品質の 4 軸深掘りレビュー

設計を 4 軸で評価するポータブルスキル。バグではなく **設計健全性** を見る。

## 4 軸

| 軸                 | 観点                                                      |
| ------------------ | --------------------------------------------------------- |
| **凝集度**         | コロケーション / SRP / 責務の物理表現                     |
| **結合度**         | 依存方向 / コロケーション / 循環依存 / リーク             |
| **シンプルさ**     | YAGNI / 未使用 export / 過剰抽象 / 早期最適化             |
| **テスタビリティ** | DI / 副作用の局所化 / テストの存在 / 純粋関数と副作用境界 |

※ 可読性は独立軸にはせず、他軸の結果として総括コメントに統合する。

## ワークフロー

### Step 1: base branch を検出する

```bash
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'
```

失敗したら `main` → `master` → `develop` → `trunk` の順で `git rev-parse --verify origin/<name>` を試す。どれも無ければ「base branch を特定できません。リモートの HEAD を設定するか、既知の基幹ブランチ (main/master/develop/trunk) を用意してください」と報告して終了する。

以降 `<base>` は検出したブランチ (例: `origin/master`)。

### Step 2: diff 対象を決める

引数判定は厳密に:

- **引数なし** → `git diff <base>...HEAD --name-status --diff-filter=ACMRT`
- **引数が正規表現 `^[0-9]+$` に一致 (PR 番号)** → `gh pr diff <N> --name-only`。`--name-only` 未対応の古い gh では `gh pr view <N> --json files -q '.files[].path'` にフォールバック
- **それ以外** → branch 名として扱う。`git rev-parse --verify origin/<arg>` または `git rev-parse --verify <arg>` のどちらかが成功すれば `git diff <base>...<arg> --name-status --diff-filter=ACMRT`。両方失敗なら「branch `<arg>` が見つかりません」とエラー終了
- 引数が 2 つ以上渡された場合は**最初の 1 つのみ**を採用

**出力解釈 (引数なし / branch 名ルート):**

- `M <path>` / `A <path>` / `C <path>` / `T <path>` → `<path>` を変更ファイルとして扱う
- `R100 <old> <new>` (rename) → **新パス `<new>`** を変更ファイルとして扱い、`<old>` は finding の location 併記用に保持。finding では `<old> → <new>` の形式で場所を示す

PR 番号ルートでは `--name-only` 系で rename 情報が取れないため、rename 併記はスキップ可。

### Step 3: diff が空なら終了

変更ファイルが 0 件なら「diff が空です。`<base>` と差分のあるブランチで実行してください」と報告して終了。

### Step 4: ファイル数過多のガード

変更ファイル数が **20 を超えたら**「cross-cutting な変更と判断しました。immediate parent directory でグルーピングして分割評価します」と宣言。

グルーピングルール:

- 各変更ファイルの **1 階層上のパス** でグループを作る
- **グループ数が 5 を超えたら** 2 階層上のパスに繰り上げて再グルーピング (5 以下に収束するまで段階的に繰り上げる)
- **リポルートまで繰り上げても 5 以下にならない**稀ケースは、**全体を 1 グループとして扱い** `## Group: <repo root>` セクションで 4 軸並列評価する (分割評価モードは維持、fast path は無効)
- **各グループに対して独立に繰り返すのは Step 5 / 9 / 10 / 11 のみ**。Step 6 (規約 auto-read) / Step 7 (axes 読込) は **全体で 1 回**。Step 8 (fast path 判定) は **分割評価モードでは無効化** (既に大規模と判定済みのため、グループ単位でも 4 軸並列で評価する)
- 最終レポートは `## Group: <path>` で区切って出す
- 軸間トレードオフはグループ内で reconciliation (グループをまたぐ矛盾は report 末尾「全グループ横断の全体総括」に俯瞰コメントとして残す)

### Step 5: 近傍ファイル一覧を取得する

各変更ファイル (rename なら**新パスのみ使用**。旧パス側のディレクトリは `ls` の対象にしない) に対し、同ディレクトリ内のファイル一覧を `ls <dir>` で取得。**パスのリストのみ**を保持し、中身は開かない (subagent が必要時に自分で open する)。

近傍ファイルの扱い:

- ✅ **シグナル源としては利用する**: 変更ファイルの凝集度・結合度を判定するため、近傍にどんなファイルがあるか (種類のバラつき、対応テストの有無、関連 hook の別置き等) を参照する
- ❌ **finding の対象にはしない**: 近傍ファイル**そのもの**への指摘は出さない (例:「近傍の `utilA.ts` が責務過多」は × — 対象が変更ファイルに含まれていないため)。finding の location は**必ず変更ファイルを指す**

### Step 6: リポ規約を auto-read する

存在すれば以下を読む。無ければスキップ。**Step 6 全体の上限: `CLAUDE.md` 1 ファイル + `docs/` 配下 3 ファイル = 計最大 4 ファイル、各先頭 200 行まで**:

- `CLAUDE.md` の先頭 200 行 (1 ファイル枠)
- `docs/` 配下で filename に `architecture` / `coding-standard` / `design` / `convention` を含むファイル (最大 3 ファイル、各先頭 200 行まで、超過分は無視)
- `@`-import / nested CLAUDE.md は **追従しない** (初版)

規約は **参考コンテキスト** 扱い。軸判定は独立させる (規約に引きずられない)。

### Step 7: references/axes/\*.md を読み込む

parent Claude が以下 4 ファイルを Read (skill ベースディレクトリ `~/.claude/skills/arch-review/` 配下):

- `references/axes/cohesion.md`
- `references/axes/coupling.md`
- `references/axes/simplicity.md`
- `references/axes/testability.md`

各ファイルの内容を文字列として保持。subagent はスキルファイルを自動継承しないため、prompt に逐語的に埋め込む。

### Step 8: 小規模 diff の fast path 判定

**分割評価モード (Step 4 発動) ではこのステップをスキップして Step 9 へ進む。**

LoC 取得コマンドは Step 2 の分岐に対応:

- **引数なし** → `git diff --shortstat <base>...HEAD`
- **PR 番号** → `gh pr diff <N> --stat | tail -1` (出力末尾の `X insertions(+), Y deletions(-)` を解釈)
- **branch 名** → `git diff --shortstat <base>...<branch>`

insertions + deletions ≤ 50 **かつ** 変更ファイル数 ≤ 2 なら fast path:

- 1 本の `Explore` subagent に **4 軸定義をまとめて渡して** シーケンシャル評価
- 4 並列の overhead を避ける
- **出力形式は Step 9 の共通テンプレと同一**: 4 軸それぞれの findings を `## 凝集度` `## 結合度` `## シンプルさ` `## テスタビリティ` の 4 セクションに分けて返す (subagent 内部ではシーケンシャルに評価するが出力構造は parallel 時と同じ)

上記に該当しなければ次ステップへ。

### Step 9: 4 軸の subagent を並列起動する

以下 4 本の `Explore` subagent を **同一メッセージ内で並列に** Task 呼び出しで起動:

| subagent       | description                            | prompt の中身                                            |
| -------------- | -------------------------------------- | -------------------------------------------------------- |
| 凝集度         | "Cohesion analysis for arch-review"    | references/axes/cohesion.md の内容 + 共通テンプレ (下記) |
| 結合度         | "Coupling analysis for arch-review"    | references/axes/coupling.md の内容 + 共通テンプレ        |
| シンプルさ     | "Simplicity analysis for arch-review"  | references/axes/simplicity.md の内容 + 共通テンプレ      |
| テスタビリティ | "Testability analysis for arch-review" | references/axes/testability.md の内容 + 共通テンプレ     |

**共通テンプレ (各 prompt の末尾に付与する情報):**

```
---

## 評価対象

変更ファイル (これらに対する findings を出す):
<変更ファイルのパス一覧>

近傍ファイル (参考コンテキスト。パス一覧のみ。必要なら自分で Read する。findings の評価対象にはしない):
<近傍ファイルのパス一覧>

## リポ規約 (参考。軸判定は独立させる)

<Step 6 で読んだ内容、存在すれば>

## 出力形式

references/templates/report.md に準拠した構造化 Markdown で、findings を列挙してください。各 finding に以下を必ず含める:

- **軸タグ (観点タグ)**: 本軸の標準セットから選ぶ
  - 凝集度: `コロケーション` / `SRP` / `責務表現` / `export粒度` / `細切れ過多`
  - 結合度: `依存方向` / `循環依存` / `過剰re-export` / `横断依存` / `import過多` / `depth`
  - シンプルさ: `YAGNI` / `未使用export` / `早期抽象` / `早期generics` / `過剰defensive` / `1箇所抽象`
  - テスタビリティ: `テスト不在` / `副作用の局所化` / `DI` / `純粋関数分離` / `過剰DI`
  - **標準セット外のタグは作らない**。該当する概念が無ければ最寄りのタグを選び、finding の所見本文で具体的に補足する (タグの語彙を揺らがせないため)
- **confidence**: high / mid / low
- **direction**: add (分離/抽象化を要求) / simplify (統合/削除を要求) / neutral (方向性なし)
- **location**: `<file:line>` または `<file>` (ファイル全体指摘)。rename の場合は `<旧path> → <新path>` で併記
- 所見 1-3 行 + 推奨アクション 1-2 行 (コード例は不要)

確信が持てない事項は confidence: low にして「判定保留 (著者の意図次第)」として列挙すること。コードから断言できることだけ high にする。
```

### Step 10: subagent 失敗のフォールバック

いずれかの軸 subagent が失敗・タイムアウトした場合、該当軸セクションを `## <軸名>\n\nN/A (analysis failed: <reason>)` と明示し、他 3 軸のレポートを完成させる。skill 全体は止めない。

### Step 11: 軸間トレードオフの reconciliation

4 軸の Markdown 結果を parent Claude が merge:

**突合キーのルール**:

- finding の location 部分から `<file>` パスのみを抜き出す (行番号 `:line` があれば除去)
- rename 併記 `<old> → <new>` は **新パス `<new>`** を突合キーとして扱う
- 同一ファイルで突合が成立した finding 同士のうち、以下の条件を見る:

1. 全 findings を収集し、軸ごとにセクション化
2. 同一 file path で confidence: high の finding を洗い出し
3. **direction: add と direction: simplify の組み合わせ** があれば「軸間トレードオフ」セクションに抽出 (両方のオリジナル findings も参照できる形で記載)
4. neutral 同士・mid/low の矛盾は各軸セクション内に留める

### Step 12: 優先度付け (改善提案のランク付け)

各 finding に **P1-P4** の優先度ラベルを付与し、レポート冒頭「優先改善提案」セクションに並べる。**新しいメタデータは追加しない** (既存の confidence / direction / 軸の組合せだけで導出する)。

**ランク付けルール (上から順に判定、最初に当たるバケットに入れる)**:

- **P1 (最優先 / Must fix)**: confidence: high の finding が **2 軸以上で同一 location を指摘** している。設計の根幹に関わるため、他の修正より先に判断すべき
  - 突合キーは Step 11 と同じ (`<file>` パスのみ、rename は新パス)。ただし `direction` が **add と simplify の両方を含む組合せ** は P1 に入れず、「軸間トレードオフ」セクションに留める (単純に最優先として並べると誤誘導になるため)
- **P2 (優先 / Should fix)**: confidence: high の単独軸 finding。ただし `direction: neutral` は P3 に落とす (命名・可読性指摘など設計健全性への影響が限定的なもの)
- **P3 (推奨 / Nice to have)**: confidence: mid の全 finding、および P2 から落ちてきた neutral な high finding
- **P4 (判定保留 / 要確認)**: confidence: low の全 finding (既存の「判定保留」セクションと同じ内容を優先度観点で再提示)

**並び順**:

- P1 → P2 → P3 → P4 の降順
- 同一バケット内は **file path の辞書順**。同一 path 内で複数 finding がある場合は **軸名の辞書順** (凝集度 → 結合度 → シンプルさ → テスタビリティ)
- P1 では複数軸の finding を **1 行にまとめず、軸ごとに独立行** で列挙する (各軸の指摘根拠が消えないように)

**出力ルール**:

- 優先改善提案セクションは **冒頭サマリの直下** に置く (Step 13 のテンプレ構造参照)
- 各 finding は軸セクションと **同じ 1 行プレフィックス形式** (`[軸][観点タグ][confidence][direction] <location>`) を使い、先頭に `[P1]`-`[P4]` を追加
- 各 finding の詳細 (所見・推奨アクション) は軸セクションに残したまま、優先改善提案セクションでは **1 行要約のみ** 併記する (重複記載で冗長化しないため)
- 軸間トレードオフ・判定保留セクションは **そのまま残す**。優先改善提案はあくまで「最初に読むべき一覧」で、詳細は既存セクションに委ねる

### Step 13: レポート出力

`references/templates/report.md` の構造に従って最終レポートをコンソールに出力。ファイル書き出しはしない (初版)。

## 安全弁まとめ

- diff 空 → 警告して終了
- ファイル数 > 20 → ディレクトリ分割評価
- subagent 失敗 → 該当軸のみ N/A、他軸は継続
- 近傍ファイルは参照のみ、findings の評価対象にはしない
- rename/move (`--diff-filter=R`) → 新パスを neighbor 起点、finding では「旧 → 新」併記
- 小規模 diff → 4 並列ではなく 1 本の subagent に集約

## 重要な姿勢

- **軸判定はコードから断言できる範囲で**。意図次第で OK な指摘は confidence: low に。
- **規約は参考**。軸判定を規約に引きずられない。
- **修正コード例は書かない**。推奨アクションは 1-2 行の文章まで。
- **バグや型エラーの指摘はしない**。それは別スキルの領分。設計健全性だけに集中する。
