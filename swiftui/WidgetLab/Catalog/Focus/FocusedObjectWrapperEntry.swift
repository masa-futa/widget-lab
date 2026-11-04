import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedObjectWrapper = CatalogEntry(
        id: "FocusedObject",
        kind: .propertyWrapper,
        topic: .focus,
        summary: "フォーカスのある View（か、その親）が .focusedObject で出した ObservableObject を読む。中身が変わっても描き直す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/focusedobject")!,
        stage: .card,
        properties: [
            .wrapper("FocusedObject", summary: "外すと、どのメモを選んでも上の札は「なし」のまま")
        ],
        code: CodeTemplate(
            call: "FocusedObject",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 札（NoteLabel）",
                    "@FocusedObject private var note: Note?",
                    "var body: some View {",
                    "    Text(\"フォーカスのあるメモ: \\(note?.title ?? \"なし\")\")",
                    "}",
                    "",
                    "// 入力欄（NoteLabel と同じ画面）",
                    "TextField(\"メモ A\", text: $noteA.title)",
                    "    .focusedObject(noteA)",
                ],
                withoutWrapper: [
                    "// 札（NoteLabel）",
                    "private var note: Note? = nil  // フォーカスを見ない",
                    "var body: some View {",
                    "    Text(\"フォーカスのあるメモ: \\(note?.title ?? \"なし\")\")",
                    "}",
                    "",
                    "// 入力欄（NoteLabel と同じ画面）",
                    "TextField(\"メモ A\", text: $noteA.title)",
                    "    .focusedObject(noteA)",
                ])),
        build: { v in
            AnyView(FocusedObjectWrapperDemo(reads: v["FocusedObject"] != nil))
        }
    )
}

private struct FocusedObjectWrapperDemo: View {
    let reads: Bool
    @StateObject private var noteA = DemoNote("")
    @StateObject private var noteB = DemoNote("")

    var body: some View {
        VStack(spacing: 8) {
            if reads {
                FocusedNoteReader()
            } else {
                FocusReadout(title: "フォーカスのあるメモ", value: nil)
            }
            NoteField(title: "メモ A", text: $noteA.title)
                .focusedObject(noteA)
            NoteField(title: "メモ B", text: $noteB.title)
                .focusedObject(noteB)
        }
    }
}
