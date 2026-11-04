import SwiftUI

nonisolated extension CatalogEntry {
    static let searchFocused = CatalogEntry(
        id: "searchFocused",
        kind: .modifier,
        topic: .focus,
        summary: "いちばん近い .searchable の検索欄のフォーカスを、@FocusState の値とつなぐ modifier。コードから検索欄を選べる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/searchfocused(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "searchFocused", .fixed(code: "$isSearching"), on: true,
                summary: "つなぐ @FocusState の Bool。外すと、「検索する」を押しても検索欄が選ばれない")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {", "    List(fruits, id: \\.self) { Text($0) }"], indent: 8, call: ".searchable",
            fixedArguments: ["text: $query"],
            suffix: [".toolbar { Button(\"検索する\") { isSearching = true } }", ".navigationTitle(\"果物\")"],
            closing: ["}"]),
        build: { v in
            AnyView(SearchFocusedDemo(binds: v["searchFocused"] != nil))
        }
    )
}

private struct SearchFocusedDemo: View {
    let binds: Bool
    @State private var query = ""
    @FocusState private var isSearching: Bool

    private let fruits = ["りんご", "ぶどう", "もも", "みかん", "なし"]

    var body: some View {
        NavigationStack {
            List(fruits.filter { query.isEmpty || $0.contains(query) }, id: \.self) { Text($0) }
                .searchable(text: $query)
                .apply(binds ? () : nil) { view, _ in view.searchFocused($isSearching) }
                .toolbar { Button("検索する") { isSearching = true } }
                .navigationTitle("果物")
        }
    }
}
