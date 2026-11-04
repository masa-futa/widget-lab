import SwiftUI

nonisolated extension CatalogEntry {
    static let focused = CatalogEntry(
        id: "focused",
        kind: .modifier,
        topic: .focus,
        summary: "この View のフォーカスを、@FocusState の値とつなぐ modifier。値を書き換えるとフォーカスが動き、フォーカスが動くと値が変わる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focused(_:equals:)")!,
        stage: .card,
        properties: [
            .modifier(
                "focused",
                .choice(
                    [Choice("Bool", code: "$isFocused"), Choice("どの欄か", code: "$field, equals: .memo")], initial: 0),
                on: true, summary: "つなぐ @FocusState。Bool か、どの欄かを表す値（equals）。外すと、ボタンを押してもフォーカスが来ない")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"入力欄へ\") { isFocused = true }"], call: "TextField",
            fixedArguments: ["\"メモ\"", "text: $memo"], closing: ["}"]),
        build: { v in
            AnyView(FocusedDemo(choice: v.pick("focused", from: [0, 1])))
        }
    )
}

private struct FocusedDemo: View {
    enum Field: Hashable { case memo }

    /// nil なら focused をかけない
    let choice: Int?
    @FocusState private var isFocused: Bool
    @FocusState private var field: Field?
    @State private var memo = ""

    var body: some View {
        VStack(spacing: 8) {
            Button("入力欄へ") {
                if choice == 1 { field = .memo } else { isFocused = true }
            }
            .buttonStyle(.bordered)
            fieldView
            Text(choice == 1 ? "field: \(field == .memo ? ".memo" : "nil")" : "isFocused: \(isFocused)")
                .monospaced()
        }
    }

    @ViewBuilder
    private var fieldView: some View {
        let base = NoteField(title: "メモ", text: $memo)
        switch choice {
        case 0?: base.focused($isFocused)
        case 1?: base.focused($field, equals: .memo)
        default: base
        }
    }
}
