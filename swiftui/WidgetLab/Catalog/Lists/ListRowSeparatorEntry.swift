import SwiftUI

nonisolated extension CatalogEntry {
    static let listRowSeparator = CatalogEntry(
        id: "listRowSeparator",
        kind: .modifier,
        topic: .lists,
        summary: "List の行の区切り線を出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listrowseparator(_:edges:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listRowSeparator", id: "listRowSeparator.visibility",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0), on: true,
                summary: "線を出すか"),
            .modifier(
                "listRowSeparator", id: "listRowSeparator.edges", label: "edges",
                .choice([Choice(".all"), Choice(".top"), Choice(".bottom")], initial: 0), required: true,
                summary: "変える線（行の上・下）"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "ForEach", fixedArguments: ["[\"りんご\", \"みかん\", \"ぶどう\"]", "id: \\.self"],
            trailing: " { Text($0) }", closing: ["}"]),
        build: { v in
            let edges = v.pick("listRowSeparator.edges", from: [VerticalEdge.Set.all, .top, .bottom]) ?? .all
            return AnyView(
                List {
                    ForEach(["りんご", "みかん", "ぶどう"], id: \.self) { Text($0) }
                        .apply(
                            v.pick("listRowSeparator.visibility", from: [Visibility.hidden, .visible, .automatic])
                        ) { $0.listRowSeparator($1, edges: edges) }
                }
            )
        }
    )
}
