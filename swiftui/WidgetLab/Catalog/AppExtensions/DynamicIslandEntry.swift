import SwiftUI

nonisolated extension CatalogEntry {
    static let dynamicIsland = CatalogEntry(
        id: "dynamicIsland",
        kind: .modifier,
        topic: .appExtensions,
        summary: "Dynamic Island で広げたライブアクティビティの中で、View を縦のどこに置くかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/dynamicisland(verticalplacement:)")!,
        noteReason: "アプリ拡張のライブアクティビティの中で効く。Dynamic Island を長押しして広げたときに出る",
        properties: [
            .modifier(
                "dynamicIsland", label: "verticalPlacement", .fixed(code: ".belowIfTooWide"), on: true,
                summary: "縦の置き場所。.belowIfTooWide なら、横に収まらないときにカメラの下へ回す")
        ],
        code: CodeTemplate(
            prefix: ["// DynamicIslandExpandedRegion(.leading) の中"], indent: 0, call: "Text",
            fixedArguments: ["\"到着まで 5 分\""])
    )
}
