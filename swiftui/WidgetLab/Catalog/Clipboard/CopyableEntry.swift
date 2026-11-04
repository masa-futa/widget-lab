import SwiftUI

nonisolated extension CatalogEntry {
    static let copyable = CatalogEntry(
        id: "copyable",
        kind: .modifier,
        topic: .clipboard,
        summary: "システムの「コピー」の操作で、クリップボードに入れる物を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/copyable(_:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "copyable", .fixed(code: "fruits"), on: true,
                summary: "コピーする物（Transferable の配列）。札にフォーカスを当て、キーボードの ⌘C でコピーする（iPhone ではハードウェアキーボードをつなぐ）")
        ],
        code: CodeTemplate(
            prefix: ["Text(fruits.joined(separator: \"・\"))"], indent: 4, call: ".focusable"),
        build: { v in
            AnyView(ClipboardDemo(command: v["copyable"] != nil ? .copy : nil))
        }
    )
}
