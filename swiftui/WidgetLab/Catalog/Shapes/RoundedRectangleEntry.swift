import SwiftUI

nonisolated extension CatalogEntry {
    static let roundedRectangle = CatalogEntry(
        id: "RoundedRectangle",
        kind: .view,
        topic: .shapes,
        summary: "角を丸めた長方形の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/roundedrectangle")!,
        stage: .card,
        properties: [
            .argument(
                "cornerRadius", .slider(range: 0...50, step: 5, initial: 25), required: true, summary: "角の丸みの半径"),
            .argument(
                "style", .choice([Choice(".circular"), Choice(".continuous")], initial: 0),
                summary: "丸みの形（.circular は円弧、.continuous はなめらかにつなぐ。OFF なら .continuous）"),
            .modifier("fill", .color(initial: 4), on: true, summary: "中を塗る色（OFF なら前景の色）"),
        ],
        code: CodeTemplate(call: "RoundedRectangle", suffix: [".frame(width: 160, height: 100)"]),
        build: { v in
            AnyView(
                RoundedRectangle(
                    cornerRadius: CGFloat(v.number("cornerRadius") ?? 0),
                    style: v.pick("style", from: [RoundedCornerStyle.circular, .continuous]) ?? .continuous
                )
                .apply(v.color("fill")) { $0.fill($1) }
                .frame(width: 160, height: 100)
            )
        }
    )
}
