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
            prefix: [
                "HStack {", "    ForEach(fruits) { fruit in", "        Text(fruit.id)",
                "            .draggable(containerItemID: fruit.id)",
                "            .onTapGesture { selection.append(fruit.id) }", "    }", "}",
            ],
            indent: 0, call: ".dragContainer", fixedArguments: ["for: Fruit.self"],
            trailing: " { ids in fruits.filter { ids.contains($0.id) } }"),
        build: { v in
            AnyView(DragContainerDemo(isContainer: true, selects: v["dragContainerSelection"] != nil))
        }
    )
}
