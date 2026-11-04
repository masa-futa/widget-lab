import SwiftUI

nonisolated extension CatalogEntry {
    static let symbolRenderingMode = CatalogEntry(
        id: "symbolRenderingMode",
        kind: .modifier,
        topic: .images,
        summary: "SF Symbols の記号の層を、1 色・濃淡・指定の色・記号の決まった色のどれで塗るかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/symbolrenderingmode(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "symbolRenderingMode",
                .choice(
                    [Choice(".monochrome"), Choice(".hierarchical"), Choice(".palette"), Choice(".multicolor")],
                    initial: 2),
                on: true, summary: "層の塗り方"),
            .modifier(
                "foregroundStyle",
                .choice(
                    [Choice("1 色", code: ".blue"), Choice("3 色", code: ".blue, .yellow, .gray")], initial: 1),
                on: true, summary: "塗る色。.palette では層ごとに順に使う"),
        ],
        code: CodeTemplate(
            call: "Image", fixedArguments: ["systemName: \"cloud.sun.rain.fill\""],
            suffix: [".font(.system(size: 72))"]),
        build: { v in
            AnyView(
                Image(systemName: "cloud.sun.rain.fill")
                    .apply(
                        v.pick(
                            "symbolRenderingMode",
                            from: [SymbolRenderingMode.monochrome, .hierarchical, .palette, .multicolor])
                    ) { $0.symbolRenderingMode($1) }
                    .apply(v.pick("foregroundStyle", from: [false, true])) { view, threeColors in
                        if threeColors {
                            view.foregroundStyle(.blue, .yellow, .gray)
                        } else {
                            view.foregroundStyle(.blue)
                        }
                    }
                    .font(.system(size: 72))
            )
        }
    )
}
