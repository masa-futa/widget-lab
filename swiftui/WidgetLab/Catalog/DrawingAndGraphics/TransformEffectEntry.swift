import SwiftUI

nonisolated extension CatalogEntry {
    static let transformEffect = CatalogEntry(
        id: "transformEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の描く形を、アフィン変換（回す・伸ばす・傾ける・ずらす）で変える modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/transformeffect(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "transformEffect",
                .choice(
                    [
                        Choice("傾ける", code: "CGAffineTransform(a: 1, b: 0, c: 0.5, d: 1, tx: 0, ty: 0)"),
                        Choice("横に伸ばす", code: "CGAffineTransform(scaleX: 1.5, y: 1)"),
                        Choice("回す", code: "CGAffineTransform(rotationAngle: .pi / 8)"),
                    ],
                    initial: 0),
                on: true, summary: "かける変換（原点は View の左上）")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .padding()"], call: ".background", fixedArguments: [".yellow"]),
        build: { v in
            AnyView(
                Text("見本")
                    .padding()
                    .background(.yellow)
                    .apply(
                        v.pick(
                            "transformEffect",
                            from: [
                                CGAffineTransform(a: 1, b: 0, c: 0.5, d: 1, tx: 0, ty: 0),
                                CGAffineTransform(scaleX: 1.5, y: 1), CGAffineTransform(rotationAngle: .pi / 8),
                            ])
                    ) { $0.transformEffect($1) }
                    .border(.secondary)
            )
        }
    )
}
