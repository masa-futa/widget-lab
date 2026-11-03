import SwiftUI

nonisolated extension CatalogEntry {
    static let contentUnavailableView = CatalogEntry(
        id: "ContentUnavailableView",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "見せる中身がないとき（検索の結果が 0 件など）に出す、アイコンと説明の View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/contentunavailableview")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "項目がありません"), required: true, summary: "見出し"),
            .argument(
                "systemImage",
                .choice([Choice("\"tray\""), Choice("\"magnifyingglass\""), Choice("\"wifi.slash\"")], initial: 0),
                required: true, summary: "SF Symbols のアイコンの名前"),
            .argument("description", .fixed(code: "Text(\"項目を足すと、ここに並びます\")"), on: true, summary: "見出しの下の説明"),
        ],
        code: CodeTemplate(call: "ContentUnavailableView"),
        build: { v in
            AnyView(
                ContentUnavailableView(
                    v.text("title") ?? "",
                    systemImage: v.pick("systemImage", from: ["tray", "magnifyingglass", "wifi.slash"]) ?? "tray",
                    description: v["description"] != nil ? Text("項目を足すと、ここに並びます") : nil)
            )
        }
    )
}
