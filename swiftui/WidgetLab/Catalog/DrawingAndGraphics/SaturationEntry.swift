import SwiftUI

nonisolated extension CatalogEntry {
    static let saturation = CatalogEntry(
        id: "saturation",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "色の鮮やかさ（彩度）を変える modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/saturation(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "saturation", .slider(range: 0...2, step: 0.2, initial: 0.2), on: true, summary: "彩度の倍率（1 で元のまま、0 で白黒）")
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
                    .apply(v.number("saturation")) { $0.saturation($1) }
            )
        }
    )
}
