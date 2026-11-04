import SwiftUI

nonisolated extension CatalogEntry {
    static let listSectionIndexVisibility = CatalogEntry(
        id: "listSectionIndexVisibility",
        kind: .modifier,
        topic: .lists,
        summary: "List の右端に、節へ飛ぶ索引（sectionIndexLabel の文字）を出すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listsectionindexvisibility(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listSectionIndexVisibility",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0), on: true,
                summary: "索引を出すか（付けないときは出る。右端の文字を押すと、その節へ飛ぶ）")
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    ForEach(groups, id: \\.letter) { group in\n        Section(group.letter) {\n"
                + "            ForEach(group.names, id: \\.self) { Text($0) }\n        }\n"
                + "        .sectionIndexLabel(group.letter)\n    }\n}"),
        build: { v in
            AnyView(
                SectionIndexDemo(
                    labels: true,
                    visibility: v.pick("listSectionIndexVisibility", from: [Visibility.hidden, .visible, .automatic]))
            )
        }
    )
}
