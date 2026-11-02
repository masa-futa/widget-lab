import SwiftUI

nonisolated extension CatalogEntry {
    static let zStack = CatalogEntry(
        id: "ZStack",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を奥から手前へ重ねる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/zstack")!,
        stage: .card,
        properties: [
            .argument(
                "alignment",
                .choice(
                    [
                        Choice(".topLeading"), Choice(".top"), Choice(".center"), Choice(".bottom"),
                        Choice(".bottomTrailing"),
                    ],
                    initial: 0),
                on: true, summary: "重ねる子の揃え方")
        ],
        code: CodeTemplate(
            call: "ZStack",
            trailing:
                " {\n    Color.yellow\n        .frame(width: 160, height: 100)\n    Text(\"手前\")\n        .padding(8)\n"
                + "        .background(.orange)\n}"),
        build: { v in
            AnyView(
                ZStack(
                    alignment: v.pick(
                        "alignment", from: [Alignment.topLeading, .top, .center, .bottom, .bottomTrailing])
                        ?? .center
                ) {
                    Color.yellow
                        .frame(width: 160, height: 100)
                    Text("手前")
                        .padding(8)
                        .background(.orange)
                }
            )
        }
    )
}
