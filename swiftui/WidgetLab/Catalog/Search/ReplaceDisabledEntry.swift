import SwiftUI

nonisolated extension CatalogEntry {
    static let replaceDisabled = CatalogEntry(
        id: "replaceDisabled",
        kind: .modifier,
        topic: .search,
        summary: "TextEditor の中を探す帯から、置き換える操作だけをできなくする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/replacedisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "replaceDisabled", .toggle(initial: true), on: true,
                summary: "true なら、検索の帯に置き換えの欄が出ない（探すだけになる）。文を押してからボタンを押して見る")
        ],
        code: .inFindDemo,
        build: { v in
            AnyView(FindDemo { $0.apply(v.flag("replaceDisabled")) { $0.replaceDisabled($1) } })
        }
    )
}
