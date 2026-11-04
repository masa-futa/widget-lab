import SwiftUI

nonisolated extension CatalogEntry {
    static let moveDisabled = CatalogEntry(
        id: "moveDisabled",
        kind: .modifier,
        topic: .lists,
        summary: "List の編集モードで、その行を並べ替えられないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/movedisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "moveDisabled", .fixed(code: "item == \"りんご\""), on: true,
                summary: "並べ替えられなくする条件（りんごの行は、つまみが出ない）")
        ],
        code: CodeTemplate(
            prefix: ["List {", "    ForEach(items, id: \\.self) { item in"], indent: 8, call: "Text",
            fixedArguments: ["item"],
            closing: [
                "    }", "    .onMove { items.move(fromOffsets: $0, toOffset: $1) }", "}",
                ".environment(\\.editMode, .constant(.active))",
            ]),
        build: { v in
            AnyView(MoveDisabledDemo(disables: v["moveDisabled"] != nil))
        }
    )
}

private struct MoveDisabledDemo: View {
    let disables: Bool
    @State private var items = ["りんご", "みかん", "ぶどう"]
    /// 編集モードをこの見本の中だけに持つ（詳細画面の NavigationStack の編集モードを切り替えないように）
    @State private var editMode = EditMode.active

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .apply(disables ? () : nil) { view, _ in
                        view.moveDisabled(item == "りんご")
                    }
            }
            .onMove { items.move(fromOffsets: $0, toOffset: $1) }
        }
        .environment(\.editMode, $editMode)
    }
}
