import SwiftUI

nonisolated extension CatalogEntry {
    static let concentricRectangle = CatalogEntry(
        id: "ConcentricRectangle",
        kind: .view,
        topic: .shapes,
        summary: "入れ物の角の丸みと中心をそろえて（同心に）角を丸める長方形の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/concentricrectangle")!,
        stage: .card,
        properties: [
            .argument(
                "corners",
                .choice(
                    [Choice(".concentric"), Choice(".concentric(minimum: 24)"), Choice(".fixed(8)")], initial: 0),
                required: true, summary: "角の決め方（入れ物と同心・同心で下限あり・決めた半径）"),
            .modifier("fill", .color(initial: 4), on: true, summary: "中を塗る色"),
            .modifier(
                "padding", .slider(range: 0...40, step: 4, initial: 12), on: true,
                summary: "入れ物の縁からの距離。離すほど、同心の角は小さくなる"),
        ],
        code: CodeTemplate(
            prefix: ["ZStack {"], call: "ConcentricRectangle",
            closing: [
                "}", ".frame(width: 200, height: 120)", ".background(.yellow, in: .rect(cornerRadius: 40))",
                ".containerShape(.rect(cornerRadius: 40))",
            ]),
        build: { v in
            AnyView(
                ZStack {
                    ConcentricRectangle(
                        corners: v.pick("corners", from: [.concentric, .concentric(minimum: 24), .fixed(8)])
                            ?? .concentric
                    )
                    .apply(v.color("fill")) { $0.fill($1) }
                    .apply(v.number("padding")) { $0.padding(CGFloat($1)) }
                }
                .frame(width: 200, height: 120)
                .background(.yellow, in: .rect(cornerRadius: 40))
                .containerShape(.rect(cornerRadius: 40))
            )
        }
    )
}
