# Research — 日本語ミラー

> このファイルは人間用の参照ドキュメントです。Claude は英語版 `SKILL.md` を読みます。

## 目的

リサーチの「設計」フェーズを協調的なスパーリングで支援するスキル。RQ（リサーチクエスチョン）の構築・リサーチ計画の設計・インタビューガイドの作成・サーベイ設計を行う。

「Product Research Rules」4ステップフレームワークをベースに、FINERクライテリア・Known/Unknownマトリクス等を重ね合わせる。

## いつ使うか / 使わないか

**使う場面:**
- 何を・どうやって調査するかを設計するとき

**使わない場面:**
- 収集済みデータの分析（→ dex）

## サブコマンド

| 引数 | アクション |
|---|---|
| (なし) | サブコマンドガイドを表示 |
| `rq` | リサーチクエスチョン構築のスパーリング |
| `plan` | リサーチ計画の設計 |
| `interview` | インタビューガイドの作成 |
| `survey` | サーベイ質問の設計 |

## 設計意図

- **設計フェーズ専門**: データ収集・分析ではなく「何を調査するか」の設計に特化。下流スキル（dex）に接続できる
- **スパーリング形式**: 一方的に出力するのではなく、対話を通じてリサーチ設計を洗練させる
- **フレームワーク参照**: `references/` 配下に各フレームワーク（FINER・PICO・Known/Unknown等）の詳細が格納されている

## references/ の役割

`references/` 配下の各ファイルはリサーチ設計の評価基準・フレームワークを定義する。スキルの設計を改善する際には参照が必要。例:
- `finer-criteria.md` — Feasible/Interesting/Novel/Ethical/Relevant の評価基準
- `pico-framework.md` — Population/Intervention/Comparison/Outcome のフレームワーク
- `rq-antipatterns.md` — RQ設計の失敗パターン集
- `interview-design.md` — インタビュー設計の原則
- `survey-design.md` — サーベイ設計の原則
