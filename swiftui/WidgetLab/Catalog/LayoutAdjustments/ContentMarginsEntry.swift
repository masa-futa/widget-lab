import SwiftUI

nonisolated extension CatalogEntry {
    static let contentMargins = CatalogEntry(
        id: "contentMargins",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "ScrollView や List の中身・スクロールバーのまわりに余白を足す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/contentmargins(_:_:for:)")!,
        stage: .card,
        properties: [
            .argument(
                "edges", unlabeled: true,
                .choice([Choice(".all"), Choice(".horizontal"), Choice(".vertical"), Choice(".top")], initial: 1),
                on: true, summary: "余白を足す辺（OFF ならすべての辺）"),
            .argument(
                "length", unlabeled: true, .slider(range: 0...60, step: 4, initial: 32), required: true,
                summary: "余白の大きさ"),
            .argument(
                "for",
                .choice([Choice(".automatic"), Choice(".scrollContent"), Choice(".scrollIndicators")], initial: 1),
                summary: "余白を足すもの（OFF なら .automatic）"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(1...20, id: \\.self) { i in", "        Text(\"行 \\(i)\")",
                "            .frame(maxWidth: .infinity)", "            .background(.yellow)", "    }", "}",
            ],
            indent: 0, call: ".contentMargins"),
        build: { v in
            let edges = v.pick("edges", from: [Edge.Set.all, .horizontal, .vertical, .top]) ?? .all
            let placement =
                v.pick("for", from: [ContentMarginPlacement.automatic, .scrollContent, .scrollIndicators]) ?? .automatic
            return AnyView(
                ScrollView {
                    ForEach(1...20, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity)
                            .background(.yellow)
                    }
                }
                .contentMargins(edges, v.number("length").map { CGFloat($0) }, for: placement)
            )
        }
    )
}
