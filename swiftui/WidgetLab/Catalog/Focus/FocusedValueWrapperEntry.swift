import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedValueWrapper = CatalogEntry(
        id: "FocusedValue",
        kind: .propertyWrapper,
        topic: .focus,
        summary: "フォーカスのある View（か、その親）が .focusedValue で出した値を読む。フォーカスが動くと描き直す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/focusedvalue")!,
        stage: .card,
        properties: [
            .wrapper("FocusedValue", summary: "外すと、どのメモを選んでも上の札は「なし」のまま")
        ],
        code: CodeTemplate(
            call: "FocusedValue",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 札（NoteTitleLabel）",
                    "@FocusedValue(\\.noteTitle) private var title",
                    "var body: some View {",
                    "    Text(\"フォーカスのあるメモ: \\(title ?? \"なし\")\")",
                    "}",
                    "",
                    "// 入力欄（NoteTitleLabel と同じ画面）",
                    "TextField(\"メモ A\", text: $memoA)",
                    "    .focusedValue(\\.noteTitle, \"メモ A\")",
                ],
                withoutWrapper: [
                    "// 札（NoteTitleLabel）",
                    "private var title: String? = nil  // フォーカスを見ない",
                    "var body: some View {",
                    "    Text(\"フォーカスのあるメモ: \\(title ?? \"なし\")\")",
                    "}",
                    "",
                    "// 入力欄（NoteTitleLabel と同じ画面）",
                    "TextField(\"メモ A\", text: $memoA)",
                    "    .focusedValue(\\.noteTitle, \"メモ A\")",
                ])),
        build: { v in
            AnyView(FocusedValueWrapperDemo(reads: v["FocusedValue"] != nil))
        }
    )
}

private struct FocusedValueWrapperDemo: View {
    let reads: Bool
    @State private var memoA = ""
    @State private var memoB = ""

    var body: some View {
        VStack(spacing: 8) {
            if reads {
                ReadingLabel()
            } else {
                FixedLabel()
            }
            NoteField(title: "メモ A", text: $memoA)
                .focusedValue(\.demoNoteTitle, "メモ A")
            NoteField(title: "メモ B", text: $memoB)
                .focusedValue(\.demoNoteTitle, "メモ B")
        }
    }

    struct ReadingLabel: View {
        @FocusedValue(\.demoNoteTitle) private var title

        var body: some View {
            FocusReadout(title: "フォーカスのあるメモ", value: title)
        }
    }

    struct FixedLabel: View {
        /// フォーカスを見ない
        private var title: String? = nil

        var body: some View {
            FocusReadout(title: "フォーカスのあるメモ", value: title)
        }
    }
}
