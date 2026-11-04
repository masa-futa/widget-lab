import SwiftUI

nonisolated extension CatalogEntry {
    static let tabViewCustomization = CatalogEntry(
        id: "tabViewCustomization",
        kind: .modifier,
        topic: .navigation,
        summary: "サイドバーのタブを並べ替えたり隠したりした結果を、TabViewCustomization に書いて覚える modifier。タブには customizationID を付ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tabviewcustomization(_:)")!,
        noteReason: "iPhone ではタブを並べ替えたり隠したりできない。iPad と Mac のサイドバーで、タブを並べ替えた結果を覚える",
        properties: [
            .modifier(
                "tabViewCustomization", .fixed(code: "$customization"), on: true,
                summary: "並べ替え・隠した結果を書く Binding。@AppStorage に置けば、次に開いたときも戻る")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n        .customizationID(\"home\")\n    TabSection(\"果物\") {\n        Tab(\"りんご\", systemImage: \"leaf\") { Text(\"りんご\") }\n            .customizationID(\"apple\")\n    }\n    .customizationID(\"fruits\")\n}",
            suffix: [".tabViewStyle(.sidebarAdaptable)"])
    )
}
