import SwiftUI

nonisolated extension CatalogEntry {
    static let text = CatalogEntry(
        id: "Text",
        kind: .view,
        topic: .textInputAndOutput,
        summary: "読み取り専用の文字を 1 行以上表示する View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/text")!,
        stage: .card,
        properties: [
            .argument(
                "content", unlabeled: true, .text(initial: "こんにちは、SwiftUI の世界"), required: true,
                summary: "表示する文字"),
            .modifier(
                "font",
                .choice(
                    [
                        Choice(".largeTitle"), Choice(".title"), Choice(".headline"), Choice(".body"),
                        Choice(".caption"),
                    ],
                    initial: 1),
                summary: "文字の大きさと太さ（Dynamic Type に合わせて変わる）"),
            .modifier("foregroundStyle", .color(initial: 4), summary: "文字の色"),
            .modifier("lineLimit", .slider(range: 1...3, step: 1, initial: 1), summary: "表示する行の数の上限"),
        ],
        code: CodeTemplate(call: "Text"),
        build: { v in
            AnyView(
                Text(v.text("content") ?? "")
                    .apply(v.pick("font", from: [Font.largeTitle, .title, .headline, .body, .caption])) { $0.font($1) }
                    .apply(v.color("foregroundStyle")) { $0.foregroundStyle($1) }
                    .apply(v.number("lineLimit")) { $0.lineLimit(Int($1)) }
            )
        }
    )
}
