import SwiftUI

nonisolated extension CatalogEntry {
    static let fontWidth = CatalogEntry(
        id: "fontWidth",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字の幅（詰めた形・広げた形）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/fontwidth(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "fontWidth",
                .choice(
                    [Choice(".compressed"), Choice(".condensed"), Choice(".standard"), Choice(".expanded")], initial: 3),
                on: true, summary: "文字の幅（幅の違う形を持つフォントで効く。日本語の文字は変わらない）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Widget Lab 123\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("Widget Lab 123")
                    .apply(v.pick("fontWidth", from: [Font.Width.compressed, .condensed, .standard, .expanded])) {
                        $0.fontWidth($1)
                    }
                    .font(.title)
            )
        }
    )
}
