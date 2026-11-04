import SwiftUI

nonisolated extension CatalogEntry {
    static let windowToolbarFullScreenVisibility = CatalogEntry(
        id: "windowToolbarFullScreenVisibility",
        kind: .modifier,
        topic: .windows,
        summary: "窓をフルスクリーンにしたとき、窓のツールバーを出したままにするか、ポインタを上に寄せたときだけ出すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/windowtoolbarfullscreenvisibility(_:)")!,
        noteReason: "Mac だけで効く（iOS で選べるのは .automatic だけ）。Mac で窓をフルスクリーンにしたときに、ツールバーの出し方が変わる",
        properties: [
            .modifier(
                "windowToolbarFullScreenVisibility",
                .choice([Choice(".automatic"), Choice(".visible"), Choice(".onHover")], initial: 2), on: true,
                summary: "ツールバーの出し方。.onHover なら、ポインタを画面の上に寄せたときだけ出す")
        ],
        code: CodeTemplate(prefix: ["// Mac のアプリの窓の中"], indent: 0, call: "Text", fixedArguments: ["\"本文\""])
    )
}
