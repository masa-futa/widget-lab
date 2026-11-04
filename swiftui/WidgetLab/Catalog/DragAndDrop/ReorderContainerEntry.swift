import SwiftUI

nonisolated extension CatalogEntry {
    static let reorderContainer = CatalogEntry(
        id: "reorderContainer",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "中の View を、長押しして引くと並べ替えられる入れ物にする modifier。ForEach に reorderable() を付けて使う。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/reordercontainer(for:isenabled:move:)")!,
        stage: .card,
        properties: [
            .modifier(
                "reorderContainer", id: "reorderContainer.for", label: "for", .fixed(code: "Fruit.self"),
                required: true,
                summary: "並べるものの型（Identifiable）"),
            .modifier(
                "reorderContainer", id: "reorderContainer.isEnabled", label: "isEnabled", .toggle(initial: true),
                required: true, summary: "false にすると、付けたまま並べ替えられなくなる"),
            .modifier(
                "reorderContainer", label: "move", .fixed(code: "{ difference in fruits.apply(difference) }"), on: true,
                summary: "並べ替えたときの処理。動かした id と行き先を受け取り、配列を並べ直す"),
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing: " {\n    ForEach(fruits) { fruit in\n        Text(fruit.id)\n    }\n    .reorderable()\n}"),
        build: { v in
            AnyView(
                ReorderContainerDemo(
                    attaches: v["reorderContainer"] != nil, isEnabled: v.flag("reorderContainer.isEnabled") ?? true))
        }
    )
}

private struct ReorderContainerDemo: View {
    let attaches: Bool
    let isEnabled: Bool
    @State private var fruits = dragFruits

    var body: some View {
        HStack {
            ForEach(fruits) { fruit in
                DragChip(text: fruit.id)
            }
            .reorderable()
        }
        .apply(attaches ? () : nil) { view, _ in
            view.reorderContainer(for: DragFruit.self, isEnabled: isEnabled) { fruits.applyReorder($0) }
        }
    }
}
