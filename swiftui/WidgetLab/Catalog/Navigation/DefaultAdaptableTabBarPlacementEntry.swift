import SwiftUI

nonisolated extension CatalogEntry {
    static let defaultAdaptableTabBarPlacement = CatalogEntry(
        id: "defaultAdaptableTabBarPlacement",
        kind: .modifier,
        topic: .navigation,
        summary: "sidebarAdaptable のタブを、はじめにタブバーとサイドバーのどちらで出すかを決める modifier。タブバーとサイドバーを行き来できる iPad で効く。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/defaultadaptabletabbarplacement(_:)")!,
        noteReason: "iPad だけで効く（タブバーとサイドバーを切り替えられるのが iPad だけのため）。iPhone では defaultTabBarPlacement を使う",
        properties: [
            .modifier(
                "defaultAdaptableTabBarPlacement",
                .choice([Choice(".automatic"), Choice(".tabBar"), Choice(".sidebar")], initial: 2),
                on: true, summary: "はじめの出し方")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    Tab(\"一覧\", systemImage: \"list.bullet\") { List(1...40, id: \\.self) { Text(\"行 \\($0)\") } }\n    Tab(\"設定\", systemImage: \"gear\") { Text(\"設定\") }\n}",
            suffix: [".tabViewStyle(.sidebarAdaptable)"])
    )
}
