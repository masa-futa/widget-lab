import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarVisibility = CatalogEntry(
        id: "toolbarVisibility",
        kind: .modifier,
        topic: .toolbars,
        summary: "ナビゲーションバーや下のバーを、出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbarvisibility(_:for:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarVisibility",
                .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 2),
                on: true, summary: "出すか。.hidden なら、バーごと隠れる（題名やボタンも）"),
            .modifier(
                "toolbarVisibility", id: "toolbarVisibility.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(v.pick("toolbarVisibility", from: [Visibility.automatic, .visible, .hidden])) {
                        $0.toolbarVisibility(
                            $1,
                            for: v.pick("toolbarVisibility.for", from: [ToolbarPlacement.navigationBar, .bottomBar])
                                ?? .navigationBar)
                    }
                })
        }
    )
}
