import SwiftUI

nonisolated extension CatalogEntry {
    static let textField = CatalogEntry(
        id: "TextField",
        kind: .view,
        topic: .textInputAndOutput,
        summary: "編集できる文字を出す操作部品。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/textfield")!,
        stage: .card,
        properties: [
            .argument(
                "prompt", .choice([Choice("例: 山田 花子", code: "Text(\"例: 山田 花子\")")], initial: 0), on: true,
                summary: "空のときに薄く出す手がかり（OFF ならタイトルを出す）"),
            .argument(
                "axis", .choice([Choice(".horizontal"), Choice(".vertical")], initial: 1),
                summary: "長い文字を入れたとき、横にずらすか（.horizontal）縦に伸ばすか（.vertical）"),
            .modifier(
                "textFieldStyle",
                .choice([Choice(".automatic"), Choice(".bordered"), Choice(".plain")], initial: 1),
                on: true, summary: "入力欄の見た目のスタイル"),
            .modifier(
                "lineLimit", .choice([Choice("2...4"), Choice("1...2")], initial: 0),
                summary: "縦に伸ばすときの行の数の幅（axis が .vertical のとき効く）"),
        ],
        code: CodeTemplate(call: "TextField", fixedArguments: ["\"名前\"", "text: $name"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    TextFieldDemo.field(
                        text: text, prompt: v.pick("prompt", from: [Text("例: 山田 花子")]),
                        axis: v.pick("axis", from: [Axis.horizontal, .vertical])
                    )
                    .apply(v.pick("textFieldStyle", from: TextFieldDemo.Style.allCases)) {
                        TextFieldDemo.styled($0, $1)
                    }
                    .apply(v.pick("lineLimit", from: [2...4, 1...2])) { $0.lineLimit($1) }
                }
                .padding()
            )
        }
    )
}

private enum TextFieldDemo {
    enum Style: CaseIterable {
        case automatic, bordered, plain
    }

    @ViewBuilder
    static func field(text: Binding<String>, prompt: Text?, axis: Axis?) -> some View {
        if let axis {
            TextField("名前", text: text, prompt: prompt, axis: axis)
        } else {
            TextField("名前", text: text, prompt: prompt)
        }
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
