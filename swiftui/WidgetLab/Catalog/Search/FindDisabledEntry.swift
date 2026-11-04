import SwiftUI

nonisolated extension CatalogEntry {
    static let findDisabled = CatalogEntry(
        id: "findDisabled",
        kind: .modifier,
        topic: .search,
        summary: "TextEditor の中を探す・置き換える操作を、できなくする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/finddisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "findDisabled", .toggle(initial: true), on: true,
                summary: "true なら、文を押してからボタンを押しても、検索の帯が出ない")
        ],
        code: .inFindDemo,
        build: { v in
            AnyView(FindDemo { $0.apply(v.flag("findDisabled")) { $0.findDisabled($1) } })
        }
    )
}
