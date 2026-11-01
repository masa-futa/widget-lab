import SwiftUI

nonisolated extension CatalogEntry {
    static let padding = CatalogEntry(
        id: "padding",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View のまわりに余白を足す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/padding(_:_:)")!,
        stage: .card,
        properties: [
            .argument(
                "edges", unlabeled: true,
                .choice(
                    [Choice(".all"), Choice(".horizontal"), Choice(".vertical"), Choice(".top"), Choice(".leading")],
                    initial: 1),
                summary: "余白を足す辺"),
            .argument(
                "length", unlabeled: true, .slider(range: 0...48, step: 4, initial: 24), on: true,
                summary: "余白の大きさ（OFF なら環境に合わせた既定の大きさ）"),
        ],
        code: CodeTemplate(prefix: ["Text(\"見本\")"], call: ".padding", suffix: [".background(.yellow)"]),
        build: { v in
            let edges = v.pick("edges", from: [Edge.Set.all, .horizontal, .vertical, .top, .leading]) ?? .all
            return AnyView(
                Text("見本")
                    .padding(edges, v.number("length").map { CGFloat($0) })
                    .background(.yellow)
            )
        }
    )
}
