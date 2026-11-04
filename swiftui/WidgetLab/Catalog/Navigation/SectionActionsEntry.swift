import SwiftUI

nonisolated extension CatalogEntry {
    static let sectionActions = CatalogEntry(
        id: "sectionActions",
        kind: .modifier,
        topic: .navigation,
        summary: "まとまり（Section）に、足すなどの操作のボタンを添える modifier。iOS ではまとまりの中身の後ろに並ぶ。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/sectionactions(content:)")!,
        stage: .card,
        properties: [
            .modifier(
                "sectionActions", label: "content", .fixed(code: "{ Button(\"果物を足す\", systemImage: \"plus\") { } }"),
                on: true, summary: "まとまりに添える操作")
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Section", fixedArguments: ["\"果物\""],
            trailing: " {\n        Text(\"りんご\")\n        Text(\"みかん\")\n    }", closing: ["}"]),
        build: { v in
            AnyView(
                List {
                    Section("果物") {
                        Text("りんご")
                        Text("みかん")
                    }
                    .apply(v["sectionActions"] != nil ? () : nil) { view, _ in
                        view.sectionActions { Button("果物を足す", systemImage: "plus") {} }
                    }
                })
        }
    )
}
