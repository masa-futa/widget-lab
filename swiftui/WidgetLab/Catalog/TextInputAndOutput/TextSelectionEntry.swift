import SwiftUI

nonisolated extension CatalogEntry {
    static let textSelection = CatalogEntry(
        id: "textSelection",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字を、長押しで選んでコピーできるようにするかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textselection(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textSelection", .choice([Choice(".enabled"), Choice(".disabled")], initial: 0), on: true,
                summary: "文字を選べるか（OFF なら選べない）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"長押しすると、この文字を選んでコピーできる\""]),
        build: { v in
            AnyView(
                Text("長押しすると、この文字を選んでコピーできる")
                    .apply(v.pick("textSelection", from: [true, false])) { view, enabled in
                        if enabled {
                            view.textSelection(.enabled)
                        } else {
                            view.textSelection(.disabled)
                        }
                    }
                    .padding()
            )
        }
    )
}
