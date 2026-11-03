import SwiftUI

nonisolated extension CatalogEntry {
    static let keyboardType = CatalogEntry(
        id: "keyboardType",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "入力欄を選んだときに出すキーボードの種類を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/keyboardtype(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "keyboardType",
                .choice(
                    [
                        Choice(".default"), Choice(".numberPad"), Choice(".decimalPad"), Choice(".emailAddress"),
                        Choice(".URL"), Choice(".phonePad"),
                    ],
                    initial: 1),
                on: true, summary: "キーボードの種類（入力欄をタップすると出る）")
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"郵便番号\"", "text: $postalCode"],
            suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    TextField("郵便番号", text: text)
                        .apply(
                            v.pick(
                                "keyboardType",
                                from: [
                                    UIKeyboardType.default, .numberPad, .decimalPad, .emailAddress, .URL, .phonePad,
                                ])
                        ) { $0.keyboardType($1) }
                        .textFieldStyle(.bordered)
                }
                .padding()
            )
        }
    )
}
