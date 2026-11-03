import SwiftUI

nonisolated extension CatalogEntry {
    static let color = CatalogEntry(
        id: "Color",
        kind: .view,
        topic: .drawingAndGraphics,
        summary: "色。View としては、置かれた枠いっぱいをその色で塗る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/color")!,
        stage: .card,
        properties: [
            .argument("red", .slider(range: 0...1, step: 0.1, initial: 0.2), required: true, summary: "赤の強さ（0〜1）"),
            .argument("green", .slider(range: 0...1, step: 0.1, initial: 0.6), required: true, summary: "緑の強さ"),
            .argument("blue", .slider(range: 0...1, step: 0.1, initial: 0.9), required: true, summary: "青の強さ"),
            .argument("opacity", .slider(range: 0...1, step: 0.1, initial: 0.5), summary: "不透明度（OFF なら 1）"),
        ],
        code: CodeTemplate(call: "Color", suffix: [".frame(width: 160, height: 100)"]),
        build: { v in
            AnyView(
                Color(
                    red: v.number("red") ?? 0, green: v.number("green") ?? 0, blue: v.number("blue") ?? 0,
                    opacity: v.number("opacity") ?? 1
                )
                .frame(width: 160, height: 100)
            )
        }
    )
}
