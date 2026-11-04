import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarMinimizationBehavior = CatalogEntry(
        id: "toolbarMinimizationBehavior",
        kind: .modifier,
        topic: .toolbars,
        summary: "中身をスクロールしたとき、ナビゲーションバーや下のバーを小さく畳むかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/toolbarminimizationbehavior(_:for:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarMinimizationBehavior",
                .choice(
                    [Choice(".automatic"), Choice(".onScrollDown"), Choice(".onScrollUp"), Choice(".never")], initial: 1
                ), on: true, summary: "畳むきっかけ。一覧をスクロールして見る"),
            .modifier(
                "toolbarMinimizationBehavior", id: "toolbarMinimizationBehavior.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(
                        v.pick(
                            "toolbarMinimizationBehavior",
                            from: [ToolbarMinimizationBehavior.automatic, .onScrollDown, .onScrollUp, .never])
                    ) {
                        $0.toolbarMinimizationBehavior(
                            $1,
                            for: v.pick(
                                "toolbarMinimizationBehavior.for", from: [ToolbarPlacement.navigationBar, .bottomBar])
                                ?? .navigationBar)
                    }
                })
        }
    )
}
