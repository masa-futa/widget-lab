import SwiftUI

nonisolated extension CatalogEntry {
    static let containerRelativeShape = CatalogEntry(
        id: "ContainerRelativeShape",
        kind: .view,
        topic: .shapes,
        summary: "入れ物の形（containerShape で決めた形）を、置かれた場所に合わせて写した Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/containerrelativeshape")!,
        stage: .card,
        properties: [
            .modifier("fill", .color(initial: 4), on: true, summary: "中を塗る色"),
            .modifier(
                "padding", .slider(range: 0...40, step: 4, initial: 12), on: true, summary: "入れ物の縁からの距離"),
        ],
        code: CodeTemplate(
            prefix: ["ZStack {"], call: "ContainerRelativeShape",
            closing: [
                "}", ".frame(width: 200, height: 120)", ".background(.yellow, in: .rect(cornerRadius: 40))",
                ".containerShape(.rect(cornerRadius: 40))",
            ]),
        build: { v in
            AnyView(
                ZStack {
                    ContainerRelativeShape()
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
