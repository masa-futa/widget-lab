import SwiftUI

nonisolated extension CatalogEntry {
    static let unredacted = CatalogEntry(
        id: "unredacted",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "外側の redacted で伏せられていても、この View だけは伏せずに見せる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/unredacted()")!,
        stage: .card,
        properties: [
            .modifier("unredacted", .fixed(code: ""), on: true, summary: "伏せずに見せる")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"山田 花子\")"], call: "Text", fixedArguments: ["\"読み込み済み\""],
            closing: ["}", ".redacted(reason: .placeholder)"]),
        build: { v in
            AnyView(
                VStack {
                    Text("山田 花子")
                    Text("読み込み済み")
                        .apply(v["unredacted"] != nil ? () : nil) { view, _ in view.unredacted() }
                }
                .redacted(reason: .placeholder)
            )
        }
    )
}
