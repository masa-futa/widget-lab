import SwiftUI

nonisolated extension CatalogEntry {
    static let vStack = CatalogEntry(
        id: "VStack",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を縦に並べる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/vstack")!,
        stage: .card,
        properties: [
            .argument(
                "alignment", .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 0),
                on: true, summary: "子の横の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "子と子の間の距離"),
        ],
        code: CodeTemplate(
            call: "VStack", trailing: " {\n    Text(\"A\")\n    Text(\"BBBB\")\n    Text(\"CC\")\n}"),
        build: { v in
            AnyView(
                VStack(
                    alignment: v.pick("alignment", from: [HorizontalAlignment.leading, .center, .trailing]) ?? .center,
                    spacing: v.number("spacing").map { CGFloat($0) }
                ) {
                    Text("A")
                    Text("BBBB")
                    Text("CC")
                }
                .border(.secondary)
            )
        }
    )
}
