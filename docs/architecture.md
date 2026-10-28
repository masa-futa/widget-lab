# アーキテクチャ

## 構成

```
lib/
  main.dart                 ProviderScope でアプリを包んで起動する
  app.dart                  MaterialApp（テーマ・l10n・最初の画面）
  core/
    theme/                  Material 3 のテーマと ThemeExtension（土台の NimiColors・NimiSpacing・NimiRadius・NimiTextStyles）
    data/                   両方の機能が使う CatalogRepository と、OS の機能の包み（ClipboardClient・UrlLauncherClient）
  l10n/
    app_ja.arb              UI の文言
    gen/                    gen-l10n の生成物（コミットする）
  catalog/
    model/                  収録データの型（WidgetEntry・PropertySpec・PropertyControl など）
    genres.dart             公式カタログのジャンル（並びはリストの順）
    manifest.dart           公式カタログに載る Widget 名の一覧（抜けの確認用）
    catalog.dart            全件の一覧
    <ジャンル>/             1 Widget = 1 ファイルの収録データ（プロパティ・説明文・組み立ての関数）。複数のジャンルに載るものは最初のジャンルに置く
  features/
    catalog/{ui,view_model,data}   ホーム（ジャンルのタイルと検索）とジャンル画面
    detail/{ui,view_model,data}    詳細（プレビュー・チップ・編集パネル・比較・コード）
test/
  app_test.dart             起動とテーマ
  features/<機能>/          機能ごとのテスト（lib と同じ形）
```

## 依存の向き
ui → view_model → data（Repository）。逆向きと、機能をまたぐ直接の参照は禁止（共通のものは lib/core/ に置く）。
`lib/catalog/` は収録データで、`lib/core/data/` の CatalogRepository だけが読む。ui から直接読まない。ただし収録データの型（`lib/catalog/model/`）は、プレビューを組み立てるために ui からも使う。
仕組みの詳細は docs/design/functions/demo-engine.md。

## 状態と依存の受け渡し
- Provider は riverpod_generator（`@riverpod`）で、各機能の view_model / data に置く
- 詳細のプロパティの値と比較の状態は、Widget ごとの family の Notifier に持つ（プレビュー・操作パネル・比較・コードの4か所で共有するため）
- 検索欄の入力中の文字など、画面の中だけの一時的な状態は StatefulWidget に持つ
- テストでは `ProviderScope(overrides: [...])` で Repository を fake に差し替える

## 遷移
標準の Navigator（`Navigator.push` と `MaterialPageRoute`）。ホーム → ジャンル → 詳細、またはホームの検索の結果 → 詳細。
ホーム（`CatalogScreen`）とジャンル画面（`GenreScreen`。同じ catalog の機能の中なので、ホームから直接 push してよい）は行を押したことを `onEntryTapped(context, entryId)` で知らせるだけで、詳細画面を直接参照しない（機能をまたぐ参照の禁止）。`DetailScreen` への `Navigator.push` は、両方を組み立てる `lib/app.dart` が渡す。

決めた理由は docs/adr/ の最初の ADR（ADR-0001-project-structure-and-conventions.md）
