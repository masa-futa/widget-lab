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
    Model/Demo/             見本の記録の窓口（DemoRecorder・Environment の demoRecorder・reportBody）
    Generated/              tools/make_manifest.py の生成物（Topic.swift・Manifest.swift）。手で直さない
    Catalog.swift           全件の一覧（Catalog.all）
    <トピック>/             1 件 = 1 ファイルの収録データ（<名前>Entry.swift）
  Features/
    Catalog/{UI,ViewModel}  ホーム（大分類ごとのトピックと検索）とトピック画面。一覧の行の見た目（文字の色・右の矢印・押したときの地）は NavigationRowButtonStyle にまとめる
    Detail/{UI,ViewModel}   詳細（プレビュー・コードの 1 行・チップ・編集パネル・比べる・全画面で試す（.full）・説明とコードのシート・見た目を持たないものの記録 DetailRecorder と RecordPanel）
WidgetLabTests/             Swift Testing。WidgetLab と同じ形（Catalog/・Features/<機能>/）と、fake を置く Support/
WidgetLabUITests/           XCTest の UI テスト（起動 → 検索 → 詳細 → コピー、詳細で比べるを開いて左右が出ること、`@State` を比べて付けた側だけ表示が変わること、全画面の収録を試すで開いて閉じること、レイアウト・描画・テキスト・操作の部品・スタイルと動き・一覧とスクロール・画面の行き来・入力の代表 2 件ずつのスクリーンショットの 12 本）
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
- 見た目を持たないものの記録は、詳細の ViewModel が DetailRecorder を持ち、側ごとの窓口を Environment で見本に渡す。見本は窓口に書くだけで読まない。プロパティや比べるを変えたら、記録を消して見本を作り直す（demoGeneration を見本の id にする）。PreviewArea は記録の値を読まない（読むと見本が描き直され、@State を外した側の箱が作り直される）。

## 遷移
`NavigationStack(path:)` と値つきの `navigationDestination(for: Route.self)`。ホーム → トピック → 詳細、またはホームの検索の結果 → 詳細。
ホーム（`HomeScreen`）とトピック画面（`TopicScreen`）は行を押したことを `onTopicTapped` / `onEntryTapped` で知らせるだけで、詳細画面を直接参照しない。`DetailScreen` を組み立てるのは `RootView`。

## コードの生成
`CodeGenerator.lines` が、`CodeTemplate`（呼び出しの名前・いつも書く引数・末尾のクロージャ・前後の行）に、付けた引数と modifier を定義の順で埋めて、行ごと（`CodeLine`）に返す。最初の値から変えたプロパティの行には `isChanged` が付く。同じ modifier の名前を持つプロパティは 1 行にまとめる（`.frame(width:height:)` など）。同じ modifier を 2 回かけるときは、プロパティの `line` で行を分ける。呼び出しの前後の行は `prefix`・`suffix`・`closing`（字下げせずに書く閉じ括弧など）で書き、呼び出しの字下げは `indent` で決める（省けば prefix があるとき 4）。modifier と suffix は、呼び出しが modifier か末尾のクロージャが複数行なら呼び出しと同じ桁、ほかは 1 段深く書く。

プレビューの出し方は `DemoStage` で決める。`.card` は枠に収まる見本、`.full` は画面の行き来の入れ物や表示の単位に効くもの（枠には「試す」だけを出し、押すと見本を `fullScreenCover` で全画面に出す。下の帯で、選んでいるプロパティの付けない／付けたを切り替える。状態は `DetailViewModel` の `isTryingFull`・`trialShowsWith`・`trialValues`）、`.behavior` は見た目を持たないもの（左右に並べて記録を出す）、`.note` はアプリの画面では試せないもの（見本の代わりに理由を出し、比べるは出さない）。

プロパティラッパーの収録は、`CodeTemplate.wrapper`（`WrapperCode`）の付けた形と外した形の行をそのまま使う。外した形では、付けた形にない行に `isChanged` が付く。引数のない呼び出しの括弧を省くのは、末尾が " {" で始まるクロージャのときだけ（`.gesture(TapGesture().onEnded { })` では省かない）。

決めた理由は docs/adr/ の ADR-0001（構成と規約）と ADR-0002（収録データから組み立てる）。
