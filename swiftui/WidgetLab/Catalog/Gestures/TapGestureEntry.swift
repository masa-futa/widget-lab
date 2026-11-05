import SwiftUI

nonisolated extension CatalogEntry {
    static let tapGesture = CatalogEntry(
        id: "TapGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "決まった回数のタップを認識するジェスチャー。VoiceOver の操作はジェスチャーを通らないので、この見本は accessibilityAction で同じ記録を出す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/tapgesture")!,
        stage: .behavior,
        properties: [
            .argument(
                "count", .slider(range: 1...3, step: 1, initial: 2), on: true,
                summary: "認識するタップの回数。省くと 1 回")
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)"], call: ".gesture(TapGesture", trailing: ".onEnded { })"),
        build: { v in
            AnyView(TapGestureDemo(count: v.number("count").map { Int($0) }))
        }
    )
}

private struct TapGestureDemo: View {
    /// nil なら TapGesture()（1 回）
    let count: Int?
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        RoundedRectangle(cornerRadius: 12)
            .fill(.tint.opacity(0.25))
            .frame(width: 120, height: 72)
            .overlay {
                Text("\(count ?? 1) 回タップ")
                    .font(.caption)
            }
            .gesture(gesture.onEnded { recorder?.log("タップを認識（\(count ?? 1) 回）") })
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            // VoiceOver の操作は 1 回の押す操作として届き、2 回以上の TapGesture は認識しない。同じ記録を出す
            .accessibilityAction { recorder?.log("VoiceOver の操作で押した（\(count ?? 1) 回のタップの代わり）") }
    }

    private var gesture: TapGesture {
        if let count { TapGesture(count: count) } else { TapGesture() }
    }
}
