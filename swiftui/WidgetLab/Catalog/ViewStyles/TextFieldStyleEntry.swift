import SwiftUI

nonisolated extension CatalogEntry {
    static let textFieldStyle = CatalogEntry(
        id: "textFieldStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の TextField の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textfieldstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textFieldStyle", .choice([Choice(".automatic"), Choice(".plain"), Choice(".bordered")], initial: 2),
                on: true, summary: "TextField の見た目のスタイル")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing: " {\n    TextField(\"名前\", text: $name)\n    TextField(\"メール\", text: $mail)\n}"),
        build: { v in
            AnyView(TextFieldStyleDemo(style: v.pick("textFieldStyle", from: TextFieldStyleDemo.Style.allCases)))
        }
    )
}

private struct TextFieldStyleDemo: View {
    enum Style: CaseIterable {
        case automatic, plain, bordered
    }

    let style: Style?
    @State private var name = ""
    @State private var mail = ""

    var body: some View {
        VStack {
            TextField("名前", text: $name)
            TextField("メール", text: $mail)
        }
        .apply(style) { view, style in
            switch style {
            case .automatic: view.textFieldStyle(.automatic)
            case .plain: view.textFieldStyle(.plain)
            case .bordered: view.textFieldStyle(.bordered)
            }
        }
        .frame(width: 260)
    }
}
