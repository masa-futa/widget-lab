import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarMinimizationRestoration = CatalogEntry(
        id: "toolbarMinimizationRestoration",
        kind: .modifier,
        topic: .toolbars,
        summary: "スクロールで畳んだバーを、いつ元の大きさに戻すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/toolbarminimizationrestoration(_:for:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarMinimizationRestoration", .choice([Choice(".automatic"), Choice(".atScrollEdge")], initial: 1),
                on: true, summary: "戻すきっかけ。.atScrollEdge なら、いちばん上（端）までスクロールしたときだけ戻す"),
            .modifier(
                "toolbarMinimizationRestoration", id: "toolbarMinimizationRestoration.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(suffix: [".toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)"]),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(
                        v.pick(
                            "toolbarMinimizationRestoration",
                            from: [ToolbarMinimizationRestoration.automatic, .atScrollEdge])
                    ) {
                        $0.toolbarMinimizationRestoration(
                            $1,
                            for: v.pick(
                                "toolbarMinimizationRestoration.for",
                                from: [ToolbarPlacement.navigationBar, .bottomBar]) ?? .navigationBar)
                    }
                    .toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)
                })
        }
    )
}
