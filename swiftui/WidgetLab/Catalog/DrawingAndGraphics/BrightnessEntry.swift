import SwiftUI

nonisolated extension CatalogEntry {
    static let brightness = CatalogEntry(
        id: "brightness",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "色を明るく（負なら暗く）する modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/brightness(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "brightness", .slider(range: -1...1, step: 0.1, initial: 0.3), on: true, summary: "足す明るさ（-1〜1。0 で元のまま）")
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
                    .apply(v.number("brightness")) { $0.brightness($1) }
            )
        }
    )
}
