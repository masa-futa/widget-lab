import SwiftUI

nonisolated extension CatalogEntry {
    static let submitLabel = CatalogEntry(
        id: "submitLabel",
        kind: .modifier,
        topic: .inputEvents,
        summary: "キーボードの確定のキー（改行キー）に出す文を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/submitlabel(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "submitLabel",
                .choice(
                    [
                        Choice(".done"), Choice(".go"), Choice(".send"), Choice(".join"), Choice(".route"),
                        Choice(".search"), Choice(".return"), Choice(".next"), Choice(".continue"),
                    ], initial: 2), on: true,
                summary: "確定のキーの文（入力欄をタップすると出るキーボードで見る）")
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"メッセージ\"", "text: $message"], suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    TextField("メッセージ", text: text)
                        .apply(
                            v.pick(
                                "submitLabel",
                                from: [SubmitLabel.done, .go, .send, .join, .route, .search, .return, .next, .continue])
                        ) { $0.submitLabel($1) }
                        .textFieldStyle(.bordered)
                }
                .padding()
            )
        }
    )
}
