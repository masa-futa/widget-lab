import SwiftUI

nonisolated extension CatalogEntry {
    static let drawingGroup = CatalogEntry(
        id: "drawingGroup",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "中の View を、画面に出す前に 1 枚の画像に描いてから合成する modifier（Metal で描く）。枠の外は描かれない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/drawinggroup(opaque:colormode:)")!,
        stage: .card,
        properties: [
            .modifier(
                "drawingGroup", label: "opaque", .toggle(initial: false), on: true,
                summary: "不透明として描く（true なら描いていないところが黒くなる）")
        ],
        code: CodeTemplate(
            prefix: [
                "ZStack {", "    Circle()", "        .fill(.yellow)", "        .frame(width: 80, height: 80)",
                "        .offset(x: -50)", "}",
            ],
            indent: 0, call: ".frame", fixedArguments: ["width: 120", "height: 80"]),
        build: { v in
            AnyView(
                ZStack {
                    Circle()
                        .fill(.yellow)
                        .frame(width: 80, height: 80)
                        .offset(x: -50)
                }
                .frame(width: 120, height: 80)
                .apply(v.flag("drawingGroup")) { $0.drawingGroup(opaque: $1) }
                .border(.secondary)
            )
        }
    )
}
