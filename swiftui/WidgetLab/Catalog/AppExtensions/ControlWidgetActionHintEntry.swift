import SwiftUI

nonisolated extension CatalogEntry {
    static let controlWidgetActionHint = CatalogEntry(
        id: "controlWidgetActionHint",
        kind: .modifier,
        topic: .appExtensions,
        summary: "コントロール（コントロールセンターなどに置くボタン）のラベルに、押すと何が起きるかの短い説明を付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/controlwidgetactionhint(_:)")!,
        noteReason: "アプリ拡張のコントロール（ControlWidget）の中で効く。コントロールセンター・ロック画面・アクションボタンに置いたときに出る",
        properties: [
            .modifier(
                "controlWidgetActionHint", .text(initial: "つける"), on: true,
                summary: "押すと起きることの説明。アクションボタンに置いたときなどに出る")
        ],
        code: CodeTemplate(
            prefix: ["// ControlWidgetToggle の label の中"], indent: 0, call: "Label",
            fixedArguments: ["\"明かり\"", "systemImage: \"lightbulb\""])
    )
}
