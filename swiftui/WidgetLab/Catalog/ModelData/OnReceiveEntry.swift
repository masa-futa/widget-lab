import Combine
import SwiftUI

nonisolated extension CatalogEntry {
    static let onReceive = CatalogEntry(
        id: "onReceive",
        kind: .modifier,
        topic: .modelData,
        summary: "Combine の publisher が値を出したときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onreceive(_:perform:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onReceive", id: "onReceive.publisher", label: nil,
                .choice(
                    [Choice("1 秒ごと", code: "everySecond"), Choice("2 秒ごと", code: "everyTwoSeconds")], initial: 0),
                required: true, summary: "見張る publisher。ここでは Timer.publish の 2 つ"),
            .modifier(
                "onReceive", id: "onReceive.perform", label: "perform", .fixed(code: "{ _ in seconds += 1 }"),
                on: true, summary: "値が届いたときの処理。届くたびに記録に出る"),
        ],
        code: CodeTemplate(
            prefix: [
                "let everySecond = Timer.publish(every: 1, on: .main, in: .common).autoconnect()",
                "let everyTwoSeconds = Timer.publish(every: 2, on: .main, in: .common).autoconnect()",
                "",
            ],
            indent: 0, call: "Text", fixedArguments: ["\"届いた回数: \\(seconds)\""]),
        build: { v in
            AnyView(
                OnReceiveDemo(
                    interval: v["onReceive.perform"] != nil ? v.pick("onReceive.publisher", from: [1.0, 2.0]) : nil))
        }
    )
}

private struct OnReceiveDemo: View {
    /// nil なら onReceive をかけない
    let interval: Double?
    @State private var seconds = 0
    /// 見本ごとに 1 つだけ作る（body のたびに作ると、届くまでの時間が数え直しになる）
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @Environment(\.demoRecorder) private var recorder

    init(interval: Double?) {
        self.interval = interval
        _timer = State(initialValue: Timer.publish(every: interval ?? 1, on: .main, in: .common).autoconnect())
    }

    var body: some View {
        let _ = reportBody(recorder, "見本")
        Text("届いた回数: \(seconds)")
            .monospacedDigit()
            .font(.title3)
            .apply(interval) { view, _ in
                view.onReceive(timer) { _ in
                    seconds += 1
                    recorder?.log("Timer から値が届いた（\(seconds) 回目）")
                }
            }
    }
}
