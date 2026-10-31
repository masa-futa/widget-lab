# リポジトリを flutter / swiftui / compose のディレクトリに分ける 実装計画

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 今の Flutter のプロジェクト一式を `flutter/` に移し、ルートには全体の README・CLAUDE.md・.gitignore・構想・全体の ADR だけを置く。

**Architecture:** 追跡しているファイルを `git mv` で移すだけのコミットを先に作り、そのあとで .gitignore と文書を直す。Flutter のコードは 1 行も変えない。spec は `docs/superpowers/specs/2026-10-31-split-into-app-dirs-design.md`。

**Tech Stack:** git、FVM（Flutter 3.47.8）、Python 3（リンクの確かめだけ。コミットしない）

## Global Constraints

- ブランチは `chore/split-into-app-dirs`（作成済み。main の cb45da6 から）。PR は 1 つ
- Flutter のコード・テスト・文書の中身は変えない（直すのはリンクと、CLAUDE.md の構想へのパスとコマンドの添え書きだけ）
- `swiftui/`・`compose/` は作らない
- ルートに残すもの: `README.md`、`CLAUDE.md`、`.gitignore`、`docs/concept/brief.md`、`docs/adr/ADR-0001-three-native-apps-in-one-repo.md`、`docs/superpowers/specs/2026-10-31-split-into-app-dirs-design.md`、`docs/superpowers/plans/2026-10-31-split-into-app-dirs.md`（この計画）
- テストは移す前と同じ「2394 件成功・0 skip」
- リポジトリは public。秘密をコミットしない。`git add -A` や `git add .` は使わず、ファイルを名指しで add する
- コミットの末尾に `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` を付ける
- 文書は日本語。既存の文書の書き方（短い文、「〜する」で終える）に合わせる
- 使い捨てのスクリプトは `/private/tmp/claude-501/-Users-masakifutami-dev-widget-lab-probe/0741b323-254c-4524-b969-4e2651ebc7fb/scratchpad/` に置く

---

### Task 1: Flutter のプロジェクトを `flutter/` に移し、.gitignore を分ける

**Files:**
- Move: `.fvmrc` `.metadata` `.gitignore` `analysis_options.yaml` `l10n.yaml` `pubspec.yaml` `pubspec.lock` `README.md` `CLAUDE.md` `lib/` `test/` `ios/` `android/` `assets/` → `flutter/` の下の同じ名前
- Move: `docs/PRD.md` `docs/architecture.md` `docs/coding-convention.md` `docs/design-system.md` `docs/adr/`（ADR-0001〜0004） `docs/design/` `docs/test/` `docs/superpowers/plans/2026-10-29-property-picker.md` → `flutter/docs/` の下の同じ位置
- Modify: `flutter/.gitignore`（`.superpowers/` の行と、その上のコメントの行を消す）
- Create: `.gitignore`（ルート）

**Interfaces:**
- Consumes: なし
- Produces: `flutter/` で Flutter のコマンドがそのまま動くこと。Task 2 はこの配置を前提にリンクを直す

- [ ] **Step 1: 移す前の基準をとる**

ルートで実行する。

```bash
cd /Users/masakifutami/dev/widget-lab-probe
git status --short   # 何も出ないこと
fvm flutter test 2>&1 | tail -3
```

Expected: 最後の行が `All tests passed!`、その前の行の件数が `+2394`（skip の `~` がない）。違う場合は止めて報告する。

- [ ] **Step 2: リンクを確かめるスクリプトを置き、移す前の結果を残す**

`/private/tmp/claude-501/-Users-masakifutami-dev-widget-lab-probe/0741b323-254c-4524-b969-4e2651ebc7fb/scratchpad/check_links.py` を作る。

```python
"""追跡している .md の相対リンクが、実在するファイル・ディレクトリを指しているか確かめる。"""
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote

root = Path(sys.argv[1]).resolve()
files = subprocess.run(
    ["git", "-C", str(root), "ls-files", "*.md"],
    capture_output=True, text=True, check=True,
).stdout.splitlines()
link = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
broken = []
for rel in files:
    md = root / rel
    if not md.exists():
        continue
    for target in link.findall(md.read_text(encoding="utf-8")):
        if re.match(r"^[a-z]+:", target) or target.startswith("#"):
            continue
        path = unquote(target.split("#", 1)[0])
        if not path:
            continue
        if not (md.parent / path).exists():
            broken.append(f"{rel}: {target}")
print("\n".join(broken) or "OK")
sys.exit(1 if broken else 0)
```

Run:

```bash
python3 -I /private/tmp/claude-501/-Users-masakifutami-dev-widget-lab-probe/0741b323-254c-4524-b969-4e2651ebc7fb/scratchpad/check_links.py . > /private/tmp/claude-501/-Users-masakifutami-dev-widget-lab-probe/0741b323-254c-4524-b969-4e2651ebc7fb/scratchpad/links_before.txt; cat /private/tmp/claude-501/-Users-masakifutami-dev-widget-lab-probe/0741b323-254c-4524-b969-4e2651ebc7fb/scratchpad/links_before.txt
```

Expected: `OK` か、移す前から切れているリンクの一覧。切れているものがあれば、それは今回の作業で直すものではない。Task 2 で「増えていない」ことを比べるために残す。

- [ ] **Step 3: 作られたものを消す**

移す前に、ルートで作られたもの（絶対パスを含む `ios/Flutter/Generated.xcconfig` など）を消す。

```bash
fvm flutter clean
rm -rf build .dart_tool .flutter-plugins-dependencies
git status --short --ignored | grep -v '^!! .superpowers/' || true
```

Expected: `git status` に変更が出ない（`!!` の行は、残っていても移したあとで作り直すので構わない）。

- [ ] **Step 4: `git mv` で移す**

```bash
mkdir -p flutter/docs/superpowers/plans
git mv .fvmrc .metadata .gitignore analysis_options.yaml l10n.yaml pubspec.yaml pubspec.lock README.md CLAUDE.md lib test ios android assets flutter/
git mv docs/PRD.md docs/architecture.md docs/coding-convention.md docs/design-system.md docs/adr docs/design docs/test flutter/docs/
git mv docs/superpowers/plans/2026-10-29-property-picker.md flutter/docs/superpowers/plans/
git status --short | grep -v '^R ' || true
```

Expected: 最後のコマンドの出力が空（全部が `R`＝名前の変更）。ルートの `docs/` には `concept/brief.md`、`superpowers/specs/2026-10-31-split-into-app-dirs-design.md`、`superpowers/plans/2026-10-31-split-into-app-dirs.md` だけが残る。

```bash
git ls-files docs
```

Expected: その 3 つだけ。

- [ ] **Step 5: 移すだけのコミット**

```bash
git commit -m "chore: Flutter のプロジェクト一式を flutter/ に移す

中身は変えず、場所だけを移す。git log --follow で移す前の履歴を追える。

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git show --stat HEAD | grep -c '=>'
```

Expected: コミットが 1 つでき、`=>`（名前の変更）が 647（追跡している 650 件から、ルートに残る 3 つを引いた数）。`git show --stat HEAD` に `+` や `-` の行数の変化がないこと。

- [ ] **Step 6: `.gitignore` を分ける**

`flutter/.gitignore` の最後にある次の 2 行を消す（ルートの .gitignore に移すため）。秘密の行は残す。

```
# ブレインストーミングの見本（visual companion）
.superpowers/
```

ルートに `.gitignore` を作る。

```
# リポジトリ全体に効くものだけ。アプリごとのものは各ディレクトリの .gitignore に置く

# Miscellaneous
.DS_Store

# Secrets (never commit)。アプリの .gitignore にも同じ行を置く
.env
*.env
*.jks
*.keystore
key.properties
*.p8
*.p12
*.mobileprovision

# ブレインストーミングの見本（visual companion）
.superpowers/
```

- [ ] **Step 7: `flutter/` で作り直して確かめる**

```bash
cd /Users/masakifutami/dev/widget-lab-probe/flutter
fvm flutter pub get && fvm dart run build_runner build
fvm dart format --set-exit-if-changed . && fvm flutter analyze && fvm flutter test 2>&1 | tail -3
```

Expected: format の差分なし、analyze が `No issues found!`、test が Step 1 と同じ `+2394` と `All tests passed!`。

```bash
fvm flutter build ios --release --no-codesign 2>&1 | tail -3
```

Expected: `✓ Built build/ios/iphoneos/Runner.app` のような成功の行。

```bash
cd /Users/masakifutami/dev/widget-lab-probe
git status --short
```

Expected: `M flutter/.gitignore` と `?? .gitignore` の 2 行だけ（作り直した `flutter/build/`・`flutter/.dart_tool/` などが出てこない）。ほかの行が出たら、.gitignore の抜けなので止めて報告する。

- [ ] **Step 8: コミット**

```bash
git add .gitignore flutter/.gitignore
git commit -m "chore: .gitignore をリポジトリ全体と flutter/ に分ける

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: ルートの文書を足し、flutter/ の文書のリンクを直す

**Files:**
- Create: `README.md`（ルート）
- Create: `CLAUDE.md`（ルート）
- Create: `docs/adr/ADR-0001-three-native-apps-in-one-repo.md`
- Modify: `flutter/CLAUDE.md:3` と `## コマンド` の節
- Check: `flutter/README.md`（リンクが切れていたら直す）

**Interfaces:**
- Consumes: Task 1 の配置（`flutter/` の下に一式、ルートの `docs/` に 3 つ）
- Produces: なし（最後のタスク）

- [ ] **Step 1: ルートの `README.md` を作る**

```markdown
# Widget Lab

UI フレームワークの部品を、プロパティを付けた／付けないで触って比べられるアプリ群です。フレームワークごとに別のアプリとして作り、このリポジトリにまとめています。

| アプリ | ディレクトリ | 対象 | 状態 |
| --- | --- | --- | --- |
| Flutter 版 | [flutter/](flutter/README.md) | iOS / Android | あり |
| SwiftUI 版 | swiftui/ | iOS | 準備中 |
| Jetpack Compose 版 | compose/ | Android | 準備中 |

- 構想: [docs/concept/brief.md](docs/concept/brief.md)
- アプリをまたぐ判断: [docs/adr/](docs/adr/ADR-0001-three-native-apps-in-one-repo.md)

起動の手順は、各アプリの README を見てください。
```

- [ ] **Step 2: ルートの `CLAUDE.md` を作る**

```markdown
# Widget Lab（リポジトリ全体）

UI フレームワークの部品を触って比べるアプリ群。フレームワークごとに別のアプリとして、ディレクトリを分けて置く。

## アプリ
- `flutter/`: Flutter 版（iOS / Android）。作業の前に flutter/CLAUDE.md を読む
- `swiftui/`: SwiftUI 版（iOS）。準備中
- `compose/`: Jetpack Compose 版（Android）。準備中

## 決まり
- 作業するアプリのディレクトリに入り、そのディレクトリの CLAUDE.md に従う。コマンドもそのディレクトリで実行する
- アプリをまたぐ判断は docs/adr/ に、またぐ作業の spec・計画は docs/superpowers/ に置く。アプリの中だけの判断・spec・計画は、そのアプリの docs/ に置く
- ADR の番号は、ルートとアプリごとに別に振る
- 構想: docs/concept/brief.md

## 公開について
- リポジトリは public。署名鍵・ストアの認証情報・`.env` などをコミットしない（ルートと各アプリの `.gitignore` で除外済み）
```

- [ ] **Step 3: ルートの ADR を作る**

`docs/adr/ADR-0001-three-native-apps-in-one-repo.md`:

```markdown
# ADR-0001: Flutter / SwiftUI / Jetpack Compose を別のアプリにして、1 つのリポジトリに並べる

> **要約**
> - 結論: SwiftUI 版と Jetpack Compose 版は、Flutter 版に埋め込まず、別のネイティブアプリとして作る。3 つは 1 つのリポジトリの `flutter/`・`swiftui/`・`compose/` に置く
> - 影響: 今の Flutter のプロジェクト一式を `flutter/` に移す。ルートには全体の README・CLAUDE.md・.gitignore・構想・この ADR を置く
> - お願い: なし（2026-10-31 オーナーが選んだ）

## ステータス
承認済み（2026-10-31）

## 背景
Flutter 版（公式 Widget カタログの全 Widget を収録）ができ、SwiftUI と Jetpack Compose のコンポーネントも同じように触って確かめたくなった。

SwiftUI は Apple の OS にある SwiftUI・UIKit の上で、Jetpack Compose は Android の View の仕組みと部品の上で動く。Flutter の PlatformView は、動いている OS の部品を埋め込む仕組みなので、もう一方の OS の部品は描けない。

## 決定
- SwiftUI 版（iOS）と Jetpack Compose 版（Android）は、それぞれ別のネイティブアプリとして作る
- 3 つを 1 つのリポジトリに置き、アプリごとにディレクトリを分ける（`flutter/`・`swiftui/`・`compose/`）
- アプリをまたぐもの（構想・この種の判断・またぐ作業の spec と計画）はルートの `docs/` に、アプリの中だけのものは各アプリの `docs/` に置く。ADR の番号はルートとアプリで別に振る
- 何を収録するかなど、SwiftUI 版・Compose 版の中身は、それぞれ作るときに決める

## 選ばなかった案
- 1 つの Flutter アプリに PlatformView で埋め込み、端末ごとに選べるものを変える（iPhone は Flutter／SwiftUI、Android は Flutter／Compose）: 本物を触れるが、1 台でもう一方の OS の部品は見られない。Flutter・Swift・Kotlin のビルドを 1 つのアプリで抱える
- 1 つのアプリにして、端末で動かないほうはスクリーンショットとコードだけ見せる: 触って確かめるという目的に合わない
- Compose Multiplatform で iOS にも Compose を出す: Android の Jetpack Compose と見た目・動き（文字の描き方・スクロールの感触・一部の部品）が一致しない。Flutter・Swift・Kotlin/Native の 3 つのビルドを抱え、保守が重い。Android で SwiftUI を動かす方法はない（Skip などは SwiftUI のコードを Compose に置き換えるもので、本物ではない）
- アプリごとに別のリポジトリにする: 構想と判断を 1 か所で見られなくなる。1 人で作るので、分ける利点が小さい

## 結果
- 各アプリは、その OS の本物の部品で作れる。プラットフォームをまたぐビルドの仕組みが要らない
- 作る量は、アプリごとにほぼ丸ごと要る（収録の一覧・プロパティの定義・デモの組み立て）
- Flutter のコマンドは `flutter/` で実行するようになる
```

- [ ] **Step 4: `flutter/CLAUDE.md` を直す**

3 行目の `構想は docs/concept/brief.md。` を、次に置き換える。

```
構想はリポジトリのルートの ../docs/concept/brief.md（全体の決まりは ../CLAUDE.md）。
```

`## コマンド` の見出しのすぐ下の行に、次の 1 行を足す。

```
- コマンドはすべて `flutter/` で実行する
```

- [ ] **Step 5: リンクを確かめる**

```bash
cd /Users/masakifutami/dev/widget-lab-probe
python3 -I /private/tmp/claude-501/-Users-masakifutami-dev-widget-lab-probe/0741b323-254c-4524-b969-4e2651ebc7fb/scratchpad/check_links.py .
```

Expected: `OK`。Task 1 Step 2 で切れていたリンクがあった場合は、`flutter/` を前に付けた同じ一覧になっていて、それより増えていないこと。増えていたら、そのリンクを直してからもう一度実行する（`flutter/README.md` のリンクもここで確かめられる）。

`lib`・`test` の中の docs への参照も確かめる。

```bash
cd /Users/masakifutami/dev/widget-lab-probe/flutter
grep -rhoE 'docs/[^ `)"'"'"']+\.md' lib test | sort -u | while read p; do [ -e "$p" ] || echo "MISSING $p"; done
```

Expected: 何も出ない。

- [ ] **Step 6: コミット**

```bash
cd /Users/masakifutami/dev/widget-lab-probe
git add README.md CLAUDE.md docs/adr/ADR-0001-three-native-apps-in-one-repo.md flutter/CLAUDE.md
git status --short   # 何も出ないこと
git commit -m "docs: リポジトリ全体の README・CLAUDE.md と、アプリを分ける ADR を足す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

- [ ] **Step 7: 最後に全体を確かめる**

```bash
cd /Users/masakifutami/dev/widget-lab-probe
ls -A   # .git .gitignore .superpowers CLAUDE.md README.md docs flutter だけ
git ls-files | grep -v '^flutter/'
```

Expected: 2 つめのコマンドの出力は次の 7 行だけ（並びは問わない）。

```
.gitignore
CLAUDE.md
README.md
docs/adr/ADR-0001-three-native-apps-in-one-repo.md
docs/concept/brief.md
docs/superpowers/plans/2026-10-31-split-into-app-dirs.md
docs/superpowers/specs/2026-10-31-split-into-app-dirs-design.md
```
