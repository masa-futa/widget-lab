import SwiftUI

nonisolated extension CatalogEntry {
    static let onTapGesture = CatalogEntry(
        id: "onTapGesture",
        kind: .modifier,
        topic: .gestures,
        summary: "View がタップされたときに、処理を行う modifier。count で、何回続けてタップしたら動くかを決める。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/ontapgesture(count:perform:)")!,
        stage: .behavior,
        properties: [
            .argument(
                "count", .slider(range: 1...3, step: 1, initial: 2), on: true,
                summary: "動くタップの回数。省くと 1 回")
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)"], call: ".onTapGesture", trailing: " { print(\"タップ\") }"),
        build: { v in
            AnyView(OnTapGestureDemo(count: v.number("count").map { Int($0) } ?? 1))
        }
    )
}

private struct OnTapGestureDemo: View {
    let count: Int
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        GestureTile(text: "\(count) 回タップ")
            .onTapGesture(count: count) { recorder?.log("タップ（\(count) 回）") }
            .accessibilityAddTraits(.isButton)
    }
}
