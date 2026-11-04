import SwiftUI

nonisolated extension CatalogEntry {
    static let listSectionSeparatorTint = CatalogEntry(
        id: "listSectionSeparatorTint",
        kind: .modifier,
        topic: .lists,
        summary: "List の節（Section）の上下の区切り線の色を決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/listsectionseparatortint(_:edges:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listSectionSeparatorTint", id: "listSectionSeparatorTint.color", .color(initial: 0), on: true,
                summary: "線の色"),
            .modifier(
                "listSectionSeparatorTint", id: "listSectionSeparatorTint.edges", label: "edges",
                .choice([Choice(".all"), Choice(".top"), Choice(".bottom")], initial: 0), required: true,
                summary: "色を変える線（節の上・下）"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Section", fixedArguments: ["\"果物\""],
            trailing: " {\n        Text(\"りんご\")\n        Text(\"みかん\")\n    }",
            closing: ["    Section(\"野菜\") { Text(\"にんじん\") }", "}", ".listStyle(.plain)"]),
        build: { v in
            let edges = v.pick("listSectionSeparatorTint.edges", from: [VerticalEdge.Set.all, .top, .bottom]) ?? .all
            return AnyView(
                List {
                    Section("果物") {
                        Text("りんご")
                        Text("みかん")
                    }
                    .apply(v.color("listSectionSeparatorTint.color")) { $0.listSectionSeparatorTint($1, edges: edges) }
                    Section("野菜") { Text("にんじん") }
                }
                .listStyle(.plain)
            )
        }
    )
}
