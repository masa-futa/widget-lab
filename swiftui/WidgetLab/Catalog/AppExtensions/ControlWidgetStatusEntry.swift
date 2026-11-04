import SwiftUI

nonisolated extension CatalogEntry {
    static let controlWidgetStatus = CatalogEntry(
        id: "controlWidgetStatus",
        kind: .modifier,
        topic: .appExtensions,
        summary: "コントロール（コントロールセンターなどに置くボタン）のラベルに、今の状態の短い文を付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/controlwidgetstatus(_:)")!,
        noteReason: "アプリ拡張のコントロール（ControlWidget）の中で効く。コントロールセンターで押したときに、状態の文が出る",
        properties: [
            .modifier(
                "controlWidgetStatus", .text(initial: "ついている"), on: true, summary: "今の状態の文。押して状態が変わったときに出る")
        ],
        code: CodeTemplate(
            prefix: ["// ControlWidgetToggle の label の中"], indent: 0, call: "Label",
            fixedArguments: ["\"明かり\"", "systemImage: \"lightbulb\""])
    )
}
