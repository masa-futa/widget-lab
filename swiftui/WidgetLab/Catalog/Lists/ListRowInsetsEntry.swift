import SwiftUI

nonisolated extension CatalogEntry {
    static let listRowInsets = CatalogEntry(
        id: "listRowInsets",
        kind: .modifier,
        topic: .lists,
        summary: "List の行の中身のまわりの余白を、辺を選んで決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listrowinsets(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listRowInsets", id: "listRowInsets.edges",
                .choice([Choice(".leading"), Choice(".vertical"), Choice(".all")], initial: 0), required: true,
                summary: "余白を変える辺"),
            .modifier(
                "listRowInsets", id: "listRowInsets.length", .slider(range: 0...60, step: 4, initial: 48), on: true,
                summary: "余白の幅"),
        ],
        code: CodeTemplate(
            prefix: ["List {", "    Text(\"行 1\")", "        .frame(maxWidth: .infinity, alignment: .leading)"],
            indent: 8, call: ".background", fixedArguments: [".yellow"], closing: ["    Text(\"行 2\")", "}"]),
        build: { v in
            let edges = v.pick("listRowInsets.edges", from: [Edge.Set.leading, .vertical, .all]) ?? .all
            return AnyView(
                List {
                    Text("行 1")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.yellow)
                        .apply(v.number("listRowInsets.length")) { $0.listRowInsets(edges, CGFloat($1)) }
                    Text("行 2")
                }
            )
        }
    )
}
