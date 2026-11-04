import SwiftUI

nonisolated extension CatalogEntry {
    static let textEditorStyle = CatalogEntry(
        id: "textEditorStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の TextEditor の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/texteditorstyle(_:)")!,
        noteReason: "iPhone では、選べる .automatic と .plain が同じ見た目になる（iOS 27.0 で試して変わらなかった）。"
            + "枠の付く .roundedBorder は macOS・visionOS で効く",
        properties: [
            .modifier(
                "textEditorStyle", .choice([Choice(".automatic"), Choice(".plain")], initial: 1), on: true,
                summary: "TextEditor の見た目のスタイル")
        ],
        code: CodeTemplate(
            call: "TextEditor", fixedArguments: ["text: $memo"], suffix: [".frame(width: 260, height: 100)"])
    )
}
