import SwiftUI

nonisolated extension CatalogEntry {
    static let safeAreaInset = CatalogEntry(
        id: "safeAreaInset",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View の端に別の View を置き、そのぶん安全な領域を狭める modifier。中身は下に隠れずに済む。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/safeareainset(edge:alignment:spacing:content:)-6gwby"
        )!,
        stage: .card,
        properties: [
            .argument(
                "edge", .choice([Choice(".top"), Choice(".bottom")], initial: 1), required: true, summary: "置く辺"),
            .argument(
                "alignment", .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 2),
                on: true, summary: "置く View の横の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "中身と置く View の間の距離"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(1...20, id: \\.self) { i in", "        Text(\"行 \\(i)\")",
                "            .frame(maxWidth: .infinity)", "    }", "}",
            ],
            indent: 0, call: ".safeAreaInset",
            trailing: " {\n    Text(\"帯\")\n        .padding(8)\n        .background(.yellow)\n}"),
        build: { v in
            AnyView(
                ScrollView {
                    ForEach(1...20, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity)
                    }
                }
                .safeAreaInset(
                    edge: v.pick("edge", from: [VerticalEdge.top, .bottom]) ?? .bottom,
                    alignment: v.pick("alignment", from: [HorizontalAlignment.leading, .center, .trailing]) ?? .center,
                    spacing: v.number("spacing").map { CGFloat($0) }
                ) {
                    Text("帯")
                        .padding(8)
                        .background(.yellow)
                }
            )
        }
    )
}
