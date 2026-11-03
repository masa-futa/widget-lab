import SwiftUI

nonisolated extension CatalogEntry {
    static let invalidatableContent = CatalogEntry(
        id: "invalidatableContent",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "中身が古くなるかもしれない View に印を付ける modifier。ウィジェットのボタンの処理を待つ間、印の付いた View を薄く見せる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/invalidatablecontent(_:)")!,
        noteReason: "ウィジェットとライブアクティビティの中で、ボタンの処理を待つ間に効く",
        properties: [
            .modifier("invalidatableContent", .toggle(initial: true), on: true, summary: "true で印を付ける。省くと true")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"気温 18℃\""])
    )
}
