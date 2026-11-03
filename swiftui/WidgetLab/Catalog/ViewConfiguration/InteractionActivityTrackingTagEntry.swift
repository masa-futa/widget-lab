import SwiftUI

nonisolated extension CatalogEntry {
    static let interactionActivityTrackingTag = CatalogEntry(
        id: "interactionActivityTrackingTag",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "操作の速さを測るときに、どの View への操作かを見分ける名前（タグ）を付ける modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/interactionactivitytrackingtag(_:)")!,
        noteReason: "操作の速さの記録（Instruments など）に名前を付けるもので、画面の見た目は変わらない",
        properties: [
            .modifier("interactionActivityTrackingTag", .text(initial: "保存ボタン"), on: true, summary: "記録に付ける名前")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存\""], trailing: " { }")
    )
}
