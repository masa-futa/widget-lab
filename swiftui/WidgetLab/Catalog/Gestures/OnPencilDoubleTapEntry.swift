import SwiftUI

nonisolated extension CatalogEntry {
    static let onPencilDoubleTap = CatalogEntry(
        id: "onPencilDoubleTap",
        kind: .modifier,
        topic: .gestures,
        summary: "Apple Pencil の軸を 2 回軽くたたいたときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onpencildoubletap(perform:)")!,
        noteReason: "iPhone では Apple Pencil が使えない。iPad で、ダブルタップに対応した Apple Pencil を使うときに効く",
        properties: [
            .modifier(
                "onPencilDoubleTap", label: "perform", .fixed(code: "{ _ in tool = tool == .pen ? .eraser : .pen }"),
                on: true, summary: "2 回たたいたときの処理（ペンと消しゴムを切り替えるなど）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"ペンで描く\""])
    )
}
