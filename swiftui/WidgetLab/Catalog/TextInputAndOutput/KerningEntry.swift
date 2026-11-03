import SwiftUI

nonisolated extension CatalogEntry {
    static let kerning = CatalogEntry(
        id: "kerning",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字と文字の間隔を、フォントの既定の間隔からずらす modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/kerning(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "kerning", .slider(range: -4...12, step: 1, initial: 8), on: true,
                summary: "ずらす量（ポイント。マイナスで詰める）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Kerning 字間\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("Kerning 字間")
                    .apply(v.number("kerning")) { $0.kerning($1) }
                    .font(.title)
            )
        }
    )
}
