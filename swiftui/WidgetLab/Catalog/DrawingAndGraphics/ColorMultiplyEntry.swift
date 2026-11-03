import SwiftUI

nonisolated extension CatalogEntry {
    static let colorMultiply = CatalogEntry(
        id: "colorMultiply",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "色に、決めた色を掛け合わせる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/colormultiply(_:)")!,
        stage: .card,
        properties: [
            .modifier("colorMultiply", .color(initial: 4), on: true, summary: "掛け合わせる色（白なら元のまま）")
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
                    .apply(v.color("colorMultiply")) { $0.colorMultiply($1) }
            )
        }
    )
}
