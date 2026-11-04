import SwiftUI

nonisolated extension CatalogEntry {
    static let searchScopes = CatalogEntry(
        id: "searchScopes",
        kind: .modifier,
        topic: .search,
        summary: "検索の欄の下に、絞り込む範囲の切り替え（すべて・果物・野菜など）を出す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/searchscopes(_:activation:_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "searchScopes", id: "searchScopes.scope", .fixed(code: "$scope"), required: true,
                summary: "選んだ範囲の Binding。範囲は tag の値で見分ける"),
            .modifier(
                "searchScopes", id: "searchScopes.activation", label: "activation",
                .choice([Choice(".automatic"), Choice(".onSearchPresentation"), Choice(".onTextEntry")], initial: 1),
                required: true, summary: "切り替えを出すきっかけ。.onSearchPresentation なら、検索の欄を押したときに出す"),
            .modifier(
                "searchScopes",
                .fixed(code: "{ Text(\"すべて\").tag(0); Text(\"果物\").tag(1); Text(\"野菜\").tag(2) }"), on: true,
                summary: "範囲の切り替え。検索の欄を押すと、欄の下に出る"),
        ],
        code: .inSearchStack(placement: ".navigationBarDrawer(displayMode: .always)"),
        build: { v in
            AnyView(
                SearchStack { view, query, scope in
                    view.searchable(text: query, placement: .navigationBarDrawer(displayMode: .always))
                        .apply(v["searchScopes"]) { view, _ in
                            view.searchScopes(
                                scope,
                                activation: v.pick(
                                    "searchScopes.activation",
                                    from: [SearchScopeActivation.automatic, .onSearchPresentation, .onTextEntry])
                                    ?? .automatic
                            ) {
                                Text("すべて").tag(0)
                                Text("果物").tag(1)
                                Text("野菜").tag(2)
                            }
                        }
                })
        }
    )
}
