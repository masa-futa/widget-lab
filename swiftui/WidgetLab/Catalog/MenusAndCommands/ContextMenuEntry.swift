import SwiftUI

nonisolated extension CatalogEntry {
    static let contextMenu = CatalogEntry(
        id: "contextMenu",
        kind: .modifier,
        topic: .menusAndCommands,
        summary: "長押しで出るメニューを、View に付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/contextmenu(menuitems:)")!,
        stage: .card,
        properties: [
            .modifier(
                "contextMenu", label: "menuItems",
                .choice(
                    [
                        Choice("コピー", code: "{ Button(\"コピー\", systemImage: \"doc.on.doc\") { } }"),
                        Choice("削除", code: "{ Button(\"削除\", systemImage: \"trash\", role: .destructive) { } }"),
                    ],
                    initial: 0),
                on: true, summary: "メニューの中身")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"長押しする\""]),
        build: { v in
            AnyView(
                Text("長押しする")
                    .padding()
                    .background(.yellow, in: .rect(cornerRadius: 12))
                    .apply(v.pick("contextMenu", from: [false, true])) { view, deletes in
                        view.contextMenu {
                            if deletes {
                                Button("削除", systemImage: "trash", role: .destructive) {}
                            } else {
                                Button("コピー", systemImage: "doc.on.doc") {}
                            }
                        }
                    }
            )
        }
    )
}
