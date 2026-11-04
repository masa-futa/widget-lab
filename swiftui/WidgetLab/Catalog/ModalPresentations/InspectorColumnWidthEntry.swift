import SwiftUI

nonisolated extension CatalogEntry {
    static let inspectorColumnWidth = CatalogEntry(
        id: "inspectorColumnWidth",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "インスペクタを右の列として出すときの幅を決める modifier。インスペクタの中身にかける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/inspectorcolumnwidth(_:)")!,
        noteReason: "iPhone ではインスペクタがシートで出るので、幅は効かない。iPad と Mac で、右の列として出るときに効く",
        properties: [
            .modifier(
                "inspectorColumnWidth", .slider(range: 200...400, step: 20, initial: 300), on: true,
                summary: "列の幅（ポイント）")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"本文\")", "    .inspector(isPresented: $shows) {"], indent: 8, call: "Text",
            fixedArguments: ["\"詳しい設定\""], closing: ["    }"])
    )
}
