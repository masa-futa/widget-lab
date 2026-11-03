import SwiftUI

nonisolated extension CatalogEntry {
    static let blendMode = CatalogEntry(
        id: "blendMode",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View を、後ろに描いたものとどう混ぜて描くか（合成の方法）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/blendmode(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "blendMode",
                .choice(
                    [Choice(".multiply"), Choice(".screen"), Choice(".difference"), Choice(".overlay")], initial: 0),
                on: true, summary: "混ぜ方（.multiply は掛けて暗く、.screen は明るく、.difference は差）")
        ],
        code: CodeTemplate(
            prefix: [
                "ZStack {", "    Circle()", "        .fill(.yellow)", "        .frame(width: 100, height: 100)",
                "        .offset(x: -30)", "    Circle()", "        .fill(.blue)",
            ],
            indent: 8, call: ".frame", fixedArguments: ["width: 100", "height: 100"], suffix: [".offset(x: 30)"],
            closing: ["}"]),
        build: { v in
            AnyView(
                ZStack {
                    Circle()
                        .fill(.yellow)
                        .frame(width: 100, height: 100)
                        .offset(x: -30)
                    Circle()
                        .fill(.blue)
                        .frame(width: 100, height: 100)
                        .apply(v.pick("blendMode", from: [BlendMode.multiply, .screen, .difference, .overlay])) {
                            $0.blendMode($1)
                        }
                        .offset(x: 30)
                }
            )
        }
    )
}
