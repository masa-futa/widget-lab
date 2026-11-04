import SwiftUI

nonisolated extension CatalogEntry {
    static let widgetAccentable = CatalogEntry(
        id: "widgetAccentable",
        kind: .modifier,
        topic: .appExtensions,
        summary: "ウィジェットの中の View を、目立たせる色（アクセントの色）で描く組に入れる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/widgetaccentable(_:)")!,
        noteReason: "アプリ拡張のウィジェットの中で効く。ロック画面・Apple Watch・色付きのホーム画面など、ウィジェットを 2 色で描くときに出る",
        properties: [
            .modifier("widgetAccentable", .toggle(initial: true), on: true, summary: "true なら、アクセントの色で描く。ほかは白っぽい色になる")
        ],
        code: CodeTemplate(
            prefix: ["// ウィジェットの中", "VStack {"], indent: 4, call: "Text", fixedArguments: ["\"21°\""],
            suffix: [".font(.largeTitle)"], closing: ["    Text(\"東京\")", "}"])
    )
}
