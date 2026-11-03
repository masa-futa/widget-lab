import SwiftUI

nonisolated extension CatalogEntry {
    static let capsule = CatalogEntry(
        id: "Capsule",
        kind: .view,
        topic: .shapes,
        summary: "短い辺の両端を半円にした、カプセルの形の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/capsule")!,
        stage: .card,
        properties: [
            .argument(
                "style", .choice([Choice(".circular"), Choice(".continuous")], initial: 0),
                summary: "丸みの形（OFF なら .circular）"),
            .modifier("fill", .color(initial: 5), on: true, summary: "中を塗る色"),
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 40...240, step: 20, initial: 200), on: true,
                summary: "枠の幅"),
            .modifier(
                "frame", id: "frame.height", label: "height", .slider(range: 20...160, step: 20, initial: 60), on: true,
                summary: "枠の高さ（縦を長くすると、上下が丸くなる）"),
        ],
        code: CodeTemplate(call: "Capsule"),
        build: { v in
            AnyView(
                Capsule(style: v.pick("style", from: [RoundedCornerStyle.circular, .continuous]) ?? .circular)
                    .apply(v.color("fill")) { $0.fill($1) }
                    .frame(
                        width: v.number("frame.width").map { CGFloat($0) },
                        height: v.number("frame.height").map { CGFloat($0) })
            )
        }
    )
}
