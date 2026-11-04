import SwiftUI
import UniformTypeIdentifiers

nonisolated extension CatalogEntry {
    static let onDrop = CatalogEntry(
        id: "onDrop",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "View を落とす先にし、落ちてきた NSItemProvider を受け取る modifier。今は dropDestination を使うことがすすめられている。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/ondrop(of:istargeted:perform:)")!,
        stage: .card,
        properties: [
            .modifier(
                "onDrop", id: "onDrop.of", label: "of", .choice([Choice("[.text]"), Choice("[.image]")], initial: 0),
                required: true, summary: "受け取る種類（UTType）。[.image] にすると、文字の札は落とせない"),
            .modifier(
                "onDrop", id: "onDrop.isTargeted", label: "isTargeted",
                .choice([Choice("$isTargeted"), Choice("nil")], initial: 0), required: true,
                summary: "上に乗っているかを書く Binding。nil なら知らせない（箱の色が変わらない）"),
            .modifier(
                "onDrop", label: "perform", .fixed(code: "{ providers in load(providers); return true }"), on: true,
                summary: "落ちたときの処理。true を返すと受け取ったことになる"),
        ],
        code: CodeTemplate(
            prefix: [
                "VStack {", "    Text(\"ぶどう\")", "        .draggable(\"ぶどう\")",
                "    Text(dropped.joined(separator: \"・\"))",
            ],
            indent: 8, call: ".frame", fixedArguments: ["width: 200", "height: 72"], closing: ["}"]),
        build: { v in
            AnyView(
                OnDropDemo(
                    attaches: v["onDrop"] != nil,
                    types: v.pick("onDrop.of", from: [[UTType.text], [.image]]) ?? [.text],
                    tracksTarget: v.pick("onDrop.isTargeted", from: [true, false]) ?? true))
        }
    )
}

private struct OnDropDemo: View {
    let attaches: Bool
    let types: [UTType]
    let tracksTarget: Bool
    @State private var dropped: [String] = []
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 16) {
            DragChip(text: "ぶどう")
                .draggable("ぶどう")
            DropBox(items: dropped, isTargeted: isTargeted)
                .apply(attaches ? () : nil) { view, _ in
                    view.onDrop(of: types, isTargeted: tracksTarget ? $isTargeted : nil) { providers in
                        loadTexts(from: providers) { dropped.append($0) }
                        return true
                    }
                }
        }
    }
}
