import SwiftUI

nonisolated extension CatalogEntry {
    static let lazyHGrid = CatalogEntry(
        id: "LazyHGrid",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を、決めた行の数で横に伸びる表に並べ、画面に入るときに初めて作る View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/lazyhgrid")!,
        stage: .card,
        properties: [
            .argument(
                "rows",
                .choice(
                    [
                        Choice("固定 2 行", code: "[GridItem(.fixed(40)), GridItem(.fixed(40))]"),
                        Choice("伸びる 3 行", code: "[GridItem(), GridItem(), GridItem()]"),
                        Choice("入るだけ", code: "[GridItem(.adaptive(minimum: 40))]"),
                    ],
                    initial: 0),
                required: true, summary: "行の数と高さの決め方（GridItem の配列）"),
            .argument(
                "alignment", .choice([Choice(".top"), Choice(".center"), Choice(".bottom")], initial: 0),
                summary: "表全体の縦の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "列と列の間の距離"),
        ],
        code: CodeTemplate(
            prefix: ["ScrollView(.horizontal) {"], call: "LazyHGrid",
            trailing: " {\n        ForEach(1...30, id: \\.self) { i in\n            Text(\"\\(i)\")\n"
                + "                .frame(width: 40)\n                .background(.yellow)\n        }\n    }",
            closing: ["}"]),
        build: { v in
            AnyView(
                ScrollView(.horizontal) {
                    LazyHGrid(
                        rows: v.pick(
                            "rows",
                            from: [
                                [GridItem(.fixed(40)), GridItem(.fixed(40))], [GridItem(), GridItem(), GridItem()],
                                [GridItem(.adaptive(minimum: 40))],
                            ]) ?? [],
                        alignment: v.pick("alignment", from: [VerticalAlignment.top, .center, .bottom]) ?? .center,
                        spacing: v.number("spacing").map { CGFloat($0) }
                    ) {
                        ForEach(1...30, id: \.self) { i in
                            Text("\(i)")
                                .frame(width: 40)
                                .background(.yellow)
                        }
                    }
                }
            )
        }
    )
}
