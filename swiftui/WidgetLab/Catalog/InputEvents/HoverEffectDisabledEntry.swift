import SwiftUI

nonisolated extension CatalogEntry {
    static let hoverEffectDisabled = CatalogEntry(
        id: "hoverEffectDisabled",
        kind: .modifier,
        topic: .inputEvents,
        summary: "中の View に付けたポインタの効果を、出さないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/hovereffectdisabled(_:)")!,
        noteReason: "iPhone にはポインタがないので、もともと効果が出ない。iPad のトラックパッドやマウスと、Vision Pro の視線で効く",
        properties: [
            .modifier("hoverEffectDisabled", .toggle(initial: true), on: true, summary: "true なら効果を出さない")
        ],
        code: CodeTemplate(prefix: ["Button(\"保存\") { }"], call: ".hoverEffect", fixedArguments: [".lift"])
    )
}
