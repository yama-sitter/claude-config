# Tree — 日本語ミラー

> このファイルは人間用の参照ドキュメントです。Claude は英語版 `SKILL.md` を読みます。

## 目的

Claude Code の組み込みツール（EnterWorktree / ExitWorktree）を使って worktree を作成・管理するスキル。

## いつ使うか / 使わないか

**使う場面:**
- worktree の作成・管理（「worktree を作って」「PR をレビューしたい」「X の作業を始めたい」等）
- ユーザーが worktree と開発作業の両方に言及した場合も、worktree のセットアップはこのスキルが担当

**使わない場面:**
- worktree操作を伴わない調査・質問への回答
- ユーザーが superpowers ワークフローを明示的に要求したとき
- `docs/superpowers/plans/` のプランに基づいて実行しているとき

## サブコマンド

| 引数 | アクション |
|---|---|
| `start [説明]` | 説明からブランチ名を自動生成して worktree に入る |
| `checkout <branch>` | 既存ブランチの worktree に直接入る |

## 設計意図

- **EnterWorktree/ExitWorktree ツール使用**: `git worktree` コマンドを直接叩かず、Claude Code の組み込みツールを使う。これにより WorktreeCreate/WorktreeRemove フックが確実に発火する
- **WorktreeCreate フックの自動化**: ブランチ命名・依存関係インストール・.env コピー・`.claude/settings.local.json` コピー（PreToolUse フックが worktree でも適用される）をフックが自動実行
- **git skip との分業**: `/git branch` はリポジトリ内でブランチを作成するだけ。worktree は `/tree` が担当

## ブランチ名のルール

- worktree ディレクトリ名はハイフン形式（例: `feature-user_profile_edit`）
- git ブランチ名はスラッシュ形式（例: `feature/user_profile_edit`）
- WorktreeCreate フックに渡す override ファイルがスラッシュ形式を保持する
