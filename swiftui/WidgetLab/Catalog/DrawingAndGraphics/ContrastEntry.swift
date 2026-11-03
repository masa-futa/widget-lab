import SwiftUI

nonisolated extension CatalogEntry {
    static let contrast = CatalogEntry(
        id: "contrast",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "明るいところと暗いところの差（コントラスト）を変える modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/contrast(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "contrast", .slider(range: 0...3, step: 0.25, initial: 2), on: true, summary: "差の倍率（1 で元のまま、0 で灰色一色）")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 80"]),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 80)
                    .apply(v.number("contrast")) { $0.contrast($1) }
            )
        }
    )
}
