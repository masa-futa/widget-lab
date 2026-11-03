import SwiftUI

nonisolated extension CatalogEntry {
    static let circle = CatalogEntry(
        id: "Circle",
        kind: .view,
        topic: .shapes,
        summary: "置かれた枠の中心に、短い辺を直径にして描く円の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/circle")!,
        stage: .card,
        properties: [
            .modifier(
                "trim", label: "to", .slider(range: 0.1...1, step: 0.05, initial: 0.75), on: true,
                summary: "線をどこまで描くか（0〜1。始まりは右端）"),
            .modifier("stroke", .color(initial: 4), on: true, summary: "線の色（OFF でほかの線も OFF なら、中を塗る）"),
            .modifier(
                "stroke", id: "stroke.lineWidth", label: "lineWidth", .slider(range: 2...24, step: 2, initial: 12),
                on: true, summary: "線の太さ"),
        ],
        code: CodeTemplate(call: "Circle", suffix: [".frame(width: 120, height: 120)"]),
        build: { v in
            AnyView(
                ShapeStyleDemo.styled(
                    Circle().trim(from: 0, to: CGFloat(v.number("trim") ?? 1)), fill: nil, stroke: v.color("stroke"),
                    lineWidth: v.number("stroke.lineWidth")
                )
                .frame(width: 120, height: 120)
            )
        }
    )
}
