import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedValue = CatalogEntry(
        id: "focusedValue",
        kind: .modifier,
        topic: .focus,
        summary: "フォーカスがこの View（か、その中）にあるあいだ、値を FocusedValues に出す modifier。ほかの View は @FocusedValue で読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focusedvalue(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "focusedValue", .fixed(code: "\\.noteTitle, \"メモ A\""), on: true,
                summary: "出す値の key path と値。外すと、メモ A を選んでも上の札は「なし」のまま")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    NoteTitleLabel()  // @FocusedValue(\\.noteTitle) を出す"], call: "TextField",
            fixedArguments: ["\"メモ A\"", "text: $memoA"],
            closing: [
                "    TextField(\"メモ B\", text: $memoB)",
                "        .focusedValue(\\.noteTitle, \"メモ B\")",
                "}",
                "",
                "extension FocusedValues {",
                "    @Entry var noteTitle: String?",
                "}",
            ]),
        build: { v in
            AnyView(FocusedValueDemo(exposesA: v["focusedValue"] != nil))
        }
    )
}

private struct FocusedValueDemo: View {
    let exposesA: Bool
    @State private var memoA = ""
    @State private var memoB = ""

    var body: some View {
        VStack(spacing: 8) {
            TitleReader()
            NoteField(title: "メモ A", text: $memoA)
                .apply(exposesA ? () : nil) { view, _ in view.focusedValue(\.demoNoteTitle, "メモ A") }
            NoteField(title: "メモ B", text: $memoB)
                .focusedValue(\.demoNoteTitle, "メモ B")
        }
    }

    struct TitleReader: View {
        @FocusedValue(\.demoNoteTitle) private var title

        var body: some View {
            FocusReadout(title: "フォーカスのあるメモ", value: title)
        }
    }
}
