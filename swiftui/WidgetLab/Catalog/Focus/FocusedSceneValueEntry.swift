import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedSceneValue = CatalogEntry(
        id: "focusedSceneValue",
        kind: .modifier,
        topic: .focus,
        summary: "かけた View がシーン（窓）の中にあるあいだ、値を FocusedValues に出す modifier。フォーカスがどこにあっても（なくても）読める。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focusedscenevalue(_:_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "focusedSceneValue", .fixed(code: "\\.noteTitle, \"メモ帳\""), on: true,
                summary: "出す値の key path と値。入力欄を選ばなくても、上の札に出る。シーンぜんたいに効くので、全画面で試す")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    NoteTitleLabel()  // @FocusedValue(\\.noteTitle) を出す\n    TextField(\"メモ\", text: $memo)\n}",
            closing: ["", "extension FocusedValues {", "    @Entry var noteTitle: String?", "}"]),
        build: { v in
            AnyView(
                FocusedSceneValueDemo().apply(v["focusedSceneValue"]) { view, _ in
                    view.focusedSceneValue(\.demoNoteTitle, "メモ帳")
                })
        }
    )
}

private struct FocusedSceneValueDemo: View {
    @State private var memo = ""

    var body: some View {
        VStack(spacing: 8) {
            TitleReader()
            NoteField(title: "メモ", text: $memo)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }

    struct TitleReader: View {
        @FocusedValue(\.demoNoteTitle) private var title

        var body: some View {
            FocusReadout(title: "読めた題名", value: title)
        }
    }
}
