# ADR-0001: SwiftUI 版の構成と規約

> **要約**
> - 結論: Xcode のプロジェクトを手で書いた project.pbxproj（フォルダと同期するグループ）で作り、外部のパッケージなしの Swift 6・`@Observable`・`NavigationStack`・Swift Testing で組む。層は UI → ViewModel → Repository
> - 影響: `swiftui/` のすべて
> - お願い: なし（2026-10-31 オーナーが spec を承認）

## ステータス
承認済み（2026-10-31）

## 背景
ルートの ADR-0001 で、SwiftUI 版を別のネイティブアプリとして `swiftui/` に作ると決めた。Flutter 版（`flutter/docs/adr/ADR-0001-project-structure-and-conventions.md`）と同じく、構成・状態・遷移・テストの決まりを最初に決めておく。

## 決定
- Xcode のプロジェクトは `.xcodeproj` をそのままコミットする。フォルダと同期するグループ（`PBXFileSystemSynchronizedRootGroup`）を使い、ファイルを足しても project.pbxproj が変わらないようにする。スキームは共有（xcshareddata）にする
- Swift 6 の言語モード。既定の分離は MainActor（`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`）。UI の状態を持たない収録データの型は `nonisolated` にする
- 外部のパッケージは使わない
- 状態は `@Observable` の ViewModel。遷移は `NavigationStack(path:)` と値つきの `navigationDestination`
- 層は UI → ViewModel → Repository。機能（`Features/<機能>/{UI,ViewModel}`）をまたぐ参照はしない。共通のものは `Core/`
- 文言は String Catalog（日本語のみ。開発の言語を ja にする）
- テストは Swift Testing。UI テストだけ XCTest（Swift Testing は UI テストに対応していない）
- 整形と点検は Xcode に付いている swift-format（`.swift-format`、1 行 120 文字）
- 対象は iPhone の iOS 27.0 以上。iPad はスマホと同じ 1 カラム

## 選ばなかった案
| 案 | 選ばなかった理由 |
|---|---|
| XcodeGen・Tuist でプロジェクトを生成する | 同期するグループで project.pbxproj の競合の悩みはほぼなくなった。道具を 1 つ増やして保守する利点が小さい |
| ロジックをローカルの Swift Package に分ける | 1 アプリだけなので、パッケージの境界の手間に見合わない。テストは xcodebuild で十分に回せる |
| TCA など状態管理のライブラリ | 画面は 3 枚で、`@Observable` で足りる。外部の依存を持たない方針 |
| 既定の分離を nonisolated のままにする | ほとんどの型が UI から使われるので、MainActor を既定にしたほうが注釈が少なく済む |

## 結果
- ファイルを足すだけでビルドに入る。project.pbxproj を直すのはターゲットや設定を変えるときだけ
- 収録データの型に `nonisolated` を付け忘れると、テストの引数（`@Test(arguments:)`）から読めずにビルドが落ちる。CLAUDE.md の規約に書いておく
