import SwiftUI

nonisolated extension CatalogEntry {
    static let offset = CatalogEntry(
        id: "offset",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View の描く場所だけをずらす modifier。並びの中の場所は変わらない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/offset(x:y:)")!,
        stage: .card,
        properties: [
            .argument("x", .slider(range: -100...100, step: 10, initial: 40), on: true, summary: "横にずらす距離（OFF なら 0）"),
            .argument("y", .slider(range: -60...60, step: 10, initial: 20), summary: "縦にずらす距離（OFF なら 0）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .background(.yellow)"], call: ".offset", suffix: [".border(.secondary)"]),
        build: { v in
            AnyView(
                Text("見本")
                    .background(.yellow)
                    .offset(x: v.number("x").map { CGFloat($0) } ?? 0, y: v.number("y").map { CGFloat($0) } ?? 0)
                    .border(.secondary)
            )
        }
    )
}
