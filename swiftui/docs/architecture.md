# アーキテクチャ

## 構成

```
WidgetLab.xcodeproj         Xcode のプロジェクト（フォルダと同期するグループ）
WidgetLab/
  App/WidgetLabApp.swift    アプリの入口。RootView が画面を組み立てて遷移をつなぐ（Route）
  Localizable.xcstrings     UI の文言（日本語のみ）
  Core/
    Data/                   CatalogRepository（収録データを読む窓口）
    System/                 OS の機能の包み（ClipboardClient）
  Catalog/
    Model/                  収録データの型（CatalogEntry・PropertySpec・PropertyControl・PropertyValues・CodeTemplate・CodeGenerator など）
    Generated/              tools/make_manifest.py の生成物（Topic.swift・Manifest.swift）。手で直さない
    Catalog.swift           全件の一覧（Catalog.all）
    <トピック>/             1 件 = 1 ファイルの収録データ（<名前>Entry.swift）
  Features/
    Catalog/{UI,ViewModel}  ホーム（大分類ごとのトピックと検索）とトピック画面
    Detail/{UI,ViewModel}   詳細（プレビュー・コードの 1 行・チップ・編集パネル・比べる・説明とコードのシート）
WidgetLabTests/             Swift Testing。WidgetLab と同じ形（Catalog/・Features/<機能>/）と、fake を置く Support/
WidgetLabUITests/           XCTest の UI テスト（起動 → 検索 → 詳細 → コピーの 1 本）
tools/                      manifest を作る道具（Python 3.9 以上、標準ライブラリだけ）とそのテスト
```

## 依存の向き
UI → ViewModel → Repository。逆向きと、機能をまたぐ直接の参照は禁止（共通のものは Core/ に置く）。

- `Catalog/` は収録データで、ViewModel は `Core/Data/CatalogRepository` を通して読む。UI は収録データの型（`CatalogEntry` の `build` など）を、プレビューを組み立てるためにだけ使う
- `Catalog/` から `Features/` と `Core/` は参照しない
- 収録データの型は UI の状態を持たないので `nonisolated` にする（プロジェクトの既定の分離は MainActor）。組み立ての関数 `build` だけが `@MainActor`

## 状態と依存の受け渡し
- ViewModel は `@Observable` のクラス（既定の分離で MainActor）。画面が `@State` で持つ
- 詳細のプロパティの値・選んでいるプロパティ・比べるかどうかは `DetailViewModel` に持つ（プレビュー・チップ・編集パネル・コードの 4 か所で共有するため）
- 比べるの仕切りの位置、シートを出しているかなど、画面の中だけの一時的な状態は View の `@State` に持つ
- Repository とクリップボードはプロトコルで受け取り、テストでは fake を渡す（WidgetLabTests/Support/Fakes.swift）

## 遷移
`NavigationStack(path:)` と値つきの `navigationDestination(for: Route.self)`。ホーム → トピック → 詳細、またはホームの検索の結果 → 詳細。
ホーム（`HomeScreen`）とトピック画面（`TopicScreen`）は行を押したことを `onTopicTapped` / `onEntryTapped` で知らせるだけで、詳細画面を直接参照しない。`DetailScreen` を組み立てるのは `RootView`。

## コードの生成
`CodeGenerator.lines` が、`CodeTemplate`（呼び出しの名前・いつも書く引数・末尾のクロージャ・前後の行）に、付けた引数と modifier を定義の順で埋めて、行ごと（`CodeLine`）に返す。最初の値から変えたプロパティの行には `isChanged` が付く。

決めた理由は docs/adr/ の ADR-0001（構成と規約）と ADR-0002（収録データから組み立てる）。
