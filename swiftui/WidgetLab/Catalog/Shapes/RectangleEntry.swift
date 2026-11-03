import SwiftUI

nonisolated extension CatalogEntry {
    static let rectangle = CatalogEntry(
        id: "Rectangle",
        kind: .view,
        topic: .shapes,
        summary: "置かれた枠いっぱいの長方形の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/rectangle")!,
        stage: .card,
        properties: [
            .modifier("fill", .color(initial: 4), on: true, summary: "中を塗る色（OFF なら前景の色）"),
            .modifier(
                "stroke", .color(initial: 0), required: true,
                summary: "縁の線の色（線の太さが ON のときだけ書く）"),
            .modifier(
                "stroke", id: "stroke.lineWidth", label: "lineWidth", .slider(range: 1...16, step: 1, initial: 6),
                summary: "縁の線の太さ"),
        ],
        code: CodeTemplate(call: "Rectangle", suffix: [".frame(width: 160, height: 100)"]),
        build: { v in
            AnyView(
                ShapeStyleDemo.styled(
                    Rectangle(), fill: v.color("fill"),
                    stroke: v.number("stroke.lineWidth") != nil ? v.color("stroke") : nil,
                    lineWidth: v.number("stroke.lineWidth")
                )
                .frame(width: 160, height: 100)
            )
        }
    )
}
