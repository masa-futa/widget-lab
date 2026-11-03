import SwiftUI

nonisolated extension CatalogEntry {
    static let stepper = CatalogEntry(
        id: "Stepper",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "＋と−のボタンで、値を 1 刻みずつ増やしたり減らしたりするコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/stepper")!,
        stage: .card,
        properties: [
            .argument(
                "in", .choice([Choice("0...10"), Choice("0...4")], initial: 0), on: true,
                summary: "選べる範囲。端まで来るとボタンが押せなくなる"),
            .argument("step", .slider(range: 1...5, step: 1, initial: 2), summary: "1 回で変わる量。省くと 1"),
            .modifier("labelsHidden", .fixed(code: ""), summary: "名前を隠す（読み上げには残る）"),
        ],
        code: CodeTemplate(call: "Stepper", fixedArguments: ["\"数: \\(count)\"", "value: $count"]),
        build: { v in
            AnyView(
                StepperDemo(
                    range: v.pick("in", from: [0...10, 0...4]), step: v.number("step").map { Int($0) },
                    hidesLabel: v["labelsHidden"] != nil))
        }
    )
}

private struct StepperDemo: View {
    let range: ClosedRange<Int>?
    let step: Int?
    let hidesLabel: Bool
    @State private var count = 2

    var body: some View {
        stepper
            .apply(hidesLabel ? () : nil) { view, _ in view.labelsHidden() }
            .monospacedDigit()
            .frame(width: 240)
    }

    @ViewBuilder
    private var stepper: some View {
        if let range {
            Stepper("数: \(count)", value: $count, in: range, step: step ?? 1)
        } else {
            Stepper("数: \(count)", value: $count, step: step ?? 1)
        }
    }
}
