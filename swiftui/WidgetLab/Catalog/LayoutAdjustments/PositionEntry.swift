import SwiftUI

nonisolated extension CatalogEntry {
    static let position = CatalogEntry(
        id: "position",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View の中心を、置き場所の中の決めた座標に置く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/position(x:y:)")!,
        stage: .card,
        properties: [
            .argument("x", .slider(range: 0...300, step: 10, initial: 60), on: true, summary: "中心の横の座標（OFF なら 0）"),
            .argument("y", .slider(range: 0...200, step: 10, initial: 40), on: true, summary: "中心の縦の座標（OFF なら 0）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .background(.yellow)"], call: ".position", suffix: [".border(.secondary)"]),
        build: { v in
            AnyView(
                Text("見本")
                    .background(.yellow)
                    .position(x: v.number("x").map { CGFloat($0) } ?? 0, y: v.number("y").map { CGFloat($0) } ?? 0)
                    .border(.secondary)
            )
        }
    )
}
