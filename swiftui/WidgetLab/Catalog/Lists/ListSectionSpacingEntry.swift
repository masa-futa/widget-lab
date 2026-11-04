import SwiftUI

nonisolated extension CatalogEntry {
    static let listSectionSpacing = CatalogEntry(
        id: "listSectionSpacing",
        kind: .modifier,
        topic: .lists,
        summary: "List の隣り合う節（Section）の間を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listsectionspacing(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listSectionSpacing",
                .choice([Choice(".compact"), Choice(".default"), Choice(".custom(60)")], initial: 0), on: true,
                summary: "節の間")
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    Section(\"果物\") { Text(\"りんご\") }\n    Section(\"野菜\") { Text(\"にんじん\") }\n"
                + "    Section(\"魚\") { Text(\"さば\") }\n}"),
        build: { v in
            AnyView(
                List {
                    Section("果物") { Text("りんご") }
                    Section("野菜") { Text("にんじん") }
                    Section("魚") { Text("さば") }
                }
                .apply(
                    v.pick("listSectionSpacing", from: [ListSectionSpacing.compact, .default, .custom(60)])
                ) { $0.listSectionSpacing($1) }
            )
        }
    )
}
