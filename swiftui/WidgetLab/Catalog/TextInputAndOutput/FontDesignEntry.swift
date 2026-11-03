import SwiftUI

nonisolated extension CatalogEntry {
    static let fontDesign = CatalogEntry(
        id: "fontDesign",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字のフォントの系統（明朝のような serif・丸ゴシックのような rounded など）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/fontdesign(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "fontDesign",
                .choice([Choice(".default"), Choice(".serif"), Choice(".rounded"), Choice(".monospaced")], initial: 1),
                on: true, summary: "フォントの系統")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"見本 Sample 123\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("見本 Sample 123")
                    .apply(v.pick("fontDesign", from: [Font.Design.default, .serif, .rounded, .monospaced])) {
                        $0.fontDesign($1)
                    }
                    .font(.title)
            )
        }
    )
}
