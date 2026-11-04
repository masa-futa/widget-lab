import SwiftUI

nonisolated extension CatalogEntry {
    static let disclosureGroupStyle = CatalogEntry(
        id: "disclosureGroupStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の DisclosureGroup の見た目と開き方を、まとめて決める modifier。iOS の既製のスタイルは .automatic だけなので、自作のスタイルと比べる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/disclosuregroupstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "disclosureGroupStyle",
                .choice([Choice(".automatic"), Choice("自作", code: "PlusDisclosureGroupStyle()")], initial: 1),
                on: true, summary: "開け閉めの見た目のスタイル。自作のものは DisclosureGroupStyle に準拠させて作る")
        ],
        code: CodeTemplate(
            call: "DisclosureGroup", fixedArguments: ["\"詳細\"", "isExpanded: $isExpanded"],
            trailing: " {\n    Text(\"バージョン 1.0\")\n}",
            closing: [
                "",
                "struct PlusDisclosureGroupStyle: DisclosureGroupStyle {",
                "    func makeBody(configuration: Configuration) -> some View {",
                "        VStack(alignment: .leading) {",
                "            Button {",
                "                withAnimation { configuration.isExpanded.toggle() }",
                "            } label: {",
                "                Label {",
                "                    configuration.label",
                "                } icon: {",
                "                    Image(systemName: configuration.isExpanded ? \"minus.circle\" : \"plus.circle\")",
                "                }",
                "            }",
                "            if configuration.isExpanded {",
                "                configuration.content",
                "                    .padding(.leading, 28)",
                "            }",
                "        }",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(DisclosureGroupStyleDemo(isCustom: v.pick("disclosureGroupStyle", from: [false, true])))
        }
    )
}

private struct DisclosureGroupStyleDemo: View {
    /// nil なら modifier をかけない。false は .automatic、true は自作のスタイル
    let isCustom: Bool?
    @State private var isExpanded = true

    var body: some View {
        DisclosureGroup("詳細", isExpanded: $isExpanded) {
            Text("バージョン 1.0")
        }
        .apply(isCustom) { view, isCustom in
            if isCustom {
                view.disclosureGroupStyle(PlusDisclosureGroupStyle())
            } else {
                view.disclosureGroupStyle(.automatic)
            }
        }
        .frame(width: 240)
    }
}

private struct PlusDisclosureGroupStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            Button {
                withAnimation { configuration.isExpanded.toggle() }
            } label: {
                Label {
                    configuration.label
                } icon: {
                    Image(systemName: configuration.isExpanded ? "minus.circle" : "plus.circle")
                }
            }
            if configuration.isExpanded {
                configuration.content
                    .padding(.leading, 28)
            }
        }
    }
}
