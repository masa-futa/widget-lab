import SwiftUI

nonisolated extension CatalogEntry {
    static let contentShape = CatalogEntry(
        id: "contentShape",
        kind: .modifier,
        topic: .inputEvents,
        summary: "タップなどが当たる範囲の形を決める modifier。何も描いていない隙間も押せるようになる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/contentshape(_:eofill:)")!,
        stage: .card,
        properties: [
            .modifier(
                "contentShape", .choice([Choice(".rect"), Choice(".capsule"), Choice("Circle()")], initial: 0),
                on: true,
                summary: "当たる範囲の形。付けないと、星と文字の上だけが押せる")
        ],
        code: CodeTemplate(
            prefix: [
                "HStack {", "    Image(systemName: \"star.fill\")", "    Spacer()", "    Text(\"右の端\")", "}",
            ], indent: 0, call: ".frame", fixedArguments: ["width: 240", "height: 64"],
            suffix: [".onTapGesture { count += 1 }"]),
        build: { v in
            AnyView(
                ContentShapeDemo(
                    shape: v.pick("contentShape", from: [AnyShape(.rect), AnyShape(.capsule), AnyShape(Circle())])))
        }
    )
}

private struct ContentShapeDemo: View {
    /// nil なら contentShape を付けない
    let shape: AnyShape?
    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                Spacer()
                Text("右の端")
            }
            .padding(.horizontal, 12)
            .frame(width: 240, height: 64)
            .apply(shape) { $0.contentShape($1) }
            .onTapGesture { count += 1 }
            // 押せる範囲を見せる線。線そのものはタップを受けない
            .overlay {
                (shape ?? AnyShape(.rect))
                    .stroke(.tint, style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .opacity(shape == nil ? 0 : 1)
                    .allowsHitTesting(false)
            }
            Text("押した回数: \(count)")
                .font(.caption)
                .monospacedDigit()
        }
    }
}
