import SwiftUI

nonisolated extension CatalogEntry {
    static let textEditor = CatalogEntry(
        id: "TextEditor",
        kind: .view,
        topic: .textInputAndOutput,
        summary: "長い文字を、複数行で表示して編集できる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/texteditor")!,
        stage: .card,
        properties: [
            .modifier(
                "font", .choice([Choice(".body"), Choice(".title3"), Choice(".caption")], initial: 1), on: true,
                summary: "文字の大きさ"),
            .modifier("foregroundStyle", .color(initial: 4), summary: "文字の色"),
            .modifier(
                "scrollContentBackground", .choice([Choice(".hidden"), Choice(".visible")], initial: 0),
                summary: "入力欄の地を出すか（.hidden なら後ろの色が透ける）"),
        ],
        code: CodeTemplate(call: "TextEditor", fixedArguments: ["text: $memo"], suffix: [".frame(height: 120)"]),
        build: { v in
            AnyView(
                TextInputDemo("買うもの\n・牛乳\n・パン\n行を足して編集できる") { text in
                    TextEditor(text: text)
                        .apply(v.pick("font", from: [Font.body, .title3, .caption])) { $0.font($1) }
                        .apply(v.color("foregroundStyle")) { $0.foregroundStyle($1) }
                        .apply(v.pick("scrollContentBackground", from: [Visibility.hidden, .visible])) {
                            $0.scrollContentBackground($1)
                        }
                        .frame(height: 120)
                }
                .padding()
            )
        }
    )
}
