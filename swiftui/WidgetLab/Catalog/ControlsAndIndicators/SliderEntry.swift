import SwiftUI

nonisolated extension CatalogEntry {
    static let slider = CatalogEntry(
        id: "Slider",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "決まった範囲の中から、つまみを動かして値を選ぶコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/slider")!,
        stage: .card,
        properties: [
            .argument("value", .fixed(code: "$volume"), required: true, summary: "選んだ値を入れる Binding"),
            .argument(
                "in", .choice([Choice("0...100"), Choice("0...10")], initial: 0), required: true,
                summary: "選べる範囲"),
            .argument("step", .slider(range: 1...25, step: 1, initial: 10), on: true, summary: "値の刻み。省くと切れ目なく動く"),
            .modifier("tint", .color(initial: 1), summary: "つまみの左側の色"),
        ],
        code: CodeTemplate(call: "Slider"),
        build: { v in
            AnyView(
                SliderDemo(
                    range: v.pick("in", from: [0.0...100.0, 0.0...10.0]) ?? 0...100, step: v.number("step"),
                    tint: v.color("tint")))
        }
    )
}

private struct SliderDemo: View {
    let range: ClosedRange<Double>
    let step: Double?
    let tint: Color?
    @State private var volume = 40.0

    var body: some View {
        VStack(spacing: 8) {
            slider
                .apply(tint) { $0.tint($1) }
            Text("volume: \(volume, format: .number.precision(.fractionLength(1)))")
                .monospacedDigit()
        }
        .frame(width: 260)
        // 範囲を狭めたとき、値を範囲の中に入れ直す（表示の数字がつまみの位置と食い違わないように）
        .onChange(of: range, initial: true) { volume = min(max(volume, range.lowerBound), range.upperBound) }
    }

    @ViewBuilder
    private var slider: some View {
        if let step {
            Slider(value: $volume, in: range, step: step)
        } else {
            Slider(value: $volume, in: range)
        }
    }
}
