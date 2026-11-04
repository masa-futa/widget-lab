import SwiftUI

nonisolated extension CatalogEntry {
    static let onHover = CatalogEntry(
        id: "onHover",
        kind: .modifier,
        topic: .inputEvents,
        summary: "ポインタが View の上に乗ったときと、離れたときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onhover(perform:)")!,
        noteReason: "iPhone にはポインタがないので、効き目は出ない。iPad のトラックパッドやマウス、Mac で効く",
        properties: [
            .modifier(
                "onHover", label: "perform", .fixed(code: "{ hovering in isHovering = hovering }"), on: true,
                summary: "乗ったとき（true）と離れたとき（false）の処理")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"ポインタを乗せる\""])
    )
}
