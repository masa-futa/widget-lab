import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationTitle = CatalogEntry(
        id: "navigationTitle",
        kind: .modifier,
        topic: .navigation,
        summary: "スタックの中の画面の題名を決める modifier。ナビゲーションバーに出て、戻るボタンの文にもなる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/navigationtitle(_:)")!,
        stage: .full,
        properties: [
            .modifier("navigationTitle", .text(initial: "果物"), on: true, summary: "題名の文")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {"], call: "List(fruits, id: \\.self)",
            trailing: " { NavigationLink($0, value: $0) }",
            closing: ["}"]),
        build: { v in
            AnyView(FruitStack { $0.apply(v.text("navigationTitle")) { $0.navigationTitle($1) } })
        }
    )
}
