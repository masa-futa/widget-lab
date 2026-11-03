import SwiftUI

nonisolated extension CatalogEntry {
    static let textCase = CatalogEntry(
        id: "textCase",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の英字を、大文字か小文字にそろえて出す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textcase(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textCase", .choice([Choice(".uppercase"), Choice(".lowercase")], initial: 0), on: true,
                summary: "そろえる文字の形（OFF なら書いたまま）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Hello SwiftUI\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("Hello SwiftUI")
                    .apply(v.pick("textCase", from: [Text.Case.uppercase, .lowercase])) { $0.textCase($1) }
                    .font(.title)
            )
        }
    )
}
