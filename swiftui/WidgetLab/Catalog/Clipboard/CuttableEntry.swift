import SwiftUI

nonisolated extension CatalogEntry {
    static let cuttable = CatalogEntry(
        id: "cuttable",
        kind: .modifier,
        topic: .clipboard,
        summary: "システムの「切り取り」の操作で、クリップボードに移す物を返す処理を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/cuttable(for:action:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "cuttable", id: "cuttable.for", label: "for", .fixed(code: "String.self"), required: true,
                summary: "移す物の型（Transferable）"),
            .modifier(
                "cuttable", id: "cuttable.action", label: "action",
                .fixed(code: "{ let cut = fruits; fruits = []; return cut }"), on: true,
                summary: "移す物を返し、元から消す処理。札にフォーカスを当て、キーボードの ⌘X で切り取る（iPhone ではハードウェアキーボードをつなぐ）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(fruits.joined(separator: \"・\"))"], indent: 4, call: ".focusable"),
        build: { v in
            AnyView(ClipboardDemo(command: v["cuttable.action"] != nil ? .cut : nil))
        }
    )
}
