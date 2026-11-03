import SwiftUI

nonisolated extension CatalogEntry {
    static let canvas = CatalogEntry(
        id: "Canvas",
        kind: .view,
        topic: .drawingAndGraphics,
        summary: "GraphicsContext に、Path や画像や文字を直接描いていく View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/canvas")!,
        stage: .card,
        properties: [
            .argument("opaque", .toggle(initial: true), on: true, summary: "不透明として描く（描いていないところが黒くなる）"),
            .argument(
                "colorMode", .choice([Choice(".nonLinear"), Choice(".linear"), Choice(".extendedLinear")], initial: 1),
                summary: "色を混ぜる計算の色空間（グラデーションの中ほどの明るさが変わる）"),
        ],
        code: CodeTemplate(
            call: "Canvas",
            trailing: " { context, size in\n"
                + "    let bar = CGRect(x: 0, y: 0, width: size.width, height: size.height / 2)\n"
                + "    context.fill(\n"
                + "        Path(roundedRect: bar, cornerRadius: 12),\n"
                + "        with: .linearGradient(\n"
                + "            Gradient(colors: [.blue, .yellow]), startPoint: .zero, endPoint: CGPoint(x: size.width, y: 0)))\n"
                + "    context.fill(\n"
                + "        Path(ellipseIn: CGRect(x: 0, y: size.height / 2 + 8, width: 60, height: 40)), with: .color(.red))\n"
                + "}",
            suffix: [".frame(width: 200, height: 120)"]),
        build: { v in
            AnyView(
                Canvas(
                    opaque: v.flag("opaque") ?? false,
                    colorMode: v.pick("colorMode", from: [ColorRenderingMode.nonLinear, .linear, .extendedLinear])
                        ?? .nonLinear
                ) { context, size in
                    let bar = CGRect(x: 0, y: 0, width: size.width, height: size.height / 2)
                    context.fill(
                        Path(roundedRect: bar, cornerRadius: 12),
                        with: .linearGradient(
                            Gradient(colors: [.blue, .yellow]), startPoint: .zero,
                            endPoint: CGPoint(x: size.width, y: 0)))
                    context.fill(
                        Path(ellipseIn: CGRect(x: 0, y: size.height / 2 + 8, width: 60, height: 40)),
                        with: .color(.red))
                }
                .frame(width: 200, height: 120)
            )
        }
    )
}
