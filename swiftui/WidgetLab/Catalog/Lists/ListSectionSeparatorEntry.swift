import SwiftUI

nonisolated extension CatalogEntry {
    static let listSectionSeparator = CatalogEntry(
        id: "listSectionSeparator",
        kind: .modifier,
        topic: .lists,
        summary: "List の節（Section）の上下の区切り線を出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listsectionseparator(_:edges:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listSectionSeparator", id: "listSectionSeparator.visibility",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0), on: true,
                summary: "線を出すか"),
            .modifier(
                "listSectionSeparator", id: "listSectionSeparator.edges", label: "edges",
                .choice([Choice(".all"), Choice(".top"), Choice(".bottom")], initial: 0), required: true,
                summary: "変える線（節の上・下）"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Section", fixedArguments: ["\"果物\""],
            trailing: " {\n        Text(\"りんご\")\n        Text(\"みかん\")\n    }",
            closing: ["    Section(\"野菜\") { Text(\"にんじん\") }", "}", ".listStyle(.plain)"]),
        build: { v in
            let edges = v.pick("listSectionSeparator.edges", from: [VerticalEdge.Set.all, .top, .bottom]) ?? .all
            return AnyView(
                List {
                    Section("果物") {
                        Text("りんご")
                        Text("みかん")
                    }
                    .apply(v.pick("listSectionSeparator.visibility", from: [Visibility.hidden, .visible, .automatic])) {
                        $0.listSectionSeparator($1, edges: edges)
                    }
                    Section("野菜") { Text("にんじん") }
                }
                .listStyle(.plain)
            )
        }
    )
}
