import SwiftUI

nonisolated extension CatalogEntry {
    static let onDrag = CatalogEntry(
        id: "onDrag",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "View を長押しして引くと、NSItemProvider に入れたものを運べるようにする modifier。今は draggable を使うことがすすめられている。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/ondrag(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "onDrag", .fixed(code: "{ NSItemProvider(object: \"みかん\" as NSString) }"), on: true,
                summary: "運ぶものを入れた NSItemProvider を返す処理。ドラッグを始めたときに呼ばれる")
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], indent: 4, call: "Text", fixedArguments: ["\"みかん\""],
            closing: [
                "    Text(dropped.joined(separator: \"・\"))",
                "        .frame(width: 200, height: 72)",
                "        .dropDestination(for: String.self) { items, _ in dropped += items }",
                "}",
            ]),
        build: { v in
            AnyView(OnDragDemo(attaches: v["onDrag"] != nil))
        }
    )
}

private struct OnDragDemo: View {
    let attaches: Bool
    @State private var dropped: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            DragChip(text: "みかん")
                .apply(attaches ? () : nil) { view, _ in
                    view.onDrag { NSItemProvider(object: "みかん" as NSString) }
                }
            DropBox(items: dropped)
                .dropDestination(for: String.self) { items, _ in dropped += items }
        }
    }
}
