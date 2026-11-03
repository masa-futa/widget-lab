import SwiftUI

nonisolated extension CatalogEntry {
    static let ellipse = CatalogEntry(
        id: "Ellipse",
        kind: .view,
        topic: .shapes,
        summary: "置かれた枠にぴったり収まる楕円の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/ellipse")!,
        stage: .card,
        properties: [
            .modifier("fill", .color(initial: 3), on: true, summary: "中を塗る色"),
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 40...240, step: 20, initial: 200), on: true,
                summary: "枠の幅（楕円の横の直径）"),
            .modifier(
                "frame", id: "frame.height", label: "height", .slider(range: 40...160, step: 20, initial: 100),
                on: true,
                summary: "枠の高さ（楕円の縦の直径）"),
        ],
        code: CodeTemplate(call: "Ellipse"),
        build: { v in
            AnyView(
                Ellipse()
                    .apply(v.color("fill")) { $0.fill($1) }
                    .frame(
                        width: v.number("frame.width").map { CGFloat($0) },
                        height: v.number("frame.height").map { CGFloat($0) })
            )
        }
    )
}
