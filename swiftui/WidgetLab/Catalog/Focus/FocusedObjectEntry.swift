import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedObject = CatalogEntry(
        id: "focusedObject",
        kind: .modifier,
        topic: .focus,
        summary: "フォーカスがこの View（か、その中）にあるあいだ、ObservableObject を出す modifier。ほかの View は @FocusedObject で読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focusedobject(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "focusedObject", .fixed(code: "noteA"), on: true,
                summary: "出す物（ObservableObject）。外すと、メモ A を選んでも上の札は「なし」のまま")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    NoteLabel()  // @FocusedObject var note: Note? を出す"], call: "TextField",
            fixedArguments: ["\"メモ A\"", "text: $noteA.title"],
            closing: ["    TextField(\"メモ B\", text: $noteB.title)", "        .focusedObject(noteB)", "}"]),
        build: { v in
            AnyView(FocusedObjectDemo(exposesA: v["focusedObject"] != nil))
        }
    )
}

private struct FocusedObjectDemo: View {
    let exposesA: Bool
    @StateObject private var noteA = DemoNote("")
    @StateObject private var noteB = DemoNote("")

    var body: some View {
        VStack(spacing: 8) {
            FocusedNoteReader()
            NoteField(title: "メモ A", text: $noteA.title)
                .apply(exposesA ? () : nil) { view, _ in view.focusedObject(noteA) }
            NoteField(title: "メモ B", text: $noteB.title)
                .focusedObject(noteB)
        }
    }
}

/// @FocusedObject で読んだメモの題名を出す札
struct FocusedNoteReader: View {
    @FocusedObject private var note: DemoNote?

    var body: some View {
        FocusReadout(title: "フォーカスのあるメモ", value: note.map { $0.title.isEmpty ? "（空）" : $0.title })
    }
}
