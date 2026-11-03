import SwiftUI

nonisolated extension CatalogEntry {
    static let font = CatalogEntry(
        id: "font",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字に使うフォントを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/font(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "font",
                .choice(
                    [
                        Choice(".largeTitle"), Choice(".title"), Choice(".body"), Choice(".caption"),
                        Choice(".system(size: 28, weight: .bold, design: .rounded)"),
                        Choice(".custom(\"Georgia\", size: 28)"),
                    ],
                    initial: 1),
                on: true, summary: "フォント（.title などの文字の役割は、文字の大きさの設定に合わせて変わる）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"見本 Sample 123\""]),
        build: { v in
            AnyView(
                Text("見本 Sample 123")
                    .apply(
                        v.pick(
                            "font",
                            from: [
                                Font.largeTitle, .title, .body, .caption,
                                .system(size: 28, weight: .bold, design: .rounded), .custom("Georgia", size: 28),
                            ])
                    ) { $0.font($1) }
            )
        }
    )
}
