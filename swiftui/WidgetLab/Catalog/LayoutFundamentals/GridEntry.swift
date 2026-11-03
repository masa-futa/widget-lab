import SwiftUI

nonisolated extension CatalogEntry {
    static let grid = CatalogEntry(
        id: "Grid",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を行と列の表の形に並べる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/grid")!,
        stage: .card,
        properties: [
            .argument(
                "alignment",
                .choice([Choice(".topLeading"), Choice(".center"), Choice(".bottomTrailing")], initial: 0), on: true,
                summary: "マスの中の揃え方"),
            .argument(
                "horizontalSpacing", .slider(range: 0...40, step: 4, initial: 16), summary: "列と列の間の距離"),
            .argument("verticalSpacing", .slider(range: 0...40, step: 4, initial: 16), summary: "行と行の間の距離"),
        ],
        code: CodeTemplate(
            call: "Grid",
            trailing: " {\n    GridRow {\n        Text(\"A\")\n        Text(\"BBBB\")\n    }\n"
                + "    GridRow {\n        Text(\"CCCCCC\")\n        Text(\"D\").font(.largeTitle)\n    }\n}"),
        build: { v in
            AnyView(
                Grid(
                    alignment: v.pick("alignment", from: [Alignment.topLeading, .center, .bottomTrailing]) ?? .center,
                    horizontalSpacing: v.number("horizontalSpacing").map { CGFloat($0) },
                    verticalSpacing: v.number("verticalSpacing").map { CGFloat($0) }
                ) {
                    GridRow {
                        Text("A").background(.yellow)
                        Text("BBBB").background(.yellow)
                    }
                    GridRow {
                        Text("CCCCCC").background(.yellow)
                        Text("D").font(.largeTitle).background(.yellow)
                    }
                }
                .border(.secondary)
            )
        }
    )
}
