import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollDismissesKeyboard = CatalogEntry(
        id: "scrollDismissesKeyboard",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "スクロールしたときに、出ているキーボードを閉じるかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrolldismisseskeyboard(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollDismissesKeyboard",
                .choice(
                    [Choice(".automatic"), Choice(".immediately"), Choice(".interactively"), Choice(".never")],
                    initial: 1),
                on: true, summary: "閉じ方（.interactively は指に合わせて下げる。入力欄をタップしてからスクロールする）")
        ],
        code: CodeTemplate(
            call: "ScrollView",
            trailing: " {\n    TextField(\"メモ\", text: $memo)\n        .textFieldStyle(.bordered)\n"
                + "    ForEach(0..<20, id: \\.self) { i in\n        Text(\"行 \\(i)\")\n    }\n}"),
        build: { v in
            AnyView(
                ScrollView {
                    TextInputDemo("") { text in
                        TextField("メモ", text: text)
                            .textFieldStyle(.bordered)
                    }
                    ForEach(0..<20, id: \.self) { i in
                        Text("行 \(i)")
                    }
                }
                .apply(
                    v.pick(
                        "scrollDismissesKeyboard",
                        from: [ScrollDismissesKeyboardMode.automatic, .immediately, .interactively, .never])
                ) { $0.scrollDismissesKeyboard($1) }
                .padding(.horizontal)
            )
        }
    )
}
