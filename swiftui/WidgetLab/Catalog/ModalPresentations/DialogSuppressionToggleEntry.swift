import SwiftUI

nonisolated extension CatalogEntry {
    static let dialogSuppressionToggle = CatalogEntry(
        id: "dialogSuppressionToggle",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ダイアログに「今後は表示しない」のチェックを足し、選んだかを Binding に書く modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/dialogsuppressiontoggle(_:issuppressed:)")!,
        noteReason: "iPhone ではチェックが出ない。Mac のダイアログで効く",
        properties: [
            .modifier(
                "dialogSuppressionToggle", .fixed(code: "\"今後は確かめない\", isSuppressed: $suppressed"), on: true,
                summary: "チェックの文と、選んだかを書く Binding")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"削除\") { shows = true }"], indent: 4, call: ".alert",
            fixedArguments: ["\"削除しますか？\"", "isPresented: $shows"],
            trailing: " {\n        Button(\"削除\", role: .destructive) { }\n    }")
    )
}
