import SwiftUI

nonisolated extension CatalogEntry {
    static let dropConfiguration = CatalogEntry(
        id: "dropConfiguration",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "落とす先の側で、落ちてきたものを写すか・動かすか・断るかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/dropconfiguration(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "dropConfiguration",
                .choice(
                    [
                        Choice(".move", code: "{ _ in DropConfiguration(operation: .move) }"),
                        Choice(".copy", code: "{ _ in DropConfiguration(operation: .copy) }"),
                        Choice(".forbidden", code: "{ _ in DropConfiguration(operation: .forbidden) }"),
                    ], initial: 0), on: true,
                summary: ".move なら札は元の場所から消え、.copy（付けないときも）なら残る。.forbidden なら落とせない")
        ],
        code: CodeTemplate(
            prefix: [
                "VStack {", "    if !moved {", "        Text(\"りんご\")", "            .draggable(\"りんご\")",
                "            .dragConfiguration(DragConfiguration(allowMove: true))",
                "            .onDragSessionUpdated { if case .ended(.move) = $0.phase { moved = true } }", "    }",
                "    Text(dropped.joined(separator: \"・\"))", "        .frame(width: 200, height: 72)",
            ], indent: 8, call: ".dropDestination", fixedArguments: ["for: String.self"],
            trailing: " { items, _ in dropped += items }", closing: ["}"]),
        build: { v in
            AnyView(
                MoveDropDemo(
                    allowsMove: true,
                    operation: v.pick("dropConfiguration", from: [DropOperation.move, .copy, .forbidden])))
        }
    )
}
