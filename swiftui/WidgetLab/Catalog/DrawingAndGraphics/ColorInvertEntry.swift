import SwiftUI

nonisolated extension CatalogEntry {
    static let colorInvert = CatalogEntry(
        id: "colorInvert",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "色を反転する modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/colorinvert()")!,
        stage: .card,
        properties: [
            .modifier("colorInvert", .fixed(code: ""), on: true, summary: "色を反転する")
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
                    .apply(v.flag("colorInvert")) { view, _ in view.colorInvert() }
            )
        }
    )
}
