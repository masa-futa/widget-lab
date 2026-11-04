import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationSplitView = CatalogEntry(
        id: "NavigationSplitView",
        kind: .view,
        topic: .navigation,
        summary: "2 列か 3 列を並べ、前の列で選んだものを後ろの列に出す View。iPhone では 1 列に畳んで、積み重ねで行き来する。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/navigationsplitview")!,
        stage: .full,
        properties: [
            .argument(
                "preferredCompactColumn",
                .choice(
                    [Choice(".sidebar", code: ".constant(.sidebar)"), Choice(".detail", code: ".constant(.detail)")],
                    initial: 1),
                on: true, summary: "1 列に畳んだとき（iPhone）に、はじめに出す列"),
            .modifier(
                "navigationSplitViewStyle",
                .choice([Choice(".automatic"), Choice(".balanced"), Choice(".prominentDetail")], initial: 0),
                summary: "列の並べ方。iPhone では変わらない"),
        ],
        code: CodeTemplate(
            call: "NavigationSplitView",
            trailing:
                " {\n    List(fruits, id: \\.self, selection: $selected) { Text($0) }\n} detail: {\n    Text(selected ?? \"果物を選ぶ\")\n}"
        ),
        build: { v in
            AnyView(
                NavigationSplitViewDemo(
                    column: v.pick("preferredCompactColumn", from: [NavigationSplitViewColumn.sidebar, .detail]),
                    style: v.pick("navigationSplitViewStyle", from: [0, 1, 2])))
        }
    )
}

private struct NavigationSplitViewDemo: View {
    let column: NavigationSplitViewColumn?
    let style: Int?
    @State private var selected: String?

    var body: some View {
        Group {
            if let column {
                NavigationSplitView(preferredCompactColumn: .constant(column)) {
                    sidebar
                } detail: {
                    detail
                }
            } else {
                NavigationSplitView {
                    sidebar
                } detail: {
                    detail
                }
            }
        }
        .apply(style) { view, style in
            switch style {
            case 1: view.navigationSplitViewStyle(.balanced)
            case 2: view.navigationSplitViewStyle(.prominentDetail)
            default: view.navigationSplitViewStyle(.automatic)
            }
        }
    }

    private var sidebar: some View {
        List(navigationFruits, id: \.self, selection: $selected) { Text($0) }
            .navigationTitle("果物")
    }

    private var detail: some View {
        FruitScreen(name: selected ?? "果物を選ぶ")
    }
}
