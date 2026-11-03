import SwiftUI

nonisolated extension CatalogEntry {
    static let bold = CatalogEntry(
        id: "bold",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字を太字にする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/bold(_:)")!,
        stage: .card,
        properties: [
            .modifier("bold", .toggle(initial: true), on: true, summary: "太字にするか（false なら付けないのと同じ）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Bold 太字\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("Bold 太字")
                    .apply(v.flag("bold")) { $0.bold($1) }
                    .font(.title)
            )
        }
    )
}
