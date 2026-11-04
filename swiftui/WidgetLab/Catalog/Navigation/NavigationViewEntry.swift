import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationView = CatalogEntry(
        id: "NavigationView",
        kind: .view,
        topic: .navigation,
        summary: "画面を積んで行き来する View の古い形。iOS 16 から非推奨で、NavigationStack か NavigationSplitView に置き換える。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/navigationview")!,
        stage: .full,
        properties: [
            .modifier(
                "navigationViewStyle", .choice([Choice(".automatic"), Choice(".stack")], initial: 1), on: true,
                summary: "並べ方。.stack は 1 列に積む（iPad でも 2 列にしない）")
        ],
        code: CodeTemplate(
            call: "NavigationView",
            trailing:
                " {\n    List(fruits, id: \\.self) { name in\n        NavigationLink(name) { Text(name) }\n    }\n    .navigationTitle(\"果物\")\n}"
        ),
        build: { v in
            AnyView(
                NavigationView {
                    List(navigationFruits, id: \.self) { name in
                        NavigationLink(name) { FruitScreen(name: name) }
                    }
                    .navigationTitle("果物")
                }
                .apply(v.pick("navigationViewStyle", from: [0, 1])) { view, style in
                    if style == 0 {
                        view.navigationViewStyle(.automatic)
                    } else {
                        view.navigationViewStyle(.stack)
                    }
                })
        }
    )
}
