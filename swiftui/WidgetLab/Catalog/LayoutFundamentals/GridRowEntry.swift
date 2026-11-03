import SwiftUI

nonisolated extension CatalogEntry {
    static let gridRow = CatalogEntry(
        id: "GridRow",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "Grid の中で、子の View を 1 行に並べる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/gridrow")!,
        stage: .card,
        properties: [
            .argument(
                "alignment", .choice([Choice(".top"), Choice(".center"), Choice(".bottom")], initial: 0), on: true,
                summary: "この行のマスの縦の揃え方（Grid の alignment より優先する）")
        ],
        code: CodeTemplate(
            prefix: ["Grid {"], call: "GridRow",
            trailing: " {\n        Text(\"A\").font(.largeTitle)\n        Text(\"b\")\n    }",
            closing: ["    GridRow {", "        Text(\"C\")", "        Text(\"d\")", "    }", "}"]),
        build: { v in
            AnyView(
                Grid {
                    GridRow(alignment: v.pick("alignment", from: [VerticalAlignment.top, .center, .bottom])) {
                        Text("A").font(.largeTitle).background(.yellow)
                        Text("b").background(.yellow)
                    }
                    GridRow {
                        Text("C").background(.yellow)
                        Text("d").background(.yellow)
                    }
                }
                .border(.secondary)
            )
        }
    )
}
