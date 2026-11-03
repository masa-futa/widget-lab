import SwiftUI

nonisolated extension CatalogEntry {
    static let typesettingLanguage = CatalogEntry(
        id: "typesettingLanguage",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字を組むときの言語を決める modifier。行の高さ・改行・字の間が、その言語の文字に合わせて変わる。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/typesettinglanguage(_:isenabled:)")!,
        stage: .card,
        properties: [
            .modifier(
                "typesettingLanguage",
                .choice(
                    [
                        Choice("タイ語", code: "Locale.Language(identifier: \"th\")"),
                        Choice("日本語", code: "Locale.Language(identifier: \"ja\")"),
                        Choice("英語", code: "Locale.Language(identifier: \"en\")"),
                    ],
                    initial: 0),
                on: true, summary: "組む言語（OFF なら端末の言語。タイ語のように上下に飾りのある文字は、行を高くとる）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"สวัสดีครับ\\nภาษาไทย\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("สวัสดีครับ\nภาษาไทย")
                    .apply(v.pick("typesettingLanguage", from: ["th", "ja", "en"])) {
                        $0.typesettingLanguage(Locale.Language(identifier: $1))
                    }
                    .font(.title)
                    .border(.secondary)
            )
        }
    )
}
