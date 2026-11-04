import SwiftUI

nonisolated extension CatalogEntry {
    static let searchSuggestions = CatalogEntry(
        id: "searchSuggestions",
        kind: .modifier,
        topic: .search,
        summary: "検索の欄を押したときに出す候補を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/searchsuggestions(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "searchSuggestions",
                .fixed(
                    code:
                        "{ ForEach([\"りんご\", \"トマト\"], id: \\.self) { Label($0, systemImage: \"magnifyingglass\").searchCompletion($0) } }"
                ), on: true, summary: "候補の行。検索の欄を押すと、一覧の代わりに出る")
        ],
        code: .inSearchStack(),
        build: { v in
            AnyView(
                SearchStack { view, query, _ in
                    view.searchable(text: query)
                        .apply(v["searchSuggestions"]) { view, _ in
                            view.searchSuggestions { SearchSuggestionRows() }
                        }
                })
        }
    )
}
