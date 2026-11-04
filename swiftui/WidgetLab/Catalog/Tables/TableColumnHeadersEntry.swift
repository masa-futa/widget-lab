import SwiftUI

nonisolated extension CatalogEntry {
    static let tableColumnHeaders = CatalogEntry(
        id: "tableColumnHeaders",
        kind: .modifier,
        topic: .tables,
        summary: "Table の列の見出しを出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tablecolumnheaders(_:)")!,
        noteReason: "iPhone（幅が compact）の Table は、最初の列だけを出し、列の見出しを出さない。iPad の幅の広い画面と Mac で効く",
        properties: [
            .modifier(
                "tableColumnHeaders",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0),
                on: true, summary: "見出しを出すか")
        ],
        code: CodeTemplate(
            call: "Table", fixedArguments: ["fruits"],
            trailing: " {\n    TableColumn(\"名前\", value: \\.name)\n    TableColumn(\"産地\", value: \\.origin)\n"
                + "    TableColumn(\"値段\") { Text(\"\\($0.price) 円\") }\n}")
    )
}
