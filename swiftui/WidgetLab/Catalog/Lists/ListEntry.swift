import SwiftUI

nonisolated extension CatalogEntry {
    static let list = CatalogEntry(
        id: "List",
        kind: .view,
        topic: .lists,
        summary: "データの行を 1 列に並べる入れ物。行を選べるようにもできる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/list")!,
        stage: .card,
        properties: [
            .argument("selection", .fixed(code: "$selected"), on: true, summary: "選んだ行を入れる値（タップで行を選ぶ）"),
            .modifier(
                "listStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".insetGrouped"), Choice(".inset"), Choice(".plain"),
                        Choice(".grouped"),
                    ],
                    initial: 1),
                on: true, summary: "一覧の見た目のスタイル"),
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    ForEach([\"りんご\", \"みかん\", \"ぶどう\"], id: \\.self) { Text($0) }\n}"),
        build: { v in
            AnyView(
                ListDemo(
                    selects: v["selection"] != nil,
                    style: v.pick("listStyle", from: ListDemo.Style.allCases))
            )
        }
    )
}

private struct ListDemo: View {
    enum Style: CaseIterable {
        case automatic, insetGrouped, inset, plain, grouped
    }

    let selects: Bool
    let style: Style?
    @State private var selected: String? = "みかん"

    var body: some View {
        list
            .apply(style) { view, style in
                switch style {
                case .automatic: view.listStyle(.automatic)
                case .insetGrouped: view.listStyle(.insetGrouped)
                case .inset: view.listStyle(.inset)
                case .plain: view.listStyle(.plain)
                case .grouped: view.listStyle(.grouped)
                }
            }
    }

    @ViewBuilder
    private var list: some View {
        if selects {
            List(selection: $selected) { rows }
        } else {
            List { rows }
        }
    }

    private var rows: some View {
        ForEach(["りんご", "みかん", "ぶどう"], id: \.self) { Text($0) }
    }
}
