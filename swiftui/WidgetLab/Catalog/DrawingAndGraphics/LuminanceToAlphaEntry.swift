import SwiftUI

nonisolated extension CatalogEntry {
    static let luminanceToAlpha = CatalogEntry(
        id: "luminanceToAlpha",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "明るさを不透明度にして、黒の濃淡で描く modifier。暗いところほど透ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/luminancetoalpha()")!,
        stage: .card,
        properties: [
            .modifier("luminanceToAlpha", .fixed(code: ""), on: true, summary: "明るさを不透明度にする")
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
                    .apply(v.flag("luminanceToAlpha")) { view, _ in view.luminanceToAlpha() }
            )
        }
    )
}
