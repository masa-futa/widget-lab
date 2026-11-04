import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbar = CatalogEntry(
        id: "toolbar",
        kind: .modifier,
        topic: .toolbars,
        summary: "ナビゲーションバーや下のバー（ツールバー）に、ボタンなどの項目を置く modifier。置く場所は ToolbarItem の placement で決める。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbar(content:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbar",
                .choice(
                    [
                        Choice(
                            ".topBarTrailing",
                            code:
                                "content: { ToolbarItem(placement: .topBarTrailing) { Button(\"足す\", systemImage: \"plus\") { } } }"
                        ),
                        Choice(
                            ".topBarLeading",
                            code:
                                "content: { ToolbarItem(placement: .topBarLeading) { Button(\"足す\", systemImage: \"plus\") { } } }"
                        ),
                        Choice(
                            ".bottomBar",
                            code:
                                "content: { ToolbarItem(placement: .bottomBar) { Button(\"足す\", systemImage: \"plus\") { } } }"
                        ),
                        Choice(
                            ".principal",
                            code:
                                "content: { ToolbarItem(placement: .principal) { Button(\"足す\", systemImage: \"plus\") { } } }"
                        ),
                    ], initial: 0), on: true,
                summary: "置く項目。ToolbarItem の placement で、右上・左上・下のバー・真ん中（題名の場所）に置く")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {", "    List(1...40, id: \\.self) { Text(\"メモ \\($0)\") }"], indent: 8,
            call: ".navigationTitle", fixedArguments: ["\"メモ\""], closing: ["}"]),
        build: { v in
            AnyView(
                NavigationStack {
                    List(1...40, id: \.self) { Text("メモ \($0)") }
                        .navigationTitle("メモ")
                        .apply(
                            v.pick(
                                "toolbar",
                                from: [
                                    ToolbarItemPlacement.topBarTrailing, .topBarLeading, .bottomBar, .principal,
                                ])
                        ) { view, placement in
                            view.toolbar {
                                ToolbarItem(placement: placement) { Button("足す", systemImage: "plus") {} }
                            }
                        }
                })
        }
    )
}
