import SwiftUI

nonisolated extension CatalogEntry {
    static let group = CatalogEntry(
        id: "Group",
        kind: .view,
        topic: .viewGroupings,
        summary: "子の View をまとめる View。かけた modifier は、子の 1 つずつにかかる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/group")!,
        stage: .card,
        properties: [
            .modifier(
                "font", .choice([Choice(".largeTitle"), Choice(".title"), Choice(".caption")], initial: 1), on: true,
                summary: "子の文字の大きさ"),
            .modifier("foregroundStyle", .color(initial: 4), summary: "子の文字の色"),
            .modifier("border", .color(initial: 0), on: true, summary: "枠線（子の 1 つずつに付く）"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "Group", trailing: " {\n        Text(\"A\")\n        Text(\"BBBB\")\n    }",
            closing: ["    Text(\"Group の外\")", "}"]),
        build: { v in
            AnyView(
                VStack {
                    Group {
                        Text("A")
                        Text("BBBB")
                    }
                    .apply(v.pick("font", from: [Font.largeTitle, .title, .caption])) { $0.font($1) }
                    .apply(v.color("foregroundStyle")) { $0.foregroundStyle($1) }
                    .apply(v.color("border")) { $0.border($1) }
                    Text("Group の外")
                }
            )
        }
    )
}
