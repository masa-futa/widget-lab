import SwiftUI

nonisolated extension CatalogEntry {
    static let keyframeAnimator = CatalogEntry(
        id: "KeyframeAnimator",
        kind: .view,
        topic: .animations,
        summary: "キーフレーム（時間と値の組）の並びに沿って値を動かし、その値で中身を描く入れ物。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/keyframeanimator")!,
        stage: .card,
        properties: [
            .argument(
                "initialValue", .fixed(code: "1.0"), required: true, summary: "動かす値の最初の値（ここでは大きさの倍率）"),
            .argument(
                "trigger", unlabeled: true,
                .choice(
                    [Choice("trigger", code: "trigger: count"), Choice("repeating", code: "repeating: true")],
                    initial: 0),
                required: true, summary: "いつ動かすか。trigger は値が変わるたび、repeating はずっと繰り返す"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "KeyframeAnimator",
            trailing: " { scale in\n        Image(systemName: \"star.fill\")\n            .font(.system(size: 48))\n"
                + "            .foregroundStyle(.orange)\n            .scaleEffect(scale)\n    } keyframes: { _ in\n"
                + "        KeyframeTrack {\n            CubicKeyframe(1.6, duration: 0.2)\n"
                + "            SpringKeyframe(1.0, duration: 0.6)\n        }\n    }",
            closing: ["    Button(\"+1\") { count += 1 }", "}"]),
        build: { v in
            AnyView(KeyframeAnimatorDemo(repeats: v.pick("trigger", from: [false, true]) ?? false))
        }
    )
}

private struct KeyframeAnimatorDemo: View {
    let repeats: Bool
    @State private var count = 0

    var body: some View {
        VStack {
            if repeats {
                KeyframeAnimator(initialValue: 1.0, repeating: true) { scale in
                    star(scale)
                } keyframes: { _ in
                    track
                }
            } else {
                KeyframeAnimator(initialValue: 1.0, trigger: count) { scale in
                    star(scale)
                } keyframes: { _ in
                    track
                }
            }
            Button("+1") { count += 1 }
                .buttonStyle(.bordered)
        }
    }

    private var track: some Keyframes<Double> {
        KeyframeTrack {
            CubicKeyframe(1.6, duration: 0.2)
            SpringKeyframe(1.0, duration: 0.6)
        }
    }

    private func star(_ scale: Double) -> some View {
        Image(systemName: "star.fill")
            .font(.system(size: 48))
            .foregroundStyle(.orange)
            .scaleEffect(scale)
    }
}
