import SwiftUI

nonisolated extension CatalogEntry {
    static let visualEffect = CatalogEntry(
        id: "visualEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の場所と大きさ（GeometryProxy）から、見た目の効果を決めてかける modifier。並びは変わらない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/visualeffect(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "visualEffect",
                .choice(
                    [
                        Choice(
                            "色を回す",
                            code:
                                "{ content, proxy in content.hueRotation(.degrees(proxy.frame(in: .scrollView).minY)) }"
                        ),
                        Choice(
                            "ずらす",
                            code: "{ content, proxy in content.offset(x: proxy.frame(in: .scrollView).minY / 4) }"),
                        Choice(
                            "ぼかす",
                            code:
                                "{ content, proxy in content.blur(radius: max(0, proxy.frame(in: .scrollView).minY / 40)) }"
                        ),
                    ],
                    initial: 0),
                on: true, summary: "かける効果（スクロールの枠の中の縦の位置で変える）")
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(0..<20, id: \\.self) { i in", "        Text(\"行 \\(i)\")",
                "            .frame(maxWidth: .infinity)",
            ],
            indent: 12, call: ".background", fixedArguments: [".yellow"], closing: ["    }", "}"]),
        build: { v in
            let effect = v.pick("visualEffect", from: [0, 1, 2])
            return AnyView(
                ScrollView {
                    ForEach(0..<20, id: \.self) { i in
                        VisualEffectDemo.row(
                            Text("行 \(i)").frame(maxWidth: .infinity).background(.yellow), effect: effect)
                    }
                }
            )
        }
    )
}

private enum VisualEffectDemo {
    @ViewBuilder
    static func row(_ view: some View, effect: Int?) -> some View {
        switch effect {
        case 0: view.visualEffect { content, proxy in content.hueRotation(.degrees(proxy.frame(in: .scrollView).minY)) }
        case 1: view.visualEffect { content, proxy in content.offset(x: proxy.frame(in: .scrollView).minY / 4) }
        case 2:
            view.visualEffect { content, proxy in content.blur(radius: max(0, proxy.frame(in: .scrollView).minY / 40)) }
        default: view
        }
    }
}
