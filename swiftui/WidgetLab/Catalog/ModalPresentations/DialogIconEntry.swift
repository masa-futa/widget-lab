import SwiftUI

nonisolated extension CatalogEntry {
    static let dialogIcon = CatalogEntry(
        id: "dialogIcon",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "この View の中で出すダイアログ（アラート・確かめのダイアログ）のアイコンを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/dialogicon(_:)")!,
        noteReason: "iPhone では見た目が変わらない。Mac ではアプリのアイコンの代わりに、Apple Watch ではダイアログの中に出る",
        properties: [
            .modifier(
                "dialogIcon", .fixed(code: "Image(systemName: \"trash\")"), on: true, summary: "ダイアログに出す画像")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"削除\") { shows = true }"], indent: 4, call: ".confirmationDialog",
            fixedArguments: ["\"削除しますか？\"", "isPresented: $shows"],
            trailing: " {\n        Button(\"削除\", role: .destructive) { }\n    }")
    )
}
