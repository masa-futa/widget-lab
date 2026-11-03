import SwiftUI

nonisolated extension CatalogEntry {
    static let secureField = CatalogEntry(
        id: "SecureField",
        kind: .view,
        topic: .textInputAndOutput,
        summary: "パスワードなどの秘密の文字を、伏せて入力する操作部品。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/securefield")!,
        stage: .card,
        properties: [
            .argument(
                "prompt", .choice([Choice("8 文字以上", code: "Text(\"8 文字以上\")")], initial: 0), on: true,
                summary: "空のときに薄く出す手がかり（OFF ならタイトルを出す）"),
            .modifier(
                "textFieldStyle",
                .choice([Choice(".automatic"), Choice(".bordered"), Choice(".plain")], initial: 1),
                on: true, summary: "入力欄の見た目のスタイル"),
        ],
        code: CodeTemplate(call: "SecureField", fixedArguments: ["\"パスワード\"", "text: $password"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    SecureField("パスワード", text: text, prompt: v.pick("prompt", from: [Text("8 文字以上")]))
                        .apply(v.pick("textFieldStyle", from: SecureFieldDemo.Style.allCases)) {
                            SecureFieldDemo.styled($0, $1)
                        }
                }
                .padding()
            )
        }
    )
}

private enum SecureFieldDemo {
    enum Style: CaseIterable {
        case automatic, bordered, plain
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.textFieldStyle(.automatic)
        case .bordered: view.textFieldStyle(.bordered)
        case .plain: view.textFieldStyle(.plain)
        }
    }
}
