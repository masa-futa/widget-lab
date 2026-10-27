# アーキテクチャ

## 構成

```
lib/
  main.dart                 ProviderScope でアプリを包んで起動する
  app.dart                  MaterialApp（テーマ・l10n・最初の画面）
  core/
    theme/                  Material 3 のテーマと ThemeExtension（AppSpacing）
  l10n/
    app_ja.arb              UI の文言
    gen/                    gen-l10n の生成物（コミットする）
  catalog/
    <ジャンル>/             収録する Widget の定義（プロパティ・説明文・デモの組み立て）
  features/
    catalog/{ui,view_model,data}   ジャンル別の一覧と検索
    detail/{ui,view_model,data}    詳細（プレビュー・操作パネル・比較・コード）
test/
  app_test.dart             起動とテーマ
  features/<機能>/          機能ごとのテスト（lib と同じ形）
```

## 依存の向き
ui → view_model → data（Repository）。逆向きと、機能をまたぐ直接の参照は禁止（共通のものは lib/core/ に置く）。
`lib/catalog/` は収録データで、features の data（Repository）だけが読む。ui から直接読まない。

## 状態と依存の受け渡し
- Provider は riverpod_generator（`@riverpod`）で、各機能の view_model / data に置く
- 詳細のプロパティの値と比較の状態は、Widget ごとの family の Notifier に持つ（プレビュー・操作パネル・比較・コードの4か所で共有するため）
- 検索欄の入力中の文字など、画面の中だけの一時的な状態は StatefulWidget に持つ
- テストでは `ProviderScope(overrides: [...])` で Repository を fake に差し替える

## 遷移
標準の Navigator（`Navigator.push` と `MaterialPageRoute`）。一覧 → 詳細の1段だけ。

決めた理由は docs/adr/ の最初の ADR（ADR-0001-project-structure-and-conventions.md）
