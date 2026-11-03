import SwiftUI

nonisolated extension CatalogEntry {
    static let hStack = CatalogEntry(
        id: "HStack",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を横に並べる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/hstack")!,
        stage: .card,
        properties: [
            .argument(
                "alignment",
                .choice(
                    [Choice(".top"), Choice(".center"), Choice(".bottom"), Choice(".firstTextBaseline")], initial: 0),
                on: true, summary: "子の縦の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "子と子の間の距離"),
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing: " {\n    Text(\"A\").font(.largeTitle)\n    Text(\"B\")\n    Text(\"C\").font(.caption)\n}"),
        build: { v in
            AnyView(
                HStack(
                    alignment: v.pick("alignment", from: [VerticalAlignment.top, .center, .bottom, .firstTextBaseline])
                        ?? .center,
                    spacing: v.number("spacing").map { CGFloat($0) }
                ) {
                    Text("A").font(.largeTitle)
                    Text("B")
                    Text("C").font(.caption)
                }
                .border(.secondary)
            )
        }
    )
}
