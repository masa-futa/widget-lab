import SwiftUI

nonisolated extension CatalogEntry {
    static let dragContainerSelection = CatalogEntry(
        id: "dragContainerSelection",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "ドラッグの入れ物で、選んでいる札をまとめて運べるようにする modifier。選んだ札の 1 つを引くと、選んだ全部が運ばれる。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/dragcontainerselection(_:containernamespace:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "dragContainerSelection", .fixed(code: "selection"), on: true,
                summary: "選んでいる札の id の配列。札を押すと選べる（橙になる）")
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing:
                " {\n    ForEach(fruits) { fruit in\n        Text(fruit.id)\n            .draggable(containerItemID: fruit.id)\n            .onTapGesture { selection.append(fruit.id) }\n    }\n}",
            suffix: [".dragContainer(for: Fruit.self) { ids in fruits.filter { ids.contains($0.id) } }"]),
        build: { v in
            AnyView(DragContainerDemo(isContainer: true, selects: v["dragContainerSelection"] != nil))
        }
    )
}
