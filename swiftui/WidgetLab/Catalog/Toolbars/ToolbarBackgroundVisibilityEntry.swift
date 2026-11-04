import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarBackgroundVisibility = CatalogEntry(
        id: "toolbarBackgroundVisibility",
        kind: .modifier,
        topic: .toolbars,
        summary: "ナビゲーションバーや下のバーの地を、出すか隠すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/toolbarbackgroundvisibility(_:for:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarBackgroundVisibility",
                .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 1), on: true,
                summary: "地を出すか。.visible なら、スクロールしていなくても地の色が出る"),
            .modifier(
                "toolbarBackgroundVisibility", id: "toolbarBackgroundVisibility.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(suffix: [
            ".toolbarBackground(.yellow, for: .navigationBar, .bottomBar)", ".toolbarTitleDisplayMode(.inline)",
        ]),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(
                        v.pick("toolbarBackgroundVisibility", from: [Visibility.automatic, .visible, .hidden])
                    ) {
                        $0.toolbarBackgroundVisibility(
                            $1,
                            for: v.pick(
                                "toolbarBackgroundVisibility.for", from: [ToolbarPlacement.navigationBar, .bottomBar])
                                ?? .navigationBar)
                    }
                    .toolbarBackground(.yellow, for: .navigationBar, .bottomBar)
                    .toolbarTitleDisplayMode(.inline)
                })
        }
    )
}
