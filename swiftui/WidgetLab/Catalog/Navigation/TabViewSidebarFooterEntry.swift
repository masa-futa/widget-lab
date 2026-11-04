import SwiftUI

nonisolated extension CatalogEntry {
    static let tabViewSidebarFooter = CatalogEntry(
        id: "tabViewSidebarFooter",
        kind: .modifier,
        topic: .navigation,
        summary: "TabView のサイドバーのタブの後ろに、好きな View を足す modifier。サイドバーを出しているときだけ見える。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tabviewsidebarfooter(content:)")!,
        noteReason: "iPhone ではタブがサイドバーで出ないので見えない。iPad と Mac で、タブをサイドバーで出しているときに出る",
        properties: [
            .modifier(
                "tabViewSidebarFooter", label: "content",
                .fixed(code: "{ Text(\"v1.0\").foregroundStyle(.secondary) }"), on: true,
                summary: "タブの後ろに出す View")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    TabSection(\"果物\") {\n        Tab(\"りんご\", systemImage: \"leaf\") { Text(\"りんご\") }\n        Tab(\"みかん\", systemImage: \"sun.max\") { Text(\"みかん\") }\n    }\n}",
            suffix: [".tabViewStyle(.sidebarAdaptable)"])
    )
}
