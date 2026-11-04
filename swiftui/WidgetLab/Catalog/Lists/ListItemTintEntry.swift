import SwiftUI

nonisolated extension CatalogEntry {
    static let listItemTint = CatalogEntry(
        id: "listItemTint",
        kind: .modifier,
        topic: .lists,
        summary: "List の中身に決まった色を付ける modifier。iOS ではサイドバーの Label のアイコンに効く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listitemtint(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listItemTint",
                .choice([Choice(".fixed(.orange)"), Choice(".preferred(.orange)"), Choice(".monochrome")], initial: 0),
                on: true, summary: "色の付け方（.preferred は、ほかに指定がなければこの色）")
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "ForEach",
            fixedArguments: ["[\"受信\", \"送信済み\"]", "id: \\.self"],
            trailing: " { name in\n        Label(name, systemImage: \"tray\")\n    }",
            closing: ["}", ".listStyle(.sidebar)"]),
        build: { v in
            AnyView(
                List {
                    ForEach(["受信", "送信済み"], id: \.self) { name in
                        Label(name, systemImage: "tray")
                    }
                    .apply(
                        v.pick("listItemTint", from: [ListItemTint.fixed(.orange), .preferred(.orange), .monochrome])
                    ) { $0.listItemTint($1) }
                }
                .listStyle(.sidebar)
            )
        }
    )
}
