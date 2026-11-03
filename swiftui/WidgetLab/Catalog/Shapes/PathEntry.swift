import SwiftUI

nonisolated extension CatalogEntry {
    static let path = CatalogEntry(
        id: "Path",
        kind: .view,
        topic: .shapes,
        summary: "線や曲線をつないで、好きな形を描く Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/path")!,
        stage: .card,
        properties: [
            .modifier("fill", .color(initial: 1), on: true, summary: "中を塗る色（OFF なら前景の色）"),
            .modifier("stroke", .color(initial: 4), summary: "縁の線の色"),
            .modifier(
                "stroke", id: "stroke.lineWidth", label: "lineWidth", .slider(range: 1...16, step: 1, initial: 6),
                summary: "縁の線の太さ"),
        ],
        code: CodeTemplate(
            call: "Path",
            trailing: " { path in\n    path.move(to: CGPoint(x: 20, y: 100))\n"
                + "    path.addLine(to: CGPoint(x: 100, y: 20))\n"
                + "    path.addQuadCurve(to: CGPoint(x: 180, y: 100), control: CGPoint(x: 180, y: 20))\n"
                + "    path.closeSubpath()\n}",
            suffix: [".frame(width: 200, height: 120)"]),
        build: { v in
            AnyView(
                ShapeStyleDemo.styled(
                    Path { path in
                        path.move(to: CGPoint(x: 20, y: 100))
                        path.addLine(to: CGPoint(x: 100, y: 20))
                        path.addQuadCurve(to: CGPoint(x: 180, y: 100), control: CGPoint(x: 180, y: 20))
                        path.closeSubpath()
                    },
                    fill: v.color("fill"), stroke: v.color("stroke"), lineWidth: v.number("stroke.lineWidth")
                )
                .frame(width: 200, height: 120)
            )
        }
    )
}
