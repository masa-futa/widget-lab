import SwiftUI

nonisolated extension CatalogEntry {
    static let table = CatalogEntry(
        id: "Table",
        kind: .view,
        topic: .tables,
        summary: "データの行を、列に分けて並べる入れ物。iPhone（幅が compact）では、最初の列だけを 1 列の一覧として出す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/table")!,
        stage: .card,
        properties: [
            .argument("selection", .fixed(code: "$selected"), on: true, summary: "選んだ行の id を入れる値（タップで行を選ぶ）"),
            .modifier("tint", .color(initial: 3), summary: "選んだ行の色"),
        ],
        code: CodeTemplate(
            call: "Table", fixedArguments: ["fruits"],
            trailing: " {\n    TableColumn(\"名前\", value: \\.name)\n    TableColumn(\"産地\", value: \\.origin)\n"
                + "    TableColumn(\"値段\") { Text(\"\\($0.price) 円\") }\n}"),
        build: { v in
            AnyView(TableDemo(selects: v["selection"] != nil, tint: v.color("tint")))
        }
    )
}

private struct TableDemo: View {
    nonisolated struct Fruit: Identifiable, Sendable {
        let name: String
        let origin: String
        let price: Int
        var id: String { name }
    }

    static let fruits = [
        Fruit(name: "りんご", origin: "青森", price: 150),
        Fruit(name: "みかん", origin: "愛媛", price: 80),
        Fruit(name: "ぶどう", origin: "山梨", price: 400),
    ]

    let selects: Bool
    let tint: Color?
    @State private var selected: Fruit.ID? = "みかん"

    var body: some View {
        table
            .apply(tint) { $0.tint($1) }
    }

    @ViewBuilder
    private var table: some View {
        if selects {
            Table(Self.fruits, selection: $selected) { columns }
        } else {
            Table(Self.fruits) { columns }
        }
    }

    @TableColumnBuilder<Fruit, Never>
    private var columns: some TableColumnContent<Fruit, Never> {
        TableColumn("名前", value: \.name)
        TableColumn("産地", value: \.origin)
        TableColumn("値段") { Text("\($0.price) 円") }
    }
}
