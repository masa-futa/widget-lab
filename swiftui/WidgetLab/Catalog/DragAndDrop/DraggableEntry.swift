import SwiftUI

nonisolated extension CatalogEntry {
    static let draggable = CatalogEntry(
        id: "draggable",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "View を長押しして引くと、渡したもの（Transferable）を運べるようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/draggable(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "draggable", .text(initial: "りんご"), on: true,
                summary: "運ぶもの（Transferable）。札を長押しして下の箱へ引くと、この文字が箱に入る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], indent: 4, call: "Text", fixedArguments: ["\"りんご\""],
            closing: [
                "    Text(dropped.joined(separator: \"・\"))",
                "        .frame(width: 200, height: 72)",
                "        .dropDestination(for: String.self) { items, _ in dropped += items }",
                "}",
            ]),
        build: { v in
            AnyView(DraggableDemo(payload: v.text("draggable")))
        }
    )
}

private struct DraggableDemo: View {
    /// nil なら draggable を付けない
    let payload: String?
    @State private var dropped: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            DragChip(text: "りんご")
                .apply(payload) { $0.draggable($1) }
            DropBox(items: dropped)
                .dropDestination(for: String.self) { items, _ in dropped += items }
        }
    }
}
