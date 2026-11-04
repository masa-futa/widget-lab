import SwiftUI

nonisolated extension CatalogEntry {
    static let formStyle = CatalogEntry(
        id: "formStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Form の並べ方を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/formstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "formStyle", .choice([Choice(".automatic"), Choice(".grouped"), Choice(".columns")], initial: 2),
                on: true, summary: "Form の並べ方のスタイル。.columns は名前と値を列にそろえる")
        ],
        code: CodeTemplate(
            call: "Form",
            trailing: " {\n    Toggle(\"通知\", isOn: $notifies)\n"
                + "    LabeledContent(\"バージョン\", value: \"1.0\")\n}",
            suffix: [".frame(height: 200)"]),
        build: { v in
            AnyView(FormStyleDemo(style: v.pick("formStyle", from: FormStyleDemo.Style.allCases)))
        }
    )
}

private struct FormStyleDemo: View {
    enum Style: CaseIterable {
        case automatic, grouped, columns
    }

    let style: Style?
    @State private var notifies = true

    var body: some View {
        Form {
            Toggle("通知", isOn: $notifies)
            LabeledContent("バージョン", value: "1.0")
        }
        .apply(style) { view, style in
            switch style {
            case .automatic: view.formStyle(.automatic)
            case .grouped: view.formStyle(.grouped)
            case .columns: view.formStyle(.columns)
            }
        }
        .frame(height: 200)
    }
}
