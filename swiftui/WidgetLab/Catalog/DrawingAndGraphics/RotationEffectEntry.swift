import SwiftUI

nonisolated extension CatalogEntry {
    static let rotationEffect = CatalogEntry(
        id: "rotationEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の描く向きだけを、決めた角度だけ回す modifier。並びの中の場所は変わらない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/rotationeffect(_:anchor:)")!,
        stage: .card,
        properties: [
            .argument(
                "angle", unlabeled: true,
                .choice(
                    [Choice(".degrees(15)"), Choice(".degrees(45)"), Choice(".degrees(90)"), Choice(".degrees(180)")],
                    initial: 1),
                required: true, summary: "回す角度（時計回り）"),
            .argument(
                "anchor", .choice([Choice(".center"), Choice(".topLeading"), Choice(".bottomTrailing")], initial: 1),
                summary: "回す中心（OFF なら .center）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .padding()", "    .background(.yellow)"], call: ".rotationEffect"),
        build: { v in
            AnyView(
                Text("見本")
                    .padding()
                    .background(.yellow)
                    .rotationEffect(
                        v.pick("angle", from: [Angle.degrees(15), .degrees(45), .degrees(90), .degrees(180)]) ?? .zero,
                        anchor: v.pick("anchor", from: [UnitPoint.center, .topLeading, .bottomTrailing]) ?? .center
                    )
                    .border(.secondary)
            )
        }
    )
}
