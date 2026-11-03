import SwiftUI

nonisolated extension CatalogEntry {
    static let hidden = CatalogEntry(
        id: "hidden",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "View を隠す modifier。見えなくなるが、場所は取ったまま。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/hidden()")!,
        stage: .card,
        properties: [
            .modifier("hidden", .fixed(code: ""), on: true, summary: "隠す。左右の文字の間は空いたまま")
        ],
        code: CodeTemplate(
            prefix: ["HStack {", "    Text(\"左\")"], call: "Text", fixedArguments: ["\"真ん中\""],
            closing: ["    Text(\"右\")", "}"]),
        build: { v in
            AnyView(
                HStack {
                    Text("左")
                    Text("真ん中")
                        .apply(v["hidden"] != nil ? () : nil) { view, _ in view.hidden() }
                    Text("右")
                }
                .padding(8)
                .border(.secondary)
            )
        }
    )
}
