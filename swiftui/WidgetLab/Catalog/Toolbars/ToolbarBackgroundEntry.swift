import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarBackground = CatalogEntry(
        id: "toolbarBackground",
        kind: .modifier,
        topic: .toolbars,
        summary: "ナビゲーションバーや下のバーの地の色（ShapeStyle）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbarbackground(_:for:)")!,
        stage: .full,
        properties: [
            .modifier("toolbarBackground", .color(initial: 2), on: true, summary: "地の色"),
            .modifier(
                "toolbarBackground", id: "toolbarBackground.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(suffix: [
            ".toolbarBackgroundVisibility(.visible, for: .navigationBar, .bottomBar)",
            ".toolbarTitleDisplayMode(.inline)",
        ]),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(v.color("toolbarBackground")) {
                        $0.toolbarBackground(
                            $1,
                            for: v.pick("toolbarBackground.for", from: [ToolbarPlacement.navigationBar, .bottomBar])
                                ?? .navigationBar)
                    }
                    .toolbarBackgroundVisibility(.visible, for: .navigationBar, .bottomBar)
                    .toolbarTitleDisplayMode(.inline)
                })
        }
    )
}
