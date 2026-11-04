import SwiftUI

nonisolated extension CatalogEntry {
    static let listRowSeparatorTint = CatalogEntry(
        id: "listRowSeparatorTint",
        kind: .modifier,
        topic: .lists,
        summary: "List の行の区切り線の色を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listrowseparatortint(_:edges:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listRowSeparatorTint", id: "listRowSeparatorTint.color", .color(initial: 0), on: true, summary: "線の色"),
            .modifier(
                "listRowSeparatorTint", id: "listRowSeparatorTint.edges", label: "edges",
                .choice([Choice(".all"), Choice(".top"), Choice(".bottom")], initial: 0), required: true,
                summary: "色を変える線（行の上・下）"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "ForEach", fixedArguments: ["[\"りんご\", \"みかん\", \"ぶどう\"]", "id: \\.self"],
            trailing: " { Text($0) }", closing: ["}"]),
        build: { v in
            let edges = v.pick("listRowSeparatorTint.edges", from: [VerticalEdge.Set.all, .top, .bottom]) ?? .all
            return AnyView(
                List {
                    ForEach(["りんご", "みかん", "ぶどう"], id: \.self) { Text($0) }
                        .apply(v.color("listRowSeparatorTint.color")) { $0.listRowSeparatorTint($1, edges: edges) }
                }
            )
        }
    )
}
