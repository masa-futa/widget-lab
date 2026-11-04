import SwiftUI

nonisolated extension CatalogEntry {
    static let longPressGesture = CatalogEntry(
        id: "LongPressGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "決まった秒数より長く押されたら成り立つジェスチャー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/longpressgesture")!,
        stage: .behavior,
        properties: [
            .argument(
                "minimumDuration", .slider(range: 0.5...3, step: 0.5, initial: 1.5), on: true,
                summary: "長押しと認める秒数。省くと 0.5 秒"),
            .argument(
                "maximumDistance", .slider(range: 0...50, step: 10, initial: 0),
                summary: "押したまま指が動いてよい距離。超えると取り消す。省くと 10"),
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)"], call: ".gesture(LongPressGesture",
            trailing: ".onEnded { _ in print(\"長押し\") })"),
        build: { v in
            AnyView(
                LongPressGestureDemo(
                    minimumDuration: v.number("minimumDuration") ?? 0.5,
                    maximumDistance: v.number("maximumDistance") ?? 10))
        }
    )
}

private struct LongPressGestureDemo: View {
    let minimumDuration: Double
    let maximumDistance: Double
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        GestureTile(text: "\(minimumDuration.formatted()) 秒長押し")
            .gesture(
                LongPressGesture(minimumDuration: minimumDuration, maximumDistance: maximumDistance)
                    .onEnded { _ in recorder?.log("長押しを認識") }
            )
            .accessibilityAddTraits(.isButton)
    }
}
