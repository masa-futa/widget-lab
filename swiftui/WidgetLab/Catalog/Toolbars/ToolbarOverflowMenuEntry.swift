import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarOverflowMenu = CatalogEntry(
        id: "toolbarOverflowMenu",
        kind: .modifier,
        topic: .toolbars,
        summary: "ツールバーの「…」のメニュー（収まらない項目を入れる所）に、項目を足す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbaroverflowmenu(content:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarOverflowMenu",
                .fixed(
                    code:
                        "content: { Button(\"書き出す\", systemImage: \"square.and.arrow.up\") { }; Button(\"印刷\", systemImage: \"printer\") { } }"
                ), on: true, summary: "メニューに足す項目。右上の「…」を押すと出る")
        ],
        code: .inToolbarStack(),
        build: { v in
            AnyView(
                ToolbarStack {
                    $0.apply(v["toolbarOverflowMenu"]) { view, _ in
                        view.toolbarOverflowMenu {
                            Button("書き出す", systemImage: "square.and.arrow.up") {}
                            Button("印刷", systemImage: "printer") {}
                        }
                    }
                })
        }
    )
}
