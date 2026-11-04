import SwiftUI

nonisolated extension CatalogEntry {
    static let labeledContentStyle = CatalogEntry(
        id: "labeledContentStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の LabeledContent の、名前と値の並べ方を決める modifier。iOS の既製のスタイルは .automatic だけなので、自作のスタイルと比べる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/labeledcontentstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "labeledContentStyle",
                .choice([Choice(".automatic"), Choice("自作", code: "StackedLabeledContentStyle()")], initial: 1),
                on: true, summary: "名前と値の並べ方のスタイル。自作のものは LabeledContentStyle に準拠させて作る")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing: " {\n    LabeledContent(\"バージョン\", value: \"1.0\")\n"
                + "    LabeledContent(\"作った人\", value: \"Widget Lab\")\n}",
            closing: [
                "",
                "struct StackedLabeledContentStyle: LabeledContentStyle {",
                "    func makeBody(configuration: Configuration) -> some View {",
                "        VStack(alignment: .leading) {",
                "            configuration.label",
                "                .font(.caption)",
                "                .foregroundStyle(.secondary)",
                "            configuration.content",
                "        }",
                "        .frame(maxWidth: .infinity, alignment: .leading)",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(
                VStack {
                    LabeledContent("バージョン", value: "1.0")
                    LabeledContent("作った人", value: "Widget Lab")
                }
                .apply(v.pick("labeledContentStyle", from: [false, true])) { view, isCustom in
                    if isCustom {
                        view.labeledContentStyle(StackedLabeledContentStyle())
                    } else {
                        view.labeledContentStyle(.automatic)
                    }
                }
                .frame(width: 240)
            )
        }
    )
}

private struct StackedLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(.caption)
                .foregroundStyle(.secondary)
            configuration.content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
