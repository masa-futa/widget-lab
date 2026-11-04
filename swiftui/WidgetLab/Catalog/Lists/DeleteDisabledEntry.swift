import SwiftUI

nonisolated extension CatalogEntry {
    static let deleteDisabled = CatalogEntry(
        id: "deleteDisabled",
        kind: .modifier,
        topic: .lists,
        summary: "List で、その行を消せないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/deletedisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "deleteDisabled", .fixed(code: "item == \"りんご\""), on: true,
                summary: "消せなくする条件（りんごの行は、削除の印が出ない）")
        ],
        code: CodeTemplate(
            prefix: ["List {", "    ForEach(items, id: \\.self) { item in"], indent: 8, call: "Text",
            fixedArguments: ["item"],
            closing: [
                "    }", "    .onDelete { items.remove(atOffsets: $0) }", "}",
                ".environment(\\.editMode, .constant(.active))",
            ]),
        build: { v in
            AnyView(DeleteDisabledDemo(disables: v["deleteDisabled"] != nil))
        }
    )
}

private struct DeleteDisabledDemo: View {
    let disables: Bool
    @State private var items = ["りんご", "みかん", "ぶどう"]
    /// 編集モードをこの見本の中だけに持つ（詳細画面の NavigationStack の編集モードを切り替えないように）
    @State private var editMode = EditMode.active

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .apply(disables ? () : nil) { view, _ in
                        view.deleteDisabled(item == "りんご")
                    }
            }
            .onDelete { items.remove(atOffsets: $0) }
        }
        .environment(\.editMode, $editMode)
    }
}
