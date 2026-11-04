import SwiftUI

nonisolated extension CatalogEntry {
    static let groupBoxStyle = CatalogEntry(
        id: "groupBoxStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の GroupBox の見た目を、まとめて決める modifier。iOS の既製のスタイルは .automatic だけなので、自作のスタイルと比べる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/groupboxstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "groupBoxStyle",
                .choice([Choice(".automatic"), Choice("自作", code: "TintedGroupBoxStyle()")], initial: 1), on: true,
                summary: "箱の見た目のスタイル。自作のものは GroupBoxStyle に準拠させて作る")
        ],
        code: CodeTemplate(
            call: "GroupBox", fixedArguments: ["\"設定\""], trailing: " {\n    Text(\"通知を受け取る\")\n}",
            closing: [
                "",
                "struct TintedGroupBoxStyle: GroupBoxStyle {",
                "    func makeBody(configuration: Configuration) -> some View {",
                "        VStack(alignment: .leading, spacing: 8) {",
                "            configuration.label",
                "                .font(.headline)",
                "            configuration.content",
                "        }",
                "        .padding()",
                "        .background(.yellow.opacity(0.3), in: .rect(cornerRadius: 12))",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(
                GroupBox("設定") {
                    Text("通知を受け取る")
                }
                .apply(v.pick("groupBoxStyle", from: [false, true])) { view, isCustom in
                    if isCustom {
                        view.groupBoxStyle(TintedGroupBoxStyle())
                    } else {
                        view.groupBoxStyle(.automatic)
                    }
                }
                .padding()
            )
        }
    )
}

private struct TintedGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            configuration.label
                .font(.headline)
            configuration.content
        }
        .padding()
        .background(.yellow.opacity(0.3), in: .rect(cornerRadius: 12))
    }
}
