import SwiftUI

nonisolated extension CatalogEntry {
    static let searchable = CatalogEntry(
        id: "searchable",
        kind: .modifier,
        topic: .search,
        summary: "検索の欄を出す modifier。打った文字は text の Binding に入るので、それで一覧を絞る。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/searchable(text:placement:prompt:)")!,
        stage: .full,
        properties: [
            .modifier(
                "searchable", label: "text", .fixed(code: "$query"), on: true,
                summary: "打った文字の Binding。検索の欄に文字を打つと、一覧が絞られる"),
            .modifier(
                "searchable", id: "searchable.placement", label: "placement",
                .choice(
                    [
                        Choice(".automatic"), Choice(".navigationBarDrawer(displayMode: .always)"),
                        Choice(".toolbar"),
                    ], initial: 0), required: true,
                summary: "欄を置く場所。.navigationBarDrawer(displayMode: .always) なら、題名の下にいつも出す"),
            .modifier(
                "searchable", id: "searchable.prompt", label: "prompt", .text(initial: "品物の名前"), required: true,
                summary: "空の欄に薄く出す文"),
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {", "    List(names, id: \\.self) { Text($0) }"], indent: 8,
            call: ".navigationTitle", fixedArguments: ["\"品物\""], closing: ["}"]),
        build: { v in
            AnyView(
                SearchStack { view, query, _ in
                    view.apply(v["searchable"]) { view, _ in
                        view.searchable(
                            text: query,
                            placement: v.pick(
                                "searchable.placement",
                                from: [
                                    SearchFieldPlacement.automatic, .navigationBarDrawer(displayMode: .always),
                                    .toolbar,
                                ]) ?? .automatic,
                            prompt: v.text("searchable.prompt") ?? "")
                    }
                })
        }
    )
}
