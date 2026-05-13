# Git ガイドライン（日本語ミラー）

> **このファイルは人間用のミラーです。** Claude は英語正本 (`git-guidelines.md`) を読みます。

## 禁止事項

- Claude の co-author フッター（`Co-Authored-By: Claude`、`Generated with Claude Code`）を追加しない
- ステージングされていない変更をコミットに含めない

## ブランチ命名

`<type>/<summary>`

- `<type>`：feature, fix, docs, style, refactor, test, chore
- `<summary>`：変更内容を snake_case で簡潔に表現

例：`feature/user_profile_edit`、`fix/login_bug`

> **注意（Worktree）**: EnterWorktree はディレクトリ名に `/` を受け付けないため、worktree ディレクトリはハイフン形式を使用する（例：`feature-user_profile_edit`）。git ブランチ名はオリジナルのスラッシュ形式を維持する（`feature/user_profile_edit`）。WorktreeCreate hook に渡すオーバーライドファイルで実現する。

## コミットメッセージ

```
<type>: <summary>

<詳細説明>
```

- コミットメッセージは**日本語**で書く
- 1コミット、1目的
- コミットが複数の意図を含む場合は `git add -p` で分割する

> **Rationale**: 日本語コミットメッセージはリポジトリオーナーが日本語話者であるため。1コミット1目的は `git bisect` や `git revert` の粒度を適切に保つため。

## PR タイトル

`<type>: <short description>`

- プロジェクトに `.github/PULL_REQUEST_TEMPLATE.md` がある場合はそれに従う

## サンドボックス制約

- `git rebase`、`git rebase --continue`、`git rebase --abort` は Bash ツールで**絶対に実行しない**
  - サンドボックスがドットファイルの作成をブロックするため、rebase の状態が取り返しのつかない形で壊れる
  - 必ずユーザーに `!` プレフィックス付きで実行してもらう：`! git rebase <args>`

> **Rationale**: Claude Code のサンドボックス環境は `.git/rebase-merge/` 等の一時ファイルを書けないため、rebase を途中まで実行すると repository が壊れた状態になる。ユーザーのローカルシェルでは問題なく動く。
