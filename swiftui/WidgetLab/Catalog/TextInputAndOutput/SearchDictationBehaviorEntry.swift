import SwiftUI

nonisolated extension CatalogEntry {
    static let searchDictationBehavior = CatalogEntry(
        id: "searchDictationBehavior",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "searchable で付けた検索欄で、音声入力をどう始めるかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/searchdictationbehavior(_:)")!,
        noteReason: "visionOS の検索欄で効く（見つめるだけで音声入力が始まるなど）。iPhone では見た目も動きも変わらない",
        properties: [
            .modifier(
                "searchDictationBehavior",
                .choice(
                    [
                        Choice(".inline(activation: .onLook)"), Choice(".inline(activation: .onSelect)"),
                        Choice(".automatic"),
                    ],
                    initial: 0),
                on: true, summary: "音声入力の始め方（.onLook は見つめたとき、.onSelect は検索欄を選んだとき）")
        ],
        code: CodeTemplate(
            call: "NavigationStack",
            trailing: " {\n    List(fruits, id: \\.self) { Text($0) }\n        .searchable(text: $query)\n}")
    )
}
