import SwiftUI

nonisolated extension CatalogEntry {
    static let help = CatalogEntry(
        id: "help",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "View に、操作の手助けになる短い説明を付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/help(_:)")!,
        noteReason: "iPhone では見た目が変わらない。iPad と Mac で、ポインタを重ねたときに説明が出る",
        properties: [
            .modifier("help", .text(initial: "書いた内容を保存する"), on: true, summary: "説明の文")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存\""], trailing: " { }")
    )
}
