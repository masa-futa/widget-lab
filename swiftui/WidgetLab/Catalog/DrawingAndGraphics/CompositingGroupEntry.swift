import SwiftUI

nonisolated extension CatalogEntry {
    static let compositingGroup = CatalogEntry(
        id: "compositingGroup",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "中の View を 1 枚の絵に合成してから、あとの効果（不透明度など）をかける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/compositinggroup()")!,
        stage: .card,
        properties: [
            .modifier(
                "compositingGroup", .fixed(code: ""), on: true,
                summary: "1 枚に合成してから透かす（OFF なら円ごとに透け、重なりが見える）")
        ],
        code: CodeTemplate(
            call: "ZStack",
            trailing: " {\n    Circle().fill(.red).frame(width: 100, height: 100).offset(x: -30)\n"
                + "    Circle().fill(.blue).frame(width: 100, height: 100).offset(x: 30)\n}",
            suffix: [".opacity(0.5)"]),
        build: { v in
            AnyView(
                ZStack {
                    Circle().fill(.red).frame(width: 100, height: 100).offset(x: -30)
                    Circle().fill(.blue).frame(width: 100, height: 100).offset(x: 30)
                }
                .apply(v.flag("compositingGroup")) { view, _ in view.compositingGroup() }
                .opacity(0.5)
            )
        }
    )
}
