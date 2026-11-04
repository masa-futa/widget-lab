import SwiftUI

nonisolated extension CatalogEntry {
    static let onPencilSqueeze = CatalogEntry(
        id: "onPencilSqueeze",
        kind: .modifier,
        topic: .gestures,
        summary: "Apple Pencil を握ったときに、処理を行う modifier。握り始め・握っている間・離したときの段階を受け取る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onpencilsqueeze(perform:)")!,
        noteReason: "iPhone では Apple Pencil が使えない。iPad で、Apple Pencil Pro を使うときに効く",
        properties: [
            .modifier(
                "onPencilSqueeze", label: "perform",
                .fixed(code: "{ phase in if case .ended = phase { showsPalette.toggle() } }"), on: true,
                summary: "握ったときの処理（道具のパレットを出すなど）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"ペンで描く\""])
    )
}
