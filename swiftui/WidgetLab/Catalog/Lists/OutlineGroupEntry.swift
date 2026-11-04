import SwiftUI

nonisolated extension CatalogEntry {
    static let outlineGroup = CatalogEntry(
        id: "OutlineGroup",
        kind: .view,
        topic: .lists,
        summary: "木の形のデータから、開け閉めできる入れ子の行を作る View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/outlinegroup")!,
        stage: .card,
        properties: [
            .argument("children", .fixed(code: "\\.children"), required: true, summary: "子の配列を取り出すキーパス（nil なら葉）")
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "OutlineGroup", fixedArguments: ["tree"],
            trailing: " { item in\n        Text(item.name)\n    }", closing: ["}"]),
        build: { _ in
            AnyView(
                List {
                    OutlineGroup(OutlineGroupDemo.tree, children: \.children) { item in
                        Text(item.name)
                    }
                }
            )
        }
    )
}

nonisolated private struct OutlineGroupDemo: Identifiable, Sendable {
    let name: String
    var children: [OutlineGroupDemo]? = nil
    var id: String { name }

    static let tree = [
        OutlineGroupDemo(
            name: "果物",
            children: [
                OutlineGroupDemo(name: "りんご"),
                OutlineGroupDemo(
                    name: "かんきつ", children: [OutlineGroupDemo(name: "みかん"), OutlineGroupDemo(name: "ゆず")]),
            ]),
        OutlineGroupDemo(name: "野菜", children: [OutlineGroupDemo(name: "にんじん")]),
    ]
}
