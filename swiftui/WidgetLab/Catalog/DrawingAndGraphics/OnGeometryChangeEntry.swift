import SwiftUI

nonisolated extension CatalogEntry {
    static let onGeometryChange = CatalogEntry(
        id: "onGeometryChange",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の大きさや場所から取り出した値が変わったときに、処理を呼ぶ modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/ongeometrychange(for:of:action:)")!,
        stage: .card,
        properties: [
            .argument(
                "of",
                .choice(
                    [
                        Choice("幅", code: "{ proxy in proxy.size.width }"),
                        Choice("高さ", code: "{ proxy in proxy.size.height }"),
                        Choice("左端の x", code: "{ proxy in proxy.frame(in: .global).minX }"),
                    ],
                    initial: 0),
                required: true, summary: "取り出す値（GeometryProxy から計算する）")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .padding()", "    .background(.yellow)"], call: ".onGeometryChange",
            fixedArguments: ["for: CGFloat.self"], trailing: " { value in\n        self.value = value\n    }"),
        build: { v in
            AnyView(
                GeometryChangeDemo(
                    measure: v.pick("of", from: GeometryChangeDemo.measures) ?? GeometryChangeDemo.measures[0]))
        }
    )
}

private struct GeometryChangeDemo: View {
    static let measures: [@Sendable (GeometryProxy) -> CGFloat] = [
        { proxy in proxy.size.width }, { proxy in proxy.size.height }, { proxy in proxy.frame(in: .global).minX },
    ]

    let measure: @Sendable (GeometryProxy) -> CGFloat
    @State private var value: CGFloat?

    var body: some View {
        VStack(spacing: 12) {
            Text("見本")
                .padding()
                .background(.yellow)
                .onGeometryChange(for: CGFloat.self, of: measure) { value = $0 }
            Text(value.map { "value = \(Int($0))" } ?? "まだ呼ばれていない")
                .font(.callout.monospacedDigit())
        }
    }
}
