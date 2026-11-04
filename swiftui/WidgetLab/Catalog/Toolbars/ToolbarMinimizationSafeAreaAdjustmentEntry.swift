import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarMinimizationSafeAreaAdjustment = CatalogEntry(
        id: "toolbarMinimizationSafeAreaAdjustment",
        kind: .modifier,
        topic: .toolbars,
        summary: "スクロールでバーを畳んだとき、空いた分だけ中身の安全な領域を広げるかを決める modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/toolbarminimizationsafeareaadjustment(_:for:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarMinimizationSafeAreaAdjustment",
                .choice([Choice(".automatic"), Choice(".enabled"), Choice(".disabled")], initial: 2), on: true,
                summary: "広げるか。.disabled なら、畳んでも安全な領域が広がらず、黄色の印が元の位置に残る。一覧をスクロールして見る"),
            .modifier(
                "toolbarMinimizationSafeAreaAdjustment", id: "toolbarMinimizationSafeAreaAdjustment.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(suffix: [
            ".toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)",
            ".overlay(alignment: .top) { Text(\"安全な領域の上の端\").background(.yellow, ignoresSafeAreaEdges: []) }",
        ]),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(
                        v.pick(
                            "toolbarMinimizationSafeAreaAdjustment",
                            from: [ToolbarMinimizationSafeAreaAdjustment.automatic, .enabled, .disabled])
                    ) {
                        $0.toolbarMinimizationSafeAreaAdjustment(
                            $1,
                            for: v.pick(
                                "toolbarMinimizationSafeAreaAdjustment.for",
                                from: [ToolbarPlacement.navigationBar, .bottomBar]) ?? .navigationBar)
                    }
                    .toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)
                    .overlay(alignment: .top) { Text("安全な領域の上の端").background(.yellow, ignoresSafeAreaEdges: []) }
                })
        }
    )
}
