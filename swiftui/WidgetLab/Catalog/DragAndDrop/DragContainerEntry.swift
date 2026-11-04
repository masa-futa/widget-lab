import SwiftUI

nonisolated extension CatalogEntry {
    static let dragContainer = CatalogEntry(
        id: "dragContainer",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "中の View の id から、ドラッグで運ぶものをあとで作る入れ物にする modifier。中の View は draggable(containerItemID:) で id だけを渡す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/dragcontainer(for:in:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "dragContainer", id: "dragContainer.for", label: "for", .fixed(code: "Fruit.self"), required: true,
                summary: "運ぶものの型（Transferable で Identifiable）"),
            .modifier(
                "dragContainer", .fixed(code: "{ ids in fruits.filter { ids.contains($0.id) } }"), on: true,
                summary: "引いた札の id から、運ぶものを作る処理。付けないと、札を引いても何も運べない"),
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing:
                " {\n    ForEach(fruits) { fruit in\n        Text(fruit.id)\n            .draggable(containerItemID: fruit.id)\n    }\n}"
        ),
        build: { v in
            AnyView(DragContainerDemo(isContainer: v["dragContainer"] != nil, selects: false))
        }
    )
}

/// 入れ物から札を運ぶ見本。isContainer なら dragContainer を付け、selects なら札を押して選べるようにし、
/// 選んだ札をまとめて運ぶ（dragContainerSelection）
struct DragContainerDemo: View {
    let isContainer: Bool
    let selects: Bool
    @State private var selection: [String] = []
    @State private var dropped: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ForEach(dragFruits) { fruit in
                    DragChip(text: fruit.id, isSelected: selection.contains(fruit.id))
                        .draggable(containerItemID: fruit.id)
                        .apply(selects ? () : nil) { view, _ in
                            view.onTapGesture {
                                if let i = selection.firstIndex(of: fruit.id) {
                                    selection.remove(at: i)
                                } else {
                                    selection.append(fruit.id)
                                }
                            }
                        }
                }
            }
            .apply(isContainer ? () : nil) { view, _ in
                view.dragContainer(for: DragFruit.self) { ids in dragFruits.filter { ids.contains($0.id) } }
            }
            .apply(selects ? () : nil) { view, _ in view.dragContainerSelection(selection) }
            DropBox(items: dropped)
                .dropDestination(for: String.self) { items, _ in dropped += items }
        }
    }
}
