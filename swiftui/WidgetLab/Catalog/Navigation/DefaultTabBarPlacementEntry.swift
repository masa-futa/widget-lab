import SwiftUI

nonisolated extension CatalogEntry {
    static let defaultTabBarPlacement = CatalogEntry(
        id: "defaultTabBarPlacement",
        kind: .modifier,
        topic: .navigation,
        summary: "sidebarAdaptable のタブを、タブバーとサイドバーのどちらで出すかを決める modifier。Mac・Apple TV・Vision Pro のように、片方しか出せないところで効く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/defaulttabbarplacement(_:)")!,
        noteReason:
            "iOS 27.0 の iPhone 18 Pro で .sidebar にしても、タブバーのままで変わらなかった。Mac・Apple TV・Vision Pro で、サイドバーかタブバーのどちらかに決まるときに効く",
        properties: [
            .modifier(
                "defaultTabBarPlacement",
                .choice([Choice(".automatic"), Choice(".tabBar"), Choice(".sidebar")], initial: 2),
                on: true, summary: "タブの出し方")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    Tab(\"一覧\", systemImage: \"list.bullet\") { List(1...40, id: \\.self) { Text(\"行 \\($0)\") } }\n    Tab(\"設定\", systemImage: \"gear\") { Text(\"設定\") }\n}",
            suffix: [".tabViewStyle(.sidebarAdaptable)"])
    )
}
