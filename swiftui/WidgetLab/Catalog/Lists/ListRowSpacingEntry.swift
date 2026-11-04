import SwiftUI

nonisolated extension CatalogEntry {
    static let listRowSpacing = CatalogEntry(
        id: "listRowSpacing",
        kind: .modifier,
        topic: .lists,
        summary: "List の隣り合う行の、縦の間を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listrowspacing(_:)")!,
        stage: .card,
        properties: [
            .modifier("listRowSpacing", .slider(range: 0...24, step: 2, initial: 12), on: true, summary: "行の間"),
            .modifier(
                "listStyle", .choice([Choice(".insetGrouped"), Choice(".plain")], initial: 0),
                summary: "一覧の見た目のスタイル"),
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    ForEach([\"りんご\", \"みかん\", \"ぶどう\"], id: \\.self) { Text($0) }\n}"),
        build: { v in
            AnyView(
                List {
                    ForEach(["りんご", "みかん", "ぶどう"], id: \.self) { Text($0) }
                }
                .apply(v.number("listRowSpacing")) { $0.listRowSpacing(CGFloat($1)) }
                .apply(v.pick("listStyle", from: [0, 1])) { view, style in
                    if style == 0 { view.listStyle(.insetGrouped) } else { view.listStyle(.plain) }
                }
            )
        }
    )
}
