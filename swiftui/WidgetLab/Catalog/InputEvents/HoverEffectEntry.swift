import SwiftUI

nonisolated extension CatalogEntry {
    static let hoverEffect = CatalogEntry(
        id: "hoverEffect",
        kind: .modifier,
        topic: .inputEvents,
        summary: "ポインタが乗ったとき（visionOS では見つめたとき）の効果を、View に付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/hovereffect(_:isenabled:)")!,
        noteReason: "iPhone にはポインタがないので、効果は出ない。iPad のトラックパッドやマウスと、Vision Pro の視線で効く",
        properties: [
            .modifier(
                "hoverEffect", .choice([Choice(".automatic"), Choice(".highlight"), Choice(".lift")], initial: 2),
                on: true, summary: "効果の種類（.highlight は地が光る、.lift は浮き上がる）")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存\""], trailing: " { }")
    )
}
