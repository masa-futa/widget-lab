import SwiftUI

nonisolated extension CatalogEntry {
    static let dragConfiguration = CatalogEntry(
        id: "dragConfiguration",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "ドラッグを始める側で、運んだものを動かしてよいか（写すだけか）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/dragconfiguration(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "dragConfiguration",
                .choice(
                    [
                        Choice("動かせる", code: "DragConfiguration(allowMove: true)"),
                        Choice("写すだけ", code: "DragConfiguration(allowMove: false)"),
                    ], initial: 0), on: true,
                summary: "動かせるにすると、落とした札は元の場所から消える。写すだけ（付けないときも）なら残る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    if !moved {", "        Text(\"りんご\")"], indent: 12, call: ".draggable",
            fixedArguments: ["\"りんご\""],
            suffix: [".onDragSessionUpdated { if case .ended(.move) = $0.phase { moved = true } }"],
            closing: [
                "    }",
                "    Text(dropped.joined(separator: \"・\"))",
                "        .frame(width: 200, height: 72)",
                "        .dropDestination(for: String.self) { items, _ in dropped += items }",
                "        .dropConfiguration { _ in DropConfiguration(operation: .move) }",
                "}",
            ]),
        build: { v in
            AnyView(
                MoveDropDemo(
                    allowsMove: v.pick("dragConfiguration", from: [true, false]),
                    operation: .move))
        }
    )
}

/// 札を動かす（写す）見本。札の側の DragConfiguration と、箱の側の DropConfiguration を渡す（nil なら付けない）。
/// 動かして落とすと、札は元の場所から消える
struct MoveDropDemo: View {
    let allowsMove: Bool?
    let operation: DropOperation?
    @State private var moved = false
    @State private var dropped: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if !moved {
                    DragChip(text: "りんご")
                        .draggable("りんご")
                        .apply(allowsMove) { $0.dragConfiguration(DragConfiguration(allowMove: $1)) }
                        .onDragSessionUpdated { if case .ended(.move) = $0.phase { moved = true } }
                } else {
                    Button("札を戻す") {
                        moved = false
                        dropped = []
                    }
                    .font(.caption)
                }
            }
            .frame(height: 40)
            DropBox(items: dropped)
                .dropDestination(for: String.self) { items, _ in dropped += items }
                .apply(operation) { view, operation in
                    view.dropConfiguration { _ in DropConfiguration(operation: operation) }
                }
        }
    }
}
