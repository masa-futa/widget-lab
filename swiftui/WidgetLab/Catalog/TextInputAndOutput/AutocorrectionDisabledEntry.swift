import SwiftUI

nonisolated extension CatalogEntry {
    static let autocorrectionDisabled = CatalogEntry(
        id: "autocorrectionDisabled",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "入力欄で、打ち間違いの自動修正を止める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/autocorrectiondisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "autocorrectionDisabled", .toggle(initial: true), on: true,
                summary: "自動修正を止めるか（false なら付けないのと同じ）。試すには英語のキーボードで打ち間違える")
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"ユーザー名\"", "text: $userName"],
            suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    TextField("ユーザー名", text: text)
                        .apply(v.flag("autocorrectionDisabled")) { $0.autocorrectionDisabled($1) }
                        .textFieldStyle(.bordered)
                }
                .padding()
            )
        }
    )
}
