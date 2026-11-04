import SwiftUI

nonisolated extension CatalogEntry {
    static let onLongPressGesture = CatalogEntry(
        id: "onLongPressGesture",
        kind: .modifier,
        topic: .gestures,
        summary: "View が長押しされたときに、処理を行う modifier。押し始めと指を離したときにも処理を行える。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/onlongpressgesture(minimumduration:maximumdistance:perform:onpressingchanged:)"
        )!,
        stage: .behavior,
        properties: [
            .argument(
                "minimumDuration", .slider(range: 0.5...3, step: 0.5, initial: 1.5), on: true,
                summary: "長押しと認める秒数。省くと 0.5 秒"),
            .argument(
                "maximumDistance", .slider(range: 0...50, step: 10, initial: 0),
                summary: "押したまま指が動いてよい距離。超えると取り消す。省くと 10"),
            .argument(
                "perform", .fixed(code: "{ print(\"長押し\") }"), required: true, summary: "長押しを認めたときの処理"),
            .argument(
                "onPressingChanged", .fixed(code: "{ pressing in print(pressing) }"), on: true,
                summary: "押し始めと指を離したときの処理"),
        ],
        code: CodeTemplate(prefix: ["RoundedRectangle(cornerRadius: 12)"], call: ".onLongPressGesture"),
        build: { v in
            AnyView(
                OnLongPressGestureDemo(
                    minimumDuration: v.number("minimumDuration") ?? 0.5,
                    maximumDistance: v.number("maximumDistance") ?? 10,
                    watchesPressing: v["onPressingChanged"] != nil))
        }
    )
}

private struct OnLongPressGestureDemo: View {
    let minimumDuration: Double
    let maximumDistance: Double
    let watchesPressing: Bool
    @State private var isPressing = false
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        GestureTile(text: "\(minimumDuration.formatted()) 秒長押し", isActive: isPressing)
            .onLongPressGesture(
                minimumDuration: minimumDuration, maximumDistance: maximumDistance,
                perform: { recorder?.log("長押しを認識") },
                onPressingChanged: { pressing in
                    guard watchesPressing else { return }
                    isPressing = pressing
                    recorder?.log(pressing ? "押し始めた" : "指を離した")
                }
            )
            .accessibilityAddTraits(.isButton)
    }
}
