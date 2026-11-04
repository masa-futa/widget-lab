import SwiftUI

nonisolated extension CatalogEntry {
    static let focusEffectDisabled = CatalogEntry(
        id: "focusEffectDisabled",
        kind: .modifier,
        topic: .focus,
        summary: "フォーカスの輪（フォーカスリング）や、ポインタを重ねたときの浮き上がりを出さないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focuseffectdisabled(_:)")!,
        noteReason: "iPhone では、フォーカスの輪や浮き上がりが出ない。iPad や Mac でキーボードやポインタを使うときと、Apple TV で効く",
        properties: [
            .modifier("focusEffectDisabled", .toggle(initial: true), on: true, summary: "フォーカスの効果を出さないか")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"札\")"], indent: 4, call: ".focusable")
    )
}
