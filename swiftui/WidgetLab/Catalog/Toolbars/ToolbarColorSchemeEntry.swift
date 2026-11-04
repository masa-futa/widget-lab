import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarColorScheme = CatalogEntry(
        id: "toolbarColorScheme",
        kind: .modifier,
        topic: .toolbars,
        summary: "ナビゲーションバーや下のバーを、明るい見た目と暗い見た目のどちらで描くかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbarcolorscheme(_:for:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarColorScheme", .choice([Choice(".dark"), Choice(".light")], initial: 0), on: true,
                summary: "バーの見た目。.dark なら、濃い地の上で題名やボタンが白くなる"),
            .modifier(
                "toolbarColorScheme", id: "toolbarColorScheme.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(suffix: [
            ".toolbarBackground(.indigo, for: .navigationBar, .bottomBar)",
            ".toolbarBackgroundVisibility(.visible, for: .navigationBar, .bottomBar)",
            ".toolbarTitleDisplayMode(.inline)",
        ]),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(v.pick("toolbarColorScheme", from: [ColorScheme.dark, .light])) {
                        $0.toolbarColorScheme(
                            $1,
                            for: v.pick("toolbarColorScheme.for", from: [ToolbarPlacement.navigationBar, .bottomBar])
                                ?? .navigationBar)
                    }
                    .toolbarBackground(.indigo, for: .navigationBar, .bottomBar)
                    .toolbarBackgroundVisibility(.visible, for: .navigationBar, .bottomBar)
                    .toolbarTitleDisplayMode(.inline)
                })
        }
    )
}
