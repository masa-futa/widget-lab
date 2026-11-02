import SwiftUI

nonisolated extension CatalogEntry {
    static let lazyVGrid = CatalogEntry(
        id: "LazyVGrid",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を、決めた列の数で縦に伸びる表に並べ、画面に入るときに初めて作る View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/lazyvgrid")!,
        stage: .card,
        properties: [
            .argument(
                "columns",
                .choice(
                    [
                        Choice("固定 3 列", code: "[GridItem(.fixed(60)), GridItem(.fixed(60)), GridItem(.fixed(60))]"),
                        Choice("伸びる 2 列", code: "[GridItem(), GridItem()]"),
                        Choice("入るだけ", code: "[GridItem(.adaptive(minimum: 60))]"),
                    ],
                    initial: 0),
                required: true, summary: "列の数と幅の決め方（GridItem の配列）"),
            .argument(
                "alignment", .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 0),
                summary: "表全体の横の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "行と行の間の距離"),
        ],
        code: CodeTemplate(
            prefix: ["ScrollView {"], call: "LazyVGrid",
            trailing: " {\n        ForEach(1...30, id: \\.self) { i in\n            Text(\"\\(i)\")\n"
                + "                .frame(height: 40)\n                .frame(maxWidth: .infinity)\n"
                + "                .background(.yellow)\n        }\n    }",
            closing: ["}"]),
        build: { v in
            AnyView(
                ScrollView {
                    LazyVGrid(
                        columns: v.pick(
                            "columns",
                            from: [
                                [GridItem(.fixed(60)), GridItem(.fixed(60)), GridItem(.fixed(60))],
                                [GridItem(), GridItem()], [GridItem(.adaptive(minimum: 60))],
                            ]) ?? [],
                        alignment: v.pick("alignment", from: [HorizontalAlignment.leading, .center, .trailing])
                            ?? .center,
                        spacing: v.number("spacing").map { CGFloat($0) }
                    ) {
                        ForEach(1...30, id: \.self) { i in
                            Text("\(i)")
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(.yellow)
                        }
                    }
                }
            )
        }
    )
}
