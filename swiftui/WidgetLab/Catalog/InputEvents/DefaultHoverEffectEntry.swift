import SwiftUI

nonisolated extension CatalogEntry {
    static let defaultHoverEffect = CatalogEntry(
        id: "defaultHoverEffect",
        kind: .modifier,
        topic: .inputEvents,
        summary: "中の View に、ポインタが乗ったときの既定の効果を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/defaulthovereffect(_:)")!,
        noteReason: "iPhone にはポインタがないので、効果は出ない。iPad のトラックパッドやマウスと、Vision Pro の視線で効く",
        properties: [
            .modifier(
                "defaultHoverEffect",
                .choice([Choice(".automatic"), Choice(".highlight"), Choice(".lift")], initial: 1),
                on: true, summary: "中のボタンなどに使う既定の効果")
        ],
        code: CodeTemplate(call: "HStack", trailing: " {\n    Button(\"保存\") { }\n    Button(\"削除\") { }\n}")
    )
}
