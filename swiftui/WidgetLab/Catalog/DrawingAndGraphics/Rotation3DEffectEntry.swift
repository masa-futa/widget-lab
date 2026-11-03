import SwiftUI

nonisolated extension CatalogEntry {
    static let rotation3DEffect = CatalogEntry(
        id: "rotation3DEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View を、決めた軸のまわりに奥行きをつけて回して描く modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/rotation3deffect(_:axis:anchor:anchorz:perspective:)"
        )!,
        stage: .card,
        properties: [
            .argument(
                "angle", unlabeled: true,
                .choice([Choice(".degrees(30)"), Choice(".degrees(60)"), Choice(".degrees(150)")], initial: 1),
                required: true, summary: "回す角度"),
            .argument(
                "axis",
                .choice(
                    [
                        Choice("縦の軸", code: "(x: 0, y: 1, z: 0)"), Choice("横の軸", code: "(x: 1, y: 0, z: 0)"),
                        Choice("斜めの軸", code: "(x: 1, y: 1, z: 0)"),
                    ],
                    initial: 0),
                required: true, summary: "回す軸の向き"),
            .argument(
                "anchor", .choice([Choice(".center"), Choice(".leading"), Choice(".top")], initial: 1),
                summary: "軸が通る場所（OFF なら .center）"),
            .argument(
                "perspective", .slider(range: 0...2, step: 0.25, initial: 0.5),
                summary: "遠近の強さ（0 で遠近なし。OFF なら 1）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .font(.largeTitle)", "    .padding()", "    .background(.yellow)"],
            call: ".rotation3DEffect"),
        build: { v in
            let axes: [(x: CGFloat, y: CGFloat, z: CGFloat)] = [(0, 1, 0), (1, 0, 0), (1, 1, 0)]
            return AnyView(
                Text("見本")
                    .font(.largeTitle)
                    .padding()
                    .background(.yellow)
                    .rotation3DEffect(
                        v.pick("angle", from: [Angle.degrees(30), .degrees(60), .degrees(150)]) ?? .zero,
                        axis: v.pick("axis", from: axes) ?? (0, 1, 0),
                        anchor: v.pick("anchor", from: [UnitPoint.center, .leading, .top]) ?? .center,
                        perspective: v.number("perspective").map { CGFloat($0) } ?? 1
                    )
            )
        }
    )
}
