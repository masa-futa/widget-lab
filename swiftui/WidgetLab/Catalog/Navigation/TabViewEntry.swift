import SwiftUI

nonisolated extension CatalogEntry {
    static let tabView = CatalogEntry(
        id: "TabView",
        kind: .view,
        topic: .navigation,
        summary: "下のタブバーなどで、いくつかの画面を切り替える View。中身は Tab で並べる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/tabview")!,
        stage: .full,
        properties: [
            .modifier(
                "tabViewStyle",
                .choice([Choice(".automatic"), Choice(".sidebarAdaptable"), Choice(".page")], initial: 0), on: true,
                summary: "切り替え方。.page は横にめくる"),
            .modifier("tint", .color(initial: 1), summary: "選んでいるタブの色"),
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    Tab(\"一覧\", systemImage: \"list.bullet\") { List(1...40, id: \\.self) { Text(\"行 \\($0)\") } }\n    Tab(\"設定\", systemImage: \"gear\") { Text(\"設定\") }\n}"
        ),
        build: { v in
            AnyView(
                TabView { FruitTabs() }
                    .apply(v.pick("tabViewStyle", from: [0, 1, 2])) { view, style in
                        switch style {
                        case 1: view.tabViewStyle(.sidebarAdaptable)
                        case 2: view.tabViewStyle(.page)
                        default: view.tabViewStyle(.automatic)
                        }
                    }
                    .apply(v.color("tint")) { $0.tint($1) })
        }
    )
}
