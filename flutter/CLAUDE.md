# Widget Lab

Flutter の公式 Widget カタログに載る Widget を、プロパティを付けた／付けないで触って比べられる iOS / Android アプリ。要件は docs/PRD.md、構想は docs/concept/brief.md。

## スタック
- Flutter 3.47.8（FVM。`.fvmrc` で固定）/ Dart 3.13.7
- 状態: Riverpod（riverpod_generator）/ 遷移: 標準の Navigator / モデル: 手書きの不変クラス / 文言: gen-l10n（ARB）
- 対象: iOS 26.0 以上 / Android minSdk 35。日本語のみ。オフラインのみ

## コマンド
- 準備: `fvm flutter pub get && fvm dart run build_runner build`
- 確かめ: `fvm dart format --set-exit-if-changed . && fvm flutter analyze && fvm flutter test`
- 起動: `fvm flutter run`

## 規約
- 構成と依存の向き: docs/architecture.md
- コーディングと使う部品: docs/coding-convention.md
- 決めた理由: docs/adr/
- 新しい画面は lib/features/<機能>/{ui,view_model,data} に置き、test/features/<機能>/ にテストを置く
- 収録する Widget の定義（プロパティ・説明文）は lib/catalog/<ジャンル>/ に置く

## 公開について
- リポジトリは public。署名鍵・ストアの認証情報・`.env` などをコミットしない（`.gitignore` で除外済み）
