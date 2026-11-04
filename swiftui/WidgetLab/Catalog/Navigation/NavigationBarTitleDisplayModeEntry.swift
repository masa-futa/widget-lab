import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationBarTitleDisplayMode = CatalogEntry(
        id: "navigationBarTitleDisplayMode",
        kind: .modifier,
        topic: .navigation,
        summary: "スタックの中の画面の題名を、大きく出すか、バーの中に小さく出すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/navigationbartitledisplaymode(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "navigationBarTitleDisplayMode",
                .choice([Choice(".automatic"), Choice(".inline"), Choice(".large")], initial: 1),
                on: true, summary: "題名の出し方。.large は大きく、.inline はバーの真ん中に小さく出す")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {"], call: "List(fruits, id: \\.self)",
            trailing: " { NavigationLink($0, value: $0) }",
            suffix: [".navigationTitle(\"果物\")", ".navigationDestination(for: String.self) { Text($0) }"],
            closing: ["}"]),
        build: { v in
            AnyView(
                FruitStack {
                    $0.navigationTitle("果物")
                        .apply(
                            v.pick(
                                "navigationBarTitleDisplayMode",
                                from: [NavigationBarItem.TitleDisplayMode.automatic, .inline, .large])
                        ) { $0.navigationBarTitleDisplayMode($1) }
                })
        }
    )
}
