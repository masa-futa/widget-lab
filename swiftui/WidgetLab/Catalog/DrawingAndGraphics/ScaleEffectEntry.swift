import SwiftUI

nonisolated extension CatalogEntry {
    static let scaleEffect = CatalogEntry(
        id: "scaleEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の描く大きさだけを、横と縦の倍率で変える modifier。並びの中の大きさは変わらない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scaleeffect(x:y:anchor:)")!,
        stage: .card,
        properties: [
            .argument("x", .slider(range: 0.25...3, step: 0.25, initial: 2), on: true, summary: "横の倍率（OFF なら 1）"),
            .argument("y", .slider(range: 0.25...3, step: 0.25, initial: 1.5), summary: "縦の倍率（OFF なら 1）"),
            .argument(
                "anchor", .choice([Choice(".center"), Choice(".topLeading"), Choice(".bottomTrailing")], initial: 1),
                summary: "伸び縮みの中心（OFF なら .center）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .padding()", "    .background(.yellow)"], call: ".scaleEffect"),
        build: { v in
            AnyView(
                Text("見本")
                    .padding()
                    .background(.yellow)
                    .scaleEffect(
                        x: v.number("x").map { CGFloat($0) } ?? 1, y: v.number("y").map { CGFloat($0) } ?? 1,
                        anchor: v.pick("anchor", from: [UnitPoint.center, .topLeading, .bottomTrailing]) ?? .center
                    )
                    .border(.secondary)
            )
        }
    )
}
