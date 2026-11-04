import SwiftUI

nonisolated extension CatalogEntry {
    static let itemProvider = CatalogEntry(
        id: "itemProvider",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "List の行などをドラッグしたときに運ぶものを、NSItemProvider で渡す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/itemprovider(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "itemProvider", .fixed(code: "{ NSItemProvider(object: name as NSString) }"), on: true,
                summary: "運ぶものを入れた NSItemProvider を返す処理。付けると、行を長押しして引ける")
        ],
        code: CodeTemplate(
            prefix: ["List(fruits, id: \\.self) { name in"], indent: 4, call: "Text", fixedArguments: ["name"],
            closing: ["}"]),
        build: { v in
            AnyView(ItemProviderDemo(attaches: v["itemProvider"] != nil))
        }
    )
}

private struct ItemProviderDemo: View {
    let attaches: Bool
    @State private var dropped: [String] = []

    var body: some View {
        VStack(spacing: 12) {
            List(dragFruits.map(\.id), id: \.self) { name in
                Text(name)
                    .apply(attaches ? () : nil) { view, _ in
                        view.itemProvider { NSItemProvider(object: name as NSString) }
                    }
            }
            .frame(width: 240, height: 150)
            DropBox(items: dropped)
                .dropDestination(for: String.self) { items, _ in dropped += items }
        }
    }
}
