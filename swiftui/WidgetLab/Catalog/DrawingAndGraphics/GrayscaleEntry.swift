import SwiftUI

nonisolated extension CatalogEntry {
    static let grayscale = CatalogEntry(
        id: "grayscale",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "色を灰色に近づける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/grayscale(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "grayscale", .slider(range: 0...1, step: 0.1, initial: 0.8), on: true,
                summary: "灰色に近づける量（0 で元のまま、1 で白黒）")
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
                    .apply(v.number("grayscale")) { $0.grayscale($1) }
            )
        }
    )
}
