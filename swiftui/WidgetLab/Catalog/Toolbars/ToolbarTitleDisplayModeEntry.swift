import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarTitleDisplayMode = CatalogEntry(
        id: "toolbarTitleDisplayMode",
        kind: .modifier,
        topic: .toolbars,
        summary: "ツールバーの題名を、大きく出すか、バーの中に小さく出すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbartitledisplaymode(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarTitleDisplayMode",
                .choice(
                    [Choice(".automatic"), Choice(".inline"), Choice(".inlineLarge"), Choice(".large")], initial: 2),
                on: true, summary: "題名の出し方。.inlineLarge は、バーの左に大きめの文字で出す")
        ],
        code: .inToolbarStack(),
        build: { v in
            AnyView(
                ToolbarStack {
                    $0.apply(
                        v.pick(
                            "toolbarTitleDisplayMode",
                            from: [ToolbarTitleDisplayMode.automatic, .inline, .inlineLarge, .large])
                    ) { $0.toolbarTitleDisplayMode($1) }
                })
        }
    )
}
