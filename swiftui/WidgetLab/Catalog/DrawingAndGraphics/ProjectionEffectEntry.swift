import SwiftUI

nonisolated extension CatalogEntry {
    static let projectionEffect = CatalogEntry(
        id: "projectionEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の描く形を、射影変換（3D の回転を平面に写したものなど）で変える modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/projectioneffect(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "projectionEffect",
                .choice(
                    [
                        Choice("縦の軸で回す", code: "ProjectionTransform(CATransform3DMakeRotation(.pi / 3, 0, 1, 0))"),
                        Choice("横の軸で回す", code: "ProjectionTransform(CATransform3DMakeRotation(.pi / 3, 1, 0, 0))"),
                        Choice(
                            "傾ける",
                            code: "ProjectionTransform(CGAffineTransform(a: 1, b: 0, c: 0.5, d: 1, tx: 0, ty: 0))"),
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
                            "projectionEffect",
                            from: [
                                ProjectionTransform(CATransform3DMakeRotation(.pi / 3, 0, 1, 0)),
                                ProjectionTransform(CATransform3DMakeRotation(.pi / 3, 1, 0, 0)),
                                ProjectionTransform(CGAffineTransform(a: 1, b: 0, c: 0.5, d: 1, tx: 0, ty: 0)),
                            ])
                    ) { $0.projectionEffect($1) }
                    .border(.secondary)
            )
        }
    )
}
