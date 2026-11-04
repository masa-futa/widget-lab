import SwiftUI

nonisolated extension CatalogEntry {
    static let searchCompletion = CatalogEntry(
        id: "searchCompletion",
        kind: .modifier,
        topic: .search,
        summary: "検索の候補の行に、押したときに検索の欄へ入れる文字を結び付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/searchcompletion(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "searchCompletion", .fixed(code: "name"), on: true,
                summary: "候補を押したときに入れる文字。付けないと、候補を押しても何も起きない")
        ],
        code: CodeTemplate(
            prefix: [
                "NavigationStack {", "    List(names, id: \\.self) { Text($0) }",
                "        .navigationTitle(\"品物\")", "        .searchable(text: $query)",
                "        .searchSuggestions {",
                "            ForEach([\"りんご\", \"トマト\"], id: \\.self) { name in",
            ], indent: 16, call: "Label", fixedArguments: ["name", "systemImage: \"magnifyingglass\""],
            closing: ["            }", "        }", "}"]),
        build: { v in
            AnyView(
                SearchStack { view, query, _ in
                    view.searchable(text: query)
                        .searchSuggestions { SearchSuggestionRows(completes: v["searchCompletion"] != nil) }
                })
        }
    )
}
