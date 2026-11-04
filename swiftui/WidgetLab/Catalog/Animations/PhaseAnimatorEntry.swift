import SwiftUI

nonisolated extension CatalogEntry {
    static let phaseAnimator = CatalogEntry(
        id: "PhaseAnimator",
        kind: .view,
        topic: .animations,
        summary: "渡した段階（phase）を順に切り替え、段階ごとの見た目のあいだをアニメーションでつなぐ入れ物。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/phaseanimator")!,
        stage: .card,
        properties: [
            .argument(
                "phases", unlabeled: true,
                .choice(
                    [Choice("2 段", code: "[1.0, 1.4]"), Choice("3 段", code: "[1.0, 1.4, 0.7]")], initial: 0),
                required: true, summary: "切り替える段階の値（ここでは大きさの倍率）"),
            .argument(
                "trigger", .fixed(code: "count"), on: true,
                summary: "見張る値。変わるたびに段階を 1 周する（省くと、ずっと繰り返す）"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "PhaseAnimator",
            trailing: " { scale in\n        Image(systemName: \"heart.fill\")\n            .font(.system(size: 48))\n"
                + "            .foregroundStyle(.pink)\n            .scaleEffect(scale)\n    } animation: { _ in\n"
                + "        .bouncy\n    }",
            closing: ["    Button(\"+1\") { count += 1 }", "}"]),
        build: { v in
            AnyView(
                PhaseAnimatorDemo(
                    phases: v.pick("phases", from: [[1.0, 1.4], [1.0, 1.4, 0.7]]) ?? [1.0, 1.4],
                    usesTrigger: v["trigger"] != nil))
        }
    )
}

private struct PhaseAnimatorDemo: View {
    let phases: [Double]
    let usesTrigger: Bool
    @State private var count = 0

    var body: some View {
        VStack {
            if usesTrigger {
                PhaseAnimator(phases, trigger: count) { scale in
                    heart(scale)
                } animation: { _ in
                    .bouncy
                }
            } else {
                PhaseAnimator(phases) { scale in
                    heart(scale)
                } animation: { _ in
                    .bouncy
                }
            }
            Button("+1") { count += 1 }
                .buttonStyle(.bordered)
        }
    }

    private func heart(_ scale: Double) -> some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 48))
            .foregroundStyle(.pink)
            .scaleEffect(scale)
    }
}
