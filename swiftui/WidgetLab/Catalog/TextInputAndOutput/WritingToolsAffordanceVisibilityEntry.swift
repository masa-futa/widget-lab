import SwiftUI

nonisolated extension CatalogEntry {
    static let writingToolsAffordanceVisibility = CatalogEntry(
        id: "writingToolsAffordanceVisibility",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "入力欄に、作文ツール（Writing Tools）を開くボタンを出すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/writingtoolsaffordancevisibility(_:)")!,
        noteReason: "Mac（Mac Catalyst を含む）の入力欄で効く。iPhone では作文ツールのボタンの出方は変わらない",
        properties: [
            .modifier(
                "writingToolsAffordanceVisibility",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0), on: true,
                summary: "作文ツールのボタンを出すか")
        ],
        code: CodeTemplate(call: "TextEditor", fixedArguments: ["text: $memo"], suffix: [".frame(height: 120)"])
    )
}
