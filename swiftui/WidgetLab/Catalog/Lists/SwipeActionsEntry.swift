import SwiftUI

nonisolated extension CatalogEntry {
    static let swipeActions = CatalogEntry(
        id: "swipeActions",
        kind: .modifier,
        topic: .lists,
        summary: "List の行を横にずらしたときに出るボタンを足す modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/swipeactions(edge:allowsfullswipe:content:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "swipeActions", id: "swipeActions.edge", label: "edge",
                .choice([Choice(".trailing"), Choice(".leading")], initial: 0), required: true,
                summary: "ボタンを出す側（.trailing は左へずらす）"),
            .modifier(
                "swipeActions", id: "swipeActions.allowsFullSwipe", label: "allowsFullSwipe", .toggle(initial: false),
                required: true, summary: "端までずらすと最初のボタンを押したことにする"),
            .modifier(
                "swipeActions", id: "swipeActions.content", label: "content",
                .fixed(code: "{ Button(\"削除\", role: .destructive) { items.removeAll { $0 == item } } }"), on: true,
                summary: "出すボタン"),
        ],
        code: CodeTemplate(
            prefix: ["List {", "    ForEach(items, id: \\.self) { item in"], indent: 8, call: "Text",
            fixedArguments: ["item"], closing: ["    }", "}"]),
        build: { v in
            AnyView(
                SwipeActionsDemo(
                    adds: v["swipeActions.content"] != nil,
                    edge: v.pick("swipeActions.edge", from: [HorizontalEdge.trailing, .leading]) ?? .trailing,
                    allowsFullSwipe: v.flag("swipeActions.allowsFullSwipe") ?? true)
            )
        }
    )
}

private struct SwipeActionsDemo: View {
    let adds: Bool
    let edge: HorizontalEdge
    let allowsFullSwipe: Bool
    @State private var items = ["りんご", "みかん", "ぶどう"]

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .apply(adds ? () : nil) { view, _ in
                        view.swipeActions(edge: edge, allowsFullSwipe: allowsFullSwipe) {
                            Button("削除", role: .destructive) { items.removeAll { $0 == item } }
                        }
                    }
            }
        }
    }
}
