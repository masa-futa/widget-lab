import SwiftUI

nonisolated extension CatalogEntry {
    static let symbolVariant = CatalogEntry(
        id: "symbolVariant",
        kind: .modifier,
        topic: .images,
        summary: "この View の中の SF Symbols の記号を、塗り・丸囲みなどの別の形で表示する modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/symbolvariant(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "symbolVariant",
                .choice(
                    [
                        Choice(".none"), Choice(".fill"), Choice(".circle"), Choice(".circle.fill"), Choice(".square"),
                        Choice(".slash"),
                    ],
                    initial: 1),
                on: true, summary: "記号の形の種類。その形がない記号は元のまま"),
            .modifier("foregroundStyle", .color(initial: 0), summary: "記号の色"),
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing: " {\n    Image(systemName: \"heart\")\n    Image(systemName: \"bell\")\n"
                + "    Image(systemName: \"person\")\n}",
            suffix: [".font(.largeTitle)"]),
        build: { v in
            AnyView(
                HStack {
                    Image(systemName: "heart")
                    Image(systemName: "bell")
                    Image(systemName: "person")
                }
                .apply(
                    v.pick("symbolVariant", from: [SymbolVariants.none, .fill, .circle, .circle.fill, .square, .slash])
                ) { $0.symbolVariant($1) }
                .apply(v.color("foregroundStyle")) { $0.foregroundStyle($1) }
                .font(.largeTitle)
            )
        }
    )
}
