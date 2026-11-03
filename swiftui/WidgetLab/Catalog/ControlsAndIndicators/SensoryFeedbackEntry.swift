import SwiftUI

nonisolated extension CatalogEntry {
    static let sensoryFeedback = CatalogEntry(
        id: "sensoryFeedback",
        kind: .modifier,
        topic: .controlsAndIndicators,
        summary: "trigger の値が変わるたびに、触覚（と音）のフィードバックを鳴らす modifier。実機で震える。シミュレータでは震えない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/sensoryfeedback(_:trigger:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "sensoryFeedback",
                .choice(
                    [
                        Choice(".success"), Choice(".warning"), Choice(".error"), Choice(".increase"),
                        Choice(".selection"), Choice(".impact"),
                    ],
                    initial: 0),
                on: true, summary: "鳴らすフィードバックの種類"),
            .modifier(
                "sensoryFeedback", id: "sensoryFeedback.trigger", label: "trigger", .fixed(code: "count"),
                required: true, summary: "見張る値。変わるたびに鳴らす"),
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"+1\""], trailing: " { count += 1 }"),
        build: { v in
            AnyView(
                SensoryFeedbackDemo(
                    feedback: v.pick(
                        "sensoryFeedback",
                        from: [
                            (SensoryFeedback.success, ".success"), (.warning, ".warning"), (.error, ".error"),
                            (.increase, ".increase"), (.selection, ".selection"), (.impact, ".impact"),
                        ])))
        }
    )
}

private struct SensoryFeedbackDemo: View {
    /// 鳴らすフィードバックと、記録に出す名前。nil なら鳴らさない
    let feedback: (value: SensoryFeedback, name: String)?
    @State private var count = 0
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 8) {
            Button("+1") {
                count += 1
                if let feedback {
                    recorder?.log("count を \(count) にした（\(feedback.name) を鳴らす）")
                } else {
                    recorder?.log("count を \(count) にした（鳴らさない）")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .apply(feedback) { $0.sensoryFeedback($1.value, trigger: count) }
            Text("count: \(count)")
                .monospacedDigit()
        }
    }
}
