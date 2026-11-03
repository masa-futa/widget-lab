import SwiftUI

nonisolated extension CatalogEntry {
    static let fontWeight = CatalogEntry(
        id: "fontWeight",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字の太さを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/fontweight(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "fontWeight",
                .choice(
                    [
                        Choice(".ultraLight"), Choice(".light"), Choice(".regular"), Choice(".semibold"),
                        Choice(".bold"),
                        Choice(".black"),
                    ],
                    initial: 4),
                on: true, summary: "文字の太さ")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"見本 Sample 123\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("見本 Sample 123")
                    .apply(
                        v.pick(
                            "fontWeight", from: [Font.Weight.ultraLight, .light, .regular, .semibold, .bold, .black])
                    ) { $0.fontWeight($1) }
                    .font(.title)
            )
        }
    )
}
