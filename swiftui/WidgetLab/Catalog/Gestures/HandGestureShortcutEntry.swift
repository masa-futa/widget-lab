import SwiftUI

nonisolated extension CatalogEntry {
    static let handGestureShortcut = CatalogEntry(
        id: "handGestureShortcut",
        kind: .modifier,
        topic: .gestures,
        summary: "手の動き（Apple Watch のダブルタップ）で、ボタンやトグルを押せるようにする modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/handgestureshortcut(_:isenabled:)")!,
        noteReason: "iPhone では効かない。Apple Watch で、指を 2 回合わせる（ダブルタップ）とボタンが押される",
        properties: [
            .modifier(
                "handGestureShortcut", .fixed(code: ".primaryAction"), on: true, summary: "割り当てる手の動き（主な操作）")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"再生\""], trailing: " { }")
    )
}
