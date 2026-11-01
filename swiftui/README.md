# Widget Lab SwiftUI

SwiftUI の部品を、プロパティを付けた／付けないで触って比べる iPhone のアプリです。収録するのは、[SwiftUI の API リファレンス](https://developer.apple.com/documentation/swiftui) に載っていて iOS 27.0 で使える View・modifier・プロパティラッパー・ジェスチャーの型です。

- 要件: [docs/PRD.md](docs/PRD.md)
- 構成: [docs/architecture.md](docs/architecture.md)
- 決めたこと: [docs/adr/](docs/adr/)

## 動かし方
1. Xcode 27.0 以上で `WidgetLab.xcodeproj` を開く
2. スキーム `WidgetLab` を選び、iOS 27.0 以上のシミュレータで実行する

テストと manifest の作り直し方は [CLAUDE.md](CLAUDE.md) の「コマンド」にあります。
