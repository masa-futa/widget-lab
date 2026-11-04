import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedBinding = CatalogEntry(
        id: "FocusedBinding",
        kind: .propertyWrapper,
        topic: .focus,
        summary: "フォーカスのある View（か、その親）が出した Binding を、ほどいて読み書きする。フォーカスのあるメモを、外のボタンから書き換えられる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/focusedbinding")!,
        stage: .card,
        properties: [
            .wrapper("FocusedBinding", summary: "外すと @FocusedValue で Binding のまま受け取り、wrappedValue を書き換える")
        ],
        code: CodeTemplate(
            call: "FocusedBinding",
            wrapper: WrapperCode(
                withWrapper: [
                    "// ボタン（ClearButton）",
                    "@FocusedBinding(\\.noteText) private var text",
                    "var body: some View {",
                    "    Button(\"フォーカスのあるメモを消す\") { text = \"\" }",
                    "        .disabled(text == nil)",
                    "}",
                    "",
                    "// 入力欄（ClearButton と同じ画面）",
                    "TextField(\"メモ A\", text: $memoA)",
                    "    .focusedValue(\\.noteText, $memoA)",
                ],
                withoutWrapper: [
                    "// ボタン（ClearButton）",
                    "@FocusedValue(\\.noteText) private var text  // Binding<String>?",
                    "var body: some View {",
                    "    Button(\"フォーカスのあるメモを消す\") { text?.wrappedValue = \"\" }",
                    "        .disabled(text == nil)",
                    "}",
                    "",
                    "// 入力欄（ClearButton と同じ画面）",
                    "TextField(\"メモ A\", text: $memoA)",
                    "    .focusedValue(\\.noteText, $memoA)",
                ])),
        build: { v in
            AnyView(FocusedBindingDemo(unwraps: v["FocusedBinding"] != nil))
        }
    )
}

private struct FocusedBindingDemo: View {
    let unwraps: Bool
    @State private var memoA = "りんごを買う"
    @State private var memoB = "ぶどうを買う"

    var body: some View {
        VStack(spacing: 8) {
            if unwraps {
                BindingButton()
            } else {
                ValueButton()
            }
            NoteField(title: "メモ A", text: $memoA)
                .focusedValue(\.demoNoteText, $memoA)
            NoteField(title: "メモ B", text: $memoB)
                .focusedValue(\.demoNoteText, $memoB)
        }
    }

    struct BindingButton: View {
        @FocusedBinding(\.demoNoteText) private var text

        var body: some View {
            Button("フォーカスのあるメモを消す") { text = "" }
                .buttonStyle(.bordered)
                .disabled(text == nil)
        }
    }

    struct ValueButton: View {
        /// Binding<String>?
        @FocusedValue(\.demoNoteText) private var text

        var body: some View {
            Button("フォーカスのあるメモを消す") { text?.wrappedValue = "" }
                .buttonStyle(.bordered)
                .disabled(text == nil)
        }
    }
}
