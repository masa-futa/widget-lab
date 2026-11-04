import SwiftUI

nonisolated extension CatalogEntry {
    static let tabViewSidebarBottomBar = CatalogEntry(
        id: "tabViewSidebarBottomBar",
        kind: .modifier,
        topic: .navigation,
        summary: "TabView のサイドバーのいちばん下に、スクロールしないバーを足す modifier。 サイドバーを出しているときだけ見える。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/tabviewsidebarbottombar(content:)")!,
        noteReason: "iPhone ではタブがサイドバーで出ないので見えない。iPad と Mac で、タブをサイドバーで出しているときに出る",
        properties: [
            .modifier(
                "tabViewSidebarBottomBar", label: "content",
                .fixed(code: "{ Button(\"アカウント\", systemImage: \"person.circle\") { } }"), on: true,
                summary: "下に止まって出す View")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    TabSection(\"果物\") {\n        Tab(\"りんご\", systemImage: \"leaf\") { Text(\"りんご\") }\n        Tab(\"みかん\", systemImage: \"sun.max\") { Text(\"みかん\") }\n    }\n}",
            suffix: [".tabViewStyle(.sidebarAdaptable)"])
    )
}
