# コーディング規約

## 使う部品
| 用途 | 部品 | 備考 |
|---|---|---|
| 構成 | 1パッケージ・機能ごと | `lib/core/`・`lib/features/<機能>/{ui,view_model,data}`・`lib/catalog/<ジャンル>/` |
| 状態 | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)・[riverpod_annotation](https://pub.dev/packages/riverpod_annotation)・[riverpod_generator](https://pub.dev/packages/riverpod_generator) | ①画面の中だけの一時的な状態は StatefulWidget、②画面をまたぐ状態は Notifier、③依存の受け渡しも Provider。①を Notifier に流し込まない |
| 遷移 | 標準の Navigator | `Navigator.push` と `MaterialPageRoute` |
| モデル | 手書きの不変クラス | `final` のフィールド、`==` と `hashCode` |
| 文言 | gen-l10n（`lib/l10n/app_ja.arb`） | UI の文言は ARB に置く。Widget とプロパティの説明文は `lib/catalog/` の定義に置く |
| 余白 | [gap](https://pub.dev/packages/gap) | Row・Column の中の余白は `Gap` |
| テーマ | Material 3 の `ThemeData`＋土台の拡張（`NimiColors`・`NimiSpacing`・`NimiRadius`・`NimiTextStyles`） | 色は `Theme.of(context).colorScheme` と `NimiColors.of(context)`、余白は `NimiSpacing.of(context)`、角丸は `NimiRadius.of(context)`、コードの文字は `NimiTextStyles.of(context).code`。値は docs/design-system.md |
| lint | flutter_lints＋strict＋[riverpod_lint](https://pub.dev/packages/riverpod_lint) | `analysis_options.yaml` |
| リンク | [url_launcher](https://pub.dev/packages/url_launcher) | 公式の API ドキュメントを開くときだけ。ほかに通信しない |

## 書き方
- Effective Dart の命名。import は `package:` で書く
- `!` は原則使わない。状態とエラーは sealed class で網羅する
- `build` が長くなったら、関数ではなく小さな Widget クラスに分ける。変わらないものに `const`
- Widget は表示とイベントの受け渡しだけ。条件分岐・整形・保存は ViewModel へ。Widget からデータ層を直接触らない
- 色・文字・余白は `Theme.of(context)` とテーマの拡張から取る（直書きしない）。ただし収録する Widget のデモの中身はこの限りでない
- 文言は ARB に置く（直書きしない）。収録データの説明文を除く
- `print` を使わない。ログに個人情報・トークンを出さない

## テスト
- 層ごとに書く。純粋なロジック・Notifier・Repository は unit を必ず、画面と使い回す部品は widget を2段で（画面は状態ごとに ProviderScope の overrides、部品は部品だけを包む）。偽物は fake を優先し、要るときだけ mocktail
- 実装の前にテストケース（`docs/test/test-cases.md`）を書き、テストの名前を `TC-01: …` で始める。要件ごとに単体か widget のテストを最低1本
- 生成物（`*.g.dart`・`lib/l10n/gen/`）はコミットする
