import SwiftUI

nonisolated extension CatalogEntry {
    static let menuOrder = CatalogEntry(
        id: "menuOrder",
        kind: .modifier,
        topic: .menusAndCommands,
        summary: "メニューの項目を並べる順を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/menuorder(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "menuOrder", .choice([Choice(".automatic"), Choice(".priority"), Choice(".fixed")], initial: 2),
                on: true, summary: "並べる順。.priority は先頭の項目を押した場所の近くに、.fixed は書いた順のまま上から並べる")
        ],
        code: CodeTemplate(
            call: "Menu", fixedArguments: ["\"並び\""],
            trailing: " {\n    Button(\"1 番目\") { }\n    Button(\"2 番目\") { }\n    Button(\"3 番目\") { }\n}"),
        build: { v in
            AnyView(
                Menu("並び") {
                    Button("1 番目") {}
                    Button("2 番目") {}
                    Button("3 番目") {}
                }
                .buttonStyle(.bordered)
                .apply(v.pick("menuOrder", from: [MenuOrder.automatic, .priority, .fixed])) { $0.menuOrder($1) }
            )
        }
    )
}
