import SwiftUI

nonisolated extension CatalogEntry {
    static let textInputBorderShape = CatalogEntry(
        id: "textInputBorderShape",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "入力欄などの枠の形を決める modifier。中の入力欄にまとめて効く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textinputbordershape(_:)")!,
        noteReason: "Mac などの入力欄の枠で効く。iPhone（iOS 27.0）では、.bordered の入力欄でも枠の形が変わらない",
        properties: [
            .modifier(
                "textInputBorderShape",
                .choice([Choice(".capsule"), Choice(".roundedRectangle"), Choice(".automatic")], initial: 0),
                on: true, summary: "枠の形")
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"名前\"", "text: $name"], suffix: [".textFieldStyle(.bordered)"])
    )
}
