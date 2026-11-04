import SwiftUI

nonisolated extension CatalogEntry {
    static let indexViewStyle = CatalogEntry(
        id: "indexViewStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "ページ送りの TabView の、ページの位置を示す点の見た目を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/indexviewstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "indexViewStyle",
                .choice(
                    [
                        Choice(".page"), Choice(".page(backgroundDisplayMode: .always)"),
                        Choice(".page(backgroundDisplayMode: .interactive)"),
                        Choice(".page(backgroundDisplayMode: .never)"),
                    ],
                    initial: 1),
                on: true, summary: "点の見た目。backgroundDisplayMode は点の後ろの帯を出すか")
        ],
        code: CodeTemplate(
            call: "TabView", trailing: " {\n    Color.yellow\n    Color.mint\n    Color.cyan\n}",
            suffix: [".tabViewStyle(.page)", ".frame(width: 240, height: 140)"]),
        build: { v in
            AnyView(
                TabView {
                    Color.yellow
                    Color.mint
                    Color.cyan
                }
                .apply(
                    v.pick(
                        "indexViewStyle",
                        from: [
                            PageIndexViewStyle(), .page(backgroundDisplayMode: .always),
                            .page(backgroundDisplayMode: .interactive), .page(backgroundDisplayMode: .never),
                        ])
                ) { $0.indexViewStyle($1) }
                .tabViewStyle(.page)
                .frame(width: 240, height: 140)
            )
        }
    )
}
