import SwiftUI

nonisolated extension CatalogEntry {
    static let searchPresentationToolbarBehavior = CatalogEntry(
        id: "searchPresentationToolbarBehavior",
        kind: .modifier,
        topic: .search,
        summary: "検索の欄を押して検索を始めたとき、ツールバー（題名など）を隠すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/searchpresentationtoolbarbehavior(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "searchPresentationToolbarBehavior",
                .choice([Choice(".automatic"), Choice(".avoidHidingContent")], initial: 1), on: true,
                summary: "隠すか。.avoidHidingContent なら、検索を始めても題名が残る。検索の欄を押して見る")
        ],
        code: .inSearchStack(),
        build: { v in
            AnyView(
                SearchStack { view, query, _ in
                    view.searchable(text: query)
                        .apply(
                            v.pick(
                                "searchPresentationToolbarBehavior",
                                from: [SearchPresentationToolbarBehavior.automatic, .avoidHidingContent])
                        ) { $0.searchPresentationToolbarBehavior($1) }
                })
        }
    )
}
