import SwiftUI

nonisolated extension CatalogEntry {
    static let italic = CatalogEntry(
        id: "italic",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字を斜体にする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/italic(_:)")!,
        stage: .card,
        properties: [
            .modifier("italic", .toggle(initial: true), on: true, summary: "斜体にするか（false なら付けないのと同じ）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Italic 斜体\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("Italic 斜体")
                    .apply(v.flag("italic")) { $0.italic($1) }
                    .font(.title)
            )
        }
    )
}
