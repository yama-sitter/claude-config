#!/bin/bash
# PreToolUse (Bash) hook: sandbox.excludedCommands のマッチを壊す Bash 呼び出しをブロックする（コマンド非依存）
#
# excludedCommands は「呼び出し内の全コマンドがマッチ」し、かつファイルへのリダイレクト・cd・
# コマンド置換などを含まない場合にだけサンドボックス外で実行される
# （https://code.claude.com/docs/en/settings-reference#sandbox-excludedcommands）。
# 除外コマンドに非除外コマンドやこれらの構文を混ぜると呼び出し全体がサンドボックス内で実行され、
# ネットワーク拒否 / x509 / SSH 署名失敗 / ファイル読み取り失敗になる。
#
# stdin: PreToolUse の JSON（.tool_input.command にコマンド文字列が入る）
# exit 2 + stderr: ブロックし、理由を Claude に伝える
# exit 0: 素通り

CMD=$(jq -r '.tool_input.command // empty')
[ -z "$CMD" ] && exit 0

# excludedCommands を全スコープから集める（存在しないファイルは無視）
PROJ="${CLAUDE_PROJECT_DIR:-$PWD}"
PATTERNS=()
for f in "$HOME/.claude/settings.json" "$PROJ/.claude/settings.json" "$PROJ/.claude/settings.local.json" \
  "/Library/Application Support/ClaudeCode/managed-settings.json"; do
  [ -f "$f" ] || continue
  while IFS= read -r p; do
    [ -n "$p" ] && PATTERNS+=("$p")
  done < <(jq -r '.sandbox.excludedCommands[]? // empty' "$f" 2>/dev/null)
done
[ ${#PATTERNS[@]} -eq 0 ] && exit 0

# Bash(...) 権限ルールと同じ構文で 1 セグメントを 1 パターンに照合する
# - * なし: 完全一致 / 末尾 :* は末尾 " *" と同じ / 末尾 " *" が唯一のワイルドカードなら引数なしにもマッチ
match_pat() {
  local seg=$1 pat=$2 rest
  [[ $pat == *':*' ]] && pat="${pat%:\*} *"
  if [[ $pat != *'*'* ]]; then
    [[ $seg == "$pat" ]]
    return
  fi
  rest=${pat%' *'}
  if [[ $pat == *' *' && $rest != *'*'* && $seg == "$rest" ]]; then
    return 0
  fi
  # shellcheck disable=SC2053
  [[ $seg == $pat ]]
}

# 前処理: 行継続を除去 → 改行を ; に → シングルクォート内を除去（$() 判定用）→ ダブルクォート内を除去
# （-m "fix: a; b" や --jq '.a | .b' のような引用符内の記号を誤検知しないため）
S1=$(printf '%s' "${CMD//$'\\\n'/ }" | tr '\n' ';' | sed -E "s/'[^']*'/Q/g")
# コマンド置換はダブルクォート内でも有効なのでここで判定し、サブシェル ( はクォート除去後に判定する
# （"feat(scope): x" のようなコミットメッセージを誤検知しないため）
SUBST=0
printf '%s' "$S1" | grep -qE '\$\(|`' && SUBST=1
S2=$(printf '%s' "$S1" | sed -E 's/"[^"]*"/Q/g')
printf '%s' "$S2" | grep -qE '\(' && SUBST=1
# fd の複製（2>&1, >&2 など）はマッチを壊さないので除去し、残った < > をファイルリダイレクトとみなす
S3=$(printf '%s' "$S2" | sed -E 's/[0-9]*[<>]&[0-9-]+//g')
REDIRECT=0
printf '%s' "$S3" | grep -qE '[<>]' && REDIRECT=1

# 区切り（&& || |& ; | &）と $( ( ) ` でセグメントに分割し、空白を正規化して照合する
# （echo $(gh ...) の内側の gh もセグメントとして拾うため）
MATCHED=()
UNMATCHED=()
HAS_CD=0
while IFS= read -r seg; do
  seg=$(printf '%s' "$seg" | tr -s '[:space:]' ' ' | sed -E 's/^ //; s/ $//')
  [ -z "$seg" ] && continue
  case "$seg" in cd | cd\ * | pushd* | popd*) HAS_CD=1 ;; esac
  hit=0
  for p in "${PATTERNS[@]}"; do
    if match_pat "$seg" "$p"; then
      hit=1
      break
    fi
  done
  if [ $hit -eq 1 ]; then MATCHED+=("$seg"); else UNMATCHED+=("$seg"); fi
done < <(printf '%s\n' "$S3" | perl -pe 's/&&|\|\||\|&|;|\||&|\$\(|[()`]/\n/g')

# 除外コマンドが無ければ通常のサンドボックス実行なので素通り
[ ${#MATCHED[@]} -eq 0 ] && exit 0

REASONS=()
[ ${#UNMATCHED[@]} -gt 0 ] && REASONS+=("除外対象外のコマンドとの連結")
[ $REDIRECT -eq 1 ] && REASONS+=("ファイルへのリダイレクト")
[ $SUBST -eq 1 ] && REASONS+=("コマンド置換 / サブシェル（\$() / バッククォート / ( )）")
[ $HAS_CD -eq 1 ] && REASONS+=("cd / pushd / popd")
[ ${#REASONS[@]} -eq 0 ] && exit 0

{
  echo "BLOCKED: この呼び出しは sandbox.excludedCommands にマッチせず、全体がサンドボックス内で実行されます（ネットワーク拒否 / x509 / SSH 署名失敗 / ファイル読み取り失敗の原因）。"
  echo "理由: $(IFS='、'; echo "${REASONS[*]}")"
  echo "除外対象にマッチ: $(printf '[%s] ' "${MATCHED[@]}")"
  [ ${#UNMATCHED[@]} -gt 0 ] && echo "マッチしない: $(printf '[%s] ' "${UNMATCHED[@]}")"
  echo "対処: 除外コマンドは単独の Bash 呼び出しで実行してください（他の除外コマンドとの && 連結と 2>&1 は可）。出力の絞り込みは | head 等ではなくツール自身のフラグ（--json / --jq / --name-only など）を使い、後処理は別の呼び出しで行ってください。git commit のメッセージは -m \"...\"（\$ やバッククォートなし）か Write で書いたファイルを -F で渡してください。迂回手段やユーザーへの ! 実行依頼は不要です。"
} >&2
exit 2
