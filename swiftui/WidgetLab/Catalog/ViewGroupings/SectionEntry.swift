import SwiftUI

nonisolated extension CatalogEntry {
    static let section = CatalogEntry(
        id: "Section",
        kind: .view,
        topic: .viewGroupings,
        summary: "List や Form の中身を、見出しの付いた節に分ける View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/section")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "見出し"), on: true, summary: "節の見出し"),
            .modifier(
                "headerProminence", .choice([Choice(".standard"), Choice(".increased")], initial: 1),
                summary: "見出しの目立たせ方"),
            .modifier(
                "listSectionSpacing", .choice([Choice(".default"), Choice(".compact")], initial: 1),
                summary: "次の節との間の距離"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Section", trailing: " {\n        Text(\"行 1\")\n        Text(\"行 2\")\n    }",
            closing: ["    Section(\"次の節\") {", "        Text(\"行 3\")", "    }", "}"]),
        build: { v in
            AnyView(
                List {
                    SectionDemo.section(title: v.text("title"))
                        .apply(v.pick("headerProminence", from: [Prominence.standard, .increased])) {
                            $0.headerProminence($1)
                        }
                        .apply(v.pick("listSectionSpacing", from: [ListSectionSpacing.default, .compact])) {
                            $0.listSectionSpacing($1)
                        }
                    Section("次の節") {
                        Text("行 3")
                    }
                }
            )
        }
    )
}

private enum SectionDemo {
    @ViewBuilder
    static func section(title: String?) -> some View {
        if let title {
            Section(title) { rows }
        } else {
            Section { rows }
        }
    }

    @ViewBuilder
    private static var rows: some View {
        Text("行 1")
        Text("行 2")
    }
}
