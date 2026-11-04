import SwiftUI

nonisolated extension CatalogEntry {
    static let tabViewSidebarHeader = CatalogEntry(
        id: "tabViewSidebarHeader",
        kind: .modifier,
        topic: .navigation,
        summary: "TabView のサイドバーのいちばん上（タブより前）に、好きな View を足す modifier。サイドバーを出しているときだけ見える。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tabviewsidebarheader(content:)")!,
        noteReason: "iPhone ではタブがサイドバーで出ないので見えない。iPad と Mac で、タブをサイドバーで出しているときに出る",
        properties: [
            .modifier(
                "tabViewSidebarHeader", label: "content", .fixed(code: "{ Text(\"ようこそ\").font(.title2) }"), on: true,
                summary: "頭に出す View")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    TabSection(\"果物\") {\n        Tab(\"りんご\", systemImage: \"leaf\") { Text(\"りんご\") }\n        Tab(\"みかん\", systemImage: \"sun.max\") { Text(\"みかん\") }\n    }\n}",
            suffix: [".tabViewStyle(.sidebarAdaptable)"])
    )
}
