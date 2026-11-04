import SwiftUI

nonisolated extension CatalogEntry {
    static let findNavigator = CatalogEntry(
        id: "findNavigator",
        kind: .modifier,
        topic: .search,
        summary: "TextEditor の中を探す・置き換える帯を、コードから出したり閉じたりする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/findnavigator(ispresented:)")!,
        stage: .card,
        properties: [
            .modifier(
                "findNavigator", label: "isPresented", .fixed(code: "$shows"), on: true,
                summary: "帯を出すかの Binding。true にすると、キーボードの上に帯が出る。文を押して入力の印を入れてから、ボタンを押す")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"検索の帯を出す\") { shows.toggle() }"], indent: 0, call: "TextEditor",
            fixedArguments: ["text: $memo"]),
        build: { v in
            AnyView(FindDemo(navigator: v["findNavigator"] != nil) { $0 })
        }
    )
}
