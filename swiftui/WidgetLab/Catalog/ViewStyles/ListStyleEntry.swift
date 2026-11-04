import SwiftUI

nonisolated extension CatalogEntry {
    static let listStyle = CatalogEntry(
        id: "listStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の List の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/liststyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".plain"), Choice(".grouped"), Choice(".inset"),
                        Choice(".insetGrouped"), Choice(".sidebar"),
                    ],
                    initial: 1),
                on: true, summary: "List の見た目のスタイル")
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    Section(\"果物\") {\n        Text(\"りんご\")\n        Text(\"みかん\")\n    }\n}",
            suffix: [".frame(height: 160)"]),
        build: { v in
            AnyView(
                List {
                    Section("果物") {
                        Text("りんご")
                        Text("みかん")
                    }
                }
                .apply(v.pick("listStyle", from: ListStyleDemo.Style.allCases)) { ListStyleDemo.styled($0, $1) }
                .frame(height: 160)
            )
        }
    )
}

private enum ListStyleDemo {
    enum Style: CaseIterable {
        case automatic, plain, grouped, inset, insetGrouped, sidebar
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.listStyle(.automatic)
        case .plain: view.listStyle(.plain)
        case .grouped: view.listStyle(.grouped)
        case .inset: view.listStyle(.inset)
        case .insetGrouped: view.listStyle(.insetGrouped)
        case .sidebar: view.listStyle(.sidebar)
        }
    }
}
