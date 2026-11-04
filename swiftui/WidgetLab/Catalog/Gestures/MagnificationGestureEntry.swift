import SwiftUI

nonisolated extension CatalogEntry {
    static let magnificationGesture = CatalogEntry(
        id: "MagnificationGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 本の指で広げたりつまんだりする動きを認識し、拡大の倍率を知らせるジェスチャー。iOS 17 から非推奨で、MagnifyGesture に置き換わった。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/magnificationgesture")!,
        stage: .card,
        properties: [
            .argument(
                "minimumScaleDelta", .slider(range: 0...0.5, step: 0.1, initial: 0.3), on: true,
                summary: "認識し始める倍率の変わり幅。省くと 0.01")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"leaf.fill\")", "    .scaleEffect(scale)"],
            call: ".gesture(MagnificationGesture",
            trailing: ".onChanged { scale = $0 })"),
        build: { v in
            AnyView(MagnificationGestureDemo(minimumScaleDelta: v.number("minimumScaleDelta") ?? 0.01))
        }
    )
}

private struct MagnificationGestureDemo: View {
    let minimumScaleDelta: Double
    @State private var scale = 1.0

    var body: some View {
        Image(systemName: "leaf.fill")
            .font(.system(size: 56))
            .foregroundStyle(.green)
            .accessibilityLabel("葉")
            .scaleEffect(scale)
            .frame(width: 200, height: 160)
            .contentShape(.rect)
            .gesture(MagnificationGesture(minimumScaleDelta: minimumScaleDelta).onChanged { scale = $0 })
    }
}
