import SwiftUI

nonisolated extension CatalogEntry {
    static let symbolEffectsRemoved = CatalogEntry(
        id: "symbolEffectsRemoved",
        kind: .modifier,
        topic: .images,
        summary: "親からかかった記号の動き（symbolEffect）を、この View の中の記号だけ外す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/symboleffectsremoved(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "symbolEffectsRemoved", .toggle(initial: true), on: true,
                summary: "true なら星の動きを外す（ベルは動いたまま）")
        ],
        code: CodeTemplate(
            prefix: [
                "HStack(spacing: 24) {", "    Image(systemName: \"bell.fill\")", "    Image(systemName: \"star.fill\")",
            ],
            indent: 8, call: ".foregroundStyle", fixedArguments: [".orange"],
            closing: ["}", ".font(.system(size: 56))", ".symbolEffect(.pulse)"]),
        build: { v in
            AnyView(
                HStack(spacing: 24) {
                    Image(systemName: "bell.fill")
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)
                        .apply(v.flag("symbolEffectsRemoved")) { $0.symbolEffectsRemoved($1) }
                }
                .font(.system(size: 56))
                .symbolEffect(.pulse)
            )
        }
    )
}
