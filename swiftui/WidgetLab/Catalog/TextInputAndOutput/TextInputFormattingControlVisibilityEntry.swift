import SwiftUI

nonisolated extension CatalogEntry {
    static let textInputFormattingControlVisibility = CatalogEntry(
        id: "textInputFormattingControlVisibility",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "書式を付けられる入力欄で、太字などの書式の操作を出すかを、出す場所ごとに決める modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/textinputformattingcontrolvisibility(_:for:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textInputFormattingControlVisibility",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0), on: true,
                summary: "書式の操作を出すか（文字を選ぶと出るメニューで確かめる）"),
            .modifier(
                "textInputFormattingControlVisibility", id: "textInputFormattingControlVisibility.for", label: "for",
                .choice([Choice(".all"), Choice(".contextMenu"), Choice(".inputAssistant")], initial: 0),
                required: true, summary: "出す場所（.contextMenu は選んだときのメニュー、.inputAssistant はキーボードの上）"),
        ],
        code: CodeTemplate(
            prefix: ["// memo は AttributedString（書式を付けられる文字）"], call: "TextEditor",
            fixedArguments: ["text: $memo"], suffix: [".frame(height: 120)"]),
        build: { v in
            let placement = v.pick(
                "textInputFormattingControlVisibility.for",
                from: [TextInputFormattingControlPlacement.Set.all, .contextMenu, .inputAssistant])
            return AnyView(
                TextInputDemo(AttributedString("文字を選ぶと出るメニューに、太字や斜体などの書式の操作が出る。")) { text in
                    TextEditor(text: text)
                        .apply(
                            v.pick(
                                "textInputFormattingControlVisibility", from: [Visibility.hidden, .visible, .automatic])
                        ) { $0.textInputFormattingControlVisibility($1, for: placement ?? .all) }
                        .frame(height: 120)
                }
                .padding()
            )
        }
    )
}
