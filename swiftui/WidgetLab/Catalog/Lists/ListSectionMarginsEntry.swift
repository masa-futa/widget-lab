import SwiftUI

nonisolated extension CatalogEntry {
    static let listSectionMargins = CatalogEntry(
        id: "listSectionMargins",
        kind: .modifier,
        topic: .lists,
        summary: "List の節のまわりの余白を、辺を選んで決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listsectionmargins(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listSectionMargins", id: "listSectionMargins.edges",
                .choice([Choice(".horizontal"), Choice(".top"), Choice(".all")], initial: 0), required: true,
                summary: "余白を変える辺"),
            .modifier(
                "listSectionMargins", id: "listSectionMargins.length", .slider(range: 0...60, step: 4, initial: 48),
                on: true, summary: "余白の幅"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Section", fixedArguments: ["\"果物\""],
            trailing: " {\n        Text(\"りんご\")\n        Text(\"みかん\")\n    }",
            closing: ["    Section(\"野菜\") { Text(\"にんじん\") }", "}"]),
        build: { v in
            let edges = v.pick("listSectionMargins.edges", from: [Edge.Set.horizontal, .top, .all]) ?? .all
            return AnyView(
                List {
                    Section("果物") {
                        Text("りんご")
                        Text("みかん")
                    }
                    .apply(v.number("listSectionMargins.length")) { $0.listSectionMargins(edges, CGFloat($1)) }
                    Section("野菜") { Text("にんじん") }
                }
            )
        }
    )
}
