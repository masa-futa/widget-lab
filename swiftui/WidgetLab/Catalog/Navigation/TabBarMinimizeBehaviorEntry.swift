import SwiftUI

nonisolated extension CatalogEntry {
    static let tabBarMinimizeBehavior = CatalogEntry(
        id: "tabBarMinimizeBehavior",
        kind: .modifier,
        topic: .navigation,
        summary: "中身をスクロールしたとき、タブバーを小さく畳むかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tabbarminimizebehavior(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "tabBarMinimizeBehavior",
                .choice(
                    [Choice(".automatic"), Choice(".onScrollDown"), Choice(".onScrollUp"), Choice(".never")], initial: 1
                ),
                on: true, summary: "畳むきっかけ。「一覧」のタブでスクロールして見る")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    Tab(\"一覧\", systemImage: \"list.bullet\") { List(1...40, id: \\.self) { Text(\"行 \\($0)\") } }\n    Tab(\"設定\", systemImage: \"gear\") { Text(\"設定\") }\n}"
        ),
        build: { v in
            AnyView(
                TabView { FruitTabs() }
                    .apply(
                        v.pick(
                            "tabBarMinimizeBehavior",
                            from: [TabBarMinimizeBehavior.automatic, .onScrollDown, .onScrollUp, .never])
                    ) { $0.tabBarMinimizeBehavior($1) })
        }
    )
}
