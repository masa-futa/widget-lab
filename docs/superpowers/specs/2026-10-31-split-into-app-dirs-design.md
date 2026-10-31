# リポジトリを Flutter / SwiftUI / Compose のディレクトリに分ける

> **要約**
> - 結論: 今の Flutter のプロジェクト一式を `flutter/` に移し、ルートには全体の README・CLAUDE.md・構想・全体の ADR だけを置く。`swiftui/`・`compose/` は後の作業で作る
> - 影響: すべてのファイルの場所（中身は変えない）。コマンドは `flutter/` で実行するようになる
> - お願い: なし（2026-10-31 オーナーが形を承認）

## 背景
SwiftUI と Jetpack Compose のコンポーネントも触って確かめたい。Flutter のアプリに埋め込む案も考えたが、SwiftUI は iOS、Compose は Android でしか本物が動かない。そのため、3 つを別のアプリとして作り、1 つのリポジトリに並べることにした（理由と比べた案は ADR-0001 に書く）。

全体の進め方は次の 3 つで、1 つずつ spec → 計画 → 実装と進める。この spec は 1 だけを扱う。

1. リポジトリの組み替え（この spec）
2. SwiftUI 版を `swiftui/` に作る（何を収録するかから、別の brainstorming で決める）
3. Compose 版を `compose/` に作る（同じく別に決める）

## 完成の形

```
widget-lab/
├── README.md        全体の紹介と 3 つのアプリへの案内
├── CLAUDE.md        全体の決まり
├── .gitignore       全体に効くものだけ
├── docs/
│   ├── concept/brief.md                     （今の場所のまま）
│   ├── adr/ADR-0001-three-native-apps-in-one-repo.md
│   └── superpowers/specs/2026-10-31-split-into-app-dirs-design.md  （この spec）
└── flutter/         今のプロジェクト一式
    ├── README.md, CLAUDE.md, .gitignore, .fvmrc, .metadata
    ├── pubspec.yaml, pubspec.lock, analysis_options.yaml, l10n.yaml
    ├── lib/, test/, ios/, android/, assets/
    └── docs/        PRD・architecture・coding-convention・design-system・design/・test/・adr/（0001〜0004）・superpowers/plans/
```

`swiftui/` と `compose/` はこの作業では作らない（空のディレクトリは git に残らないため）。

## 移し方
- 追跡しているファイルは `git mv` で移す。中身を変えずに移すコミットと、中身を直すコミットを分ける。こうすると、`git log --follow` で移す前の履歴を追える
- 移すもの: `.fvmrc`、`.metadata`、`analysis_options.yaml`、`l10n.yaml`、`pubspec.yaml`、`pubspec.lock`、`README.md`、`CLAUDE.md`、`lib/`、`test/`、`ios/`、`android/`、`assets/`、`docs/` のうち `concept/` と `superpowers/specs/` 以外の全部
- 追跡していない作られたもの（`build/`、`.dart_tool/`、`.flutter-plugins-dependencies`、`ios/Pods` など）は移さない。ルートから消し、`flutter/` で `pub get`・`build_runner` を実行して作り直す
- `lib`・`test` の中の docs への参照（`docs/...` の書き方、15 か所）は、プロジェクトのルートからの相対パスなので直さなくてよい。`flutter/docs/` に移ったあともそのまま通る

## .gitignore
- `flutter/.gitignore`: 今の .gitignore の Flutter の分（`/build/`、`/android/app/debug` など、ルートからの位置を決めた書き方があるもの）と、IDE・FVM の分
- ルートの `.gitignore`: 全体に効くものだけ。秘密（`.env`、`*.env`、`*.jks`、`*.keystore`、`key.properties`、`*.p8`、`*.p12`、`*.mobileprovision`）、`.DS_Store`、`.superpowers/`
- 秘密の行はルートに置いた上で、`flutter/.gitignore` にも残す（どちらかを消しても漏れないように）

## 文書
- ルートの `README.md`: 何のリポジトリか（Flutter・SwiftUI・Jetpack Compose の部品を、プロパティを付けた／付けないで触って比べるアプリ群）と、アプリごとの表（ディレクトリ・状態・README へのリンク）。今は flutter だけ「あり」、swiftui・compose は「準備中」
- ルートの `CLAUDE.md`: 全体の決まりだけ。作業するアプリのディレクトリに入って、その CLAUDE.md に従うこと／アプリをまたぐ判断はルートの `docs/adr/`、またぐ作業の spec・計画はルートの `docs/superpowers/` に置くこと／公開リポジトリなので秘密をコミットしないこと
- `flutter/CLAUDE.md`: 今の内容のまま。構想へのリンクを `../docs/concept/brief.md` に直し、コマンドは `flutter/` で実行すると書き添える
- `flutter/README.md`: 今の内容のまま。リンクが切れていないかだけ確かめる
- ルートの `docs/adr/ADR-0001-three-native-apps-in-one-repo.md`: 書式は今の ADR（要約・ステータス・背景・決定・比べた案）に合わせる。比べた案は次の 4 つ
  - A: 1 つの Flutter アプリに埋め込み、端末ごとに選べるものを変える（もう一方の OS の本物は見られない）
  - B: 別のネイティブアプリにする（採用）
  - C: 1 つのアプリにして、動かないほうはスクリーンショットとコードだけ見せる（触れない）
  - Compose Multiplatform で iOS にも Compose を出す（Android の本物と見た目・動きが一致しない。Flutter・Swift・Kotlin/Native の 3 つのビルドを抱えて保守が重い）
- ADR の番号はルートと `flutter/` で別に振る。ルートは 0001 から

## 確かめ方
- `flutter/` で `fvm flutter pub get && fvm dart run build_runner build` のあと、`fvm dart format --set-exit-if-changed . && fvm flutter analyze && fvm flutter test` が通る。テストは移す前と同じ件数（2394 件成功・0 skip）
- `flutter/` で `fvm flutter build ios --release --no-codesign` が通る
- Markdown の相対リンク（ルートと `flutter/` の全 .md）が、全部実在するファイルを指している。小さなスクリプトで機械的に確かめる（スクリプトはコミットしない）
- `git status` に、作り直したもの（`build/` など）が出てこない（.gitignore が効いている）

## 進め方
- ブランチ `chore/split-into-app-dirs`（main から）。PR は 1 つ
- コミットは「移すだけ」「.gitignore を分ける」「文書を直す・足す」に分ける

## やらないこと
- `swiftui/`・`compose/` のプロジェクトを作ること（2・3 で行う）
- Flutter のコードや文書の中身を書き換えること（リンクの直し以外）
- CI を足すこと（今もない）
