# Widget Lab

Flutter の公式 Widget カタログに載る Widget を、プロパティを付けた／付けないで触って比べられる iOS / Android アプリです。要件は [docs/PRD.md](docs/PRD.md)。

## 起動の手順
1. FVM を入れる（https://fvm.app）
2. `fvm install`（`.fvmrc` の版が入る）
3. `fvm flutter pub get && fvm dart run build_runner build`、続けて `fvm flutter run`（`android/` の Gradle のラッパーなど、Flutter の標準の `.gitignore` で除いたものは、初回の `flutter run` で作り直されます）

## 設計判断
- 1パッケージで、`lib/features/<機能>/` に画面、`lib/catalog/<ジャンル>/` に収録する Widget の定義を置く
- 状態は Riverpod。プロパティの値と比較の状態は Widget ごとの Notifier に持ち、プレビュー・操作パネル・比較・コードで共有する
- 遷移は標準の Navigator（ディープリンク・タブがないため）
- UI の文言は gen-l10n、Widget の説明文は収録データに置く
- 詳しくは [docs/adr/ADR-0001-project-structure-and-conventions.md](docs/adr/ADR-0001-project-structure-and-conventions.md)

## 進め方
メインで順に進める。

## AI の使い方
（案件の終わりに書く）

## テストの結果
2026-10-28（土台の時点）: `flutter test` 2件すべて成功、`flutter analyze` 問題なし、`dart format` 差分なし。テストケースごとの結果は docs/test/test-cases.md（設計の段で作る）

## 未対応のこと
（案件の終わりに書く）
