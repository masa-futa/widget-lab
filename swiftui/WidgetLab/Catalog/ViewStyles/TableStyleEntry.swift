import SwiftUI

nonisolated extension CatalogEntry {
    static let tableStyle = CatalogEntry(
        id: "tableStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Table の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tablestyle(_:)")!,
        noteReason: "iPhone では Table が最初の列だけの一覧になり、.automatic と .inset が同じ見た目になる"
            + "（iOS 27.0 で試して変わらなかった）。列が並ぶ iPad の広い画面と Mac で効く",
        properties: [
            .modifier(
                "tableStyle", .choice([Choice(".automatic"), Choice(".inset")], initial: 1), on: true,
                summary: "Table の見た目のスタイル")
        ],
        code: CodeTemplate(
            call: "Table", fixedArguments: ["fruits"],
            trailing:
                " {\n    TableColumn(\"名前\", value: \\.name)\n    TableColumn(\"値段\", value: \\.price)\n}",
            suffix: [".frame(height: 160)"])
    )
}
