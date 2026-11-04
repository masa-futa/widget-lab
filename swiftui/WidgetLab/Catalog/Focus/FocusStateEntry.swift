import SwiftUI

nonisolated extension CatalogEntry {
    static let focusState = CatalogEntry(
        id: "FocusState",
        kind: .propertyWrapper,
        topic: .focus,
        summary: "フォーカスがどこにあるかを持つ値。.focused でつないだ View にフォーカスが来ると変わり、書き換えるとフォーカスを動かせる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/focusstate")!,
        stage: .behavior,
        properties: [
            .wrapper("FocusState", summary: "外すと @State の Bool になり、.focused につなげない。ボタンで true にしても、入力欄にフォーカスが来ない")
        ],
        code: CodeTemplate(
            call: "FocusState",
            wrapper: WrapperCode(
                withWrapper: [
                    "@FocusState private var isFocused: Bool",
                    "",
                    "var body: some View {",
                    "    Button(\"入力欄へ\") { isFocused = true }",
                    "    TextField(\"メモ\", text: $memo)",
                    "        .focused($isFocused)",
                    "}",
                ],
                withoutWrapper: [
                    "@State private var isFocused = false  // フォーカスとつながらない",
                    "",
                    "var body: some View {",
                    "    Button(\"入力欄へ\") { isFocused = true }",
                    "    TextField(\"メモ\", text: $memo)",
                    "}",
                ])),
        build: { v in
            v["FocusState"] != nil ? AnyView(FocusStateDemo.WithFocusState()) : AnyView(FocusStateDemo.WithState())
        }
    )
}

private enum FocusStateDemo {
    struct WithFocusState: View {
        @FocusState private var isFocused: Bool
        @State private var memo = ""
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            VStack(spacing: 8) {
                Button("入力欄へ") { isFocused = true }
                    .buttonStyle(.bordered)
                NoteField(title: "メモ", text: $memo)
                    .focused($isFocused)
                Text("isFocused: \(isFocused)")
            }
            .onChange(of: isFocused) { recorder?.log("isFocused を \(isFocused) にした") }
        }
    }

    struct WithState: View {
        /// フォーカスとつながらない
        @State private var isFocused = false
        @State private var memo = ""
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            VStack(spacing: 8) {
                Button("入力欄へ") { isFocused = true }
                    .buttonStyle(.bordered)
                NoteField(title: "メモ", text: $memo)
                Text("isFocused: \(isFocused)")
            }
            .onChange(of: isFocused) { recorder?.log("isFocused を \(isFocused) にした（フォーカスは動かない）") }
        }
    }
}
