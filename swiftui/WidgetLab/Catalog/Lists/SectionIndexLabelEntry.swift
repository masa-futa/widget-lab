import SwiftUI

nonisolated extension CatalogEntry {
    static let sectionIndexLabel = CatalogEntry(
        id: "sectionIndexLabel",
        kind: .modifier,
        topic: .lists,
        summary: "List の節の索引に出す文字（ふつうは 1 文字）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/sectionindexlabel(_:)")!,
        stage: .card,
        properties: [
            .modifier("sectionIndexLabel", .fixed(code: "group.letter"), on: true, summary: "索引に出す文字（節の頭の文字）")
        ],
        code: CodeTemplate(
            prefix: ["List {", "    ForEach(groups, id: \\.letter) { group in"], indent: 8, call: "Section",
            fixedArguments: ["group.letter"],
            trailing: " {\n            ForEach(group.names, id: \\.self) { Text($0) }\n        }",
            closing: ["    }", "}", ".listSectionIndexVisibility(.visible)"]),
        build: { v in
            AnyView(SectionIndexDemo(labels: v["sectionIndexLabel"] != nil, visibility: .visible))
        }
    )
}
