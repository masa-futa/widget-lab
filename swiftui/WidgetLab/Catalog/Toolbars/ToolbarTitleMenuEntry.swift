import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarTitleMenu = CatalogEntry(
        id: "toolbarTitleMenu",
        kind: .modifier,
        topic: .toolbars,
        summary: "ツールバーの題名を押すと出るメニューを決める modifier。題名の横に下向きの印が付く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbartitlemenu(content:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarTitleMenu",
                .fixed(
                    code:
                        "content: { Button(\"名前を変える\", systemImage: \"pencil\") { }; Button(\"複製\", systemImage: \"plus.square.on.square\") { } }"
                ), on: true, summary: "メニューの項目。題名を押すと出る")
        ],
        code: .inToolbarStack(suffix: [".toolbarTitleDisplayMode(.inline)"]),
        build: { v in
            AnyView(
                ToolbarStack {
                    $0.apply(v["toolbarTitleMenu"]) { view, _ in
                        view.toolbarTitleMenu {
                            Button("名前を変える", systemImage: "pencil") {}
                            Button("複製", systemImage: "plus.square.on.square") {}
                        }
                    }
                    .toolbarTitleDisplayMode(.inline)
                })
        }
    )
}
