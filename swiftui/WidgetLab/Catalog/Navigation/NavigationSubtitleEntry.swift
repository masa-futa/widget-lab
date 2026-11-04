import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationSubtitle = CatalogEntry(
        id: "navigationSubtitle",
        kind: .modifier,
        topic: .navigation,
        summary: "スタックの中の画面の、題名に添える小さな副題を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/navigationsubtitle(_:)")!,
        stage: .full,
        properties: [
            .modifier("navigationSubtitle", .text(initial: "3 件"), on: true, summary: "副題の文。題名の下に出る")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {"], call: "List(fruits, id: \\.self)",
            trailing: " { NavigationLink($0, value: $0) }",
            suffix: [".navigationTitle(\"果物\")"], closing: ["}"]),
        build: { v in
            AnyView(
                FruitStack {
                    $0.navigationTitle("果物")
                        .apply(v.text("navigationSubtitle")) { $0.navigationSubtitle($1) }
                })
        }
    )
}
