import SwiftUI

nonisolated extension CatalogEntry {
    static let form = CatalogEntry(
        id: "Form",
        kind: .view,
        topic: .viewGroupings,
        summary: "設定やデータの入力に使う操作部品を、まとめて並べる入れ物。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/form")!,
        stage: .card,
        properties: [
            .modifier(
                "formStyle", .choice([Choice(".automatic"), Choice(".grouped"), Choice(".columns")], initial: 2),
                on: true, summary: "並べ方のスタイル"),
            .modifier(
                "scrollContentBackground", .choice([Choice(".hidden"), Choice(".visible")], initial: 0),
                summary: "Form の背景を出すか"),
            .modifier("disabled", .toggle(initial: true), summary: "中の操作部品を全部押せなくする"),
        ],
        code: CodeTemplate(
            call: "Form",
            trailing: " {\n    Toggle(\"通知\", isOn: .constant(true))\n"
                + "    LabeledContent(\"バージョン\", value: \"1.0\")\n}"),
        build: { v in
            AnyView(
                Form {
                    Toggle("通知", isOn: .constant(true))
                    LabeledContent("バージョン", value: "1.0")
                }
                .apply(v.pick("formStyle", from: FormDemo.Style.allCases)) { FormDemo.styled($0, $1) }
                .apply(v.pick("scrollContentBackground", from: [Visibility.hidden, .visible])) {
                    $0.scrollContentBackground($1)
                }
                .apply(v.flag("disabled")) { $0.disabled($1) }
            )
        }
    )
}

private enum FormDemo {
    enum Style: CaseIterable {
        case automatic, grouped, columns
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.formStyle(.automatic)
        case .grouped: view.formStyle(.grouped)
        case .columns: view.formStyle(.columns)
        }
    }
}
