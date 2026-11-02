# Widget Lab SwiftUI

SwiftUI の API リファレンスに載る View・modifier・プロパティラッパー・ジェスチャーの型を、プロパティを付けた／付けないで触って比べられる iPhone のアプリ。要件は docs/PRD.md、構想はリポジトリのルートの ../docs/concept/brief.md（全体の決まりは ../CLAUDE.md）。

## スタック
- Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）。外部のパッケージは使わない
- 状態: `@Observable` / 遷移: `NavigationStack` / 文言: String Catalog（日本語のみ）/ テスト: Swift Testing（UI テストだけ XCTest）
- 対象: iPhone、iOS 27.0 以上（iPad はスマホと同じ 1 カラム）。オフラインのみ

## コマンド
- コマンドはすべて `swiftui/` で実行する
- 確かめ:
  ```
  xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests \
    && python3 -m unittest discover tools \
    && xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
       -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
       -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
       -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120
  ```
  UI テストは時間の上限を付けて実行する（要素が見つからないと待ち続けて止まるため）。`Toggle` を `.toggleStyle(.button)` にしたものは、UI テストでは `app.switches[...]` で探す
- 整形: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests`
- manifest を作り直す: `python3 tools/make_manifest.py`（`--refresh` でリファレンスを取り直す）。生成した `WidgetLab/Catalog/Generated/` はコミットする
- 収録の進み具合: `python3 tools/catalog_progress.py`（トピックの slug を渡すと、そのトピックだけ。抜けがあれば終了コード 1）
- 起動: Xcode で `WidgetLab.xcodeproj` を開いて実行する

## 規約
- 構成と依存の向き: docs/architecture.md
- 決めた理由: docs/adr/
- フォルダはファイルと同期する（Xcode 16 以降の同期グループ）。ファイルを足すときに project.pbxproj を直す必要はない
- 新しい画面は WidgetLab/Features/<機能>/{UI,ViewModel} に置き、WidgetLabTests/Features/<機能>/ にテストを置く
- 収録データは WidgetLab/Catalog/<トピック>/<名前>Entry.swift に置き、Catalog.swift の `all` に並べる。id・種類・トピックは Generated/Manifest.swift に合わせる
- 収録データの型（WidgetLab/Catalog/）は `nonisolated` にする。組み立ての関数だけが `@MainActor`

## 公開について
- リポジトリは public。署名鍵・ストアの認証情報・`.env` などをコミットしない（`.gitignore` で除外済み）
