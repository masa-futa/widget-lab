import SwiftUI

nonisolated extension CatalogEntry {
    static let textContentType = CatalogEntry(
        id: "textContentType",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "入力欄に入れる中身の種類を伝え、キーボードの上に自動入力の候補を出せるようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textcontenttype(_:)-ufdv")!,
        stage: .card,
        properties: [
            .modifier(
                "textContentType",
                .choice(
                    [
                        Choice(".emailAddress"), Choice(".name"), Choice(".telephoneNumber"), Choice(".oneTimeCode"),
                        Choice(".password"),
                    ],
                    initial: 0),
                on: true, summary: "中身の種類（入力欄をタップすると、連絡先などからの候補が出る）")
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"連絡先\"", "text: $contact"],
            suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    TextField("連絡先", text: text)
                        .apply(
                            v.pick(
                                "textContentType",
                                from: [
                                    UITextContentType.emailAddress, .name, .telephoneNumber, .oneTimeCode, .password,
                                ])
                        ) { $0.textContentType($1) }
                        .textFieldStyle(.bordered)
                }
                .padding()
            )
        }
    )
}
