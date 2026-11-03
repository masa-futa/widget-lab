import SwiftUI

nonisolated extension CatalogEntry {
    static let textInputAutocapitalization = CatalogEntry(
        id: "textInputAutocapitalization",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "入力欄で英字を打つとき、どこを自動で大文字にするかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textinputautocapitalization(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textInputAutocapitalization",
                .choice([Choice(".never"), Choice(".words"), Choice(".sentences"), Choice(".characters")], initial: 1),
                on: true, summary: "大文字にする単位（OFF なら .sentences。英語のキーボードで打つと違いが出る）")
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"Full name\"", "text: $fullName"],
            suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    TextField("Full name", text: text)
                        .apply(
                            v.pick(
                                "textInputAutocapitalization",
                                from: [TextInputAutocapitalization.never, .words, .sentences, .characters])
                        ) { $0.textInputAutocapitalization($1) }
                        .textFieldStyle(.bordered)
                }
                .padding()
            )
        }
    )
}
