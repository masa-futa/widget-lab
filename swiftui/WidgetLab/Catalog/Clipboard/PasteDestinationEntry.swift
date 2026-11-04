import SwiftUI

nonisolated extension CatalogEntry {
    static let pasteDestination = CatalogEntry(
        id: "pasteDestination",
        kind: .modifier,
        topic: .clipboard,
        summary: "システムの「貼り付け」の操作で、クリップボードの物を受け取る処理を決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/pastedestination(for:action:validator:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "pasteDestination", id: "pasteDestination.for", label: "for", .fixed(code: "String.self"),
                required: true, summary: "受け取る物の型（Transferable）"),
            .modifier(
                "pasteDestination", id: "pasteDestination.action", label: "action", .fixed(code: "{ fruits += $0 }"),
                on: true, summary: "受け取ったときの処理。札にフォーカスを当て、キーボードの ⌘V で貼り付ける（iPhone ではハードウェアキーボードをつなぐ）"),
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["fruits.joined(separator: \"・\")"], suffix: [".focusable()"]),
        build: { v in
            AnyView(ClipboardDemo(command: v["pasteDestination.action"] != nil ? .paste : nil))
        }
    )
}
