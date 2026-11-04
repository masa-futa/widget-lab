import SwiftUI

nonisolated extension CatalogEntry {
    static let rotationGesture = CatalogEntry(
        id: "RotationGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 本の指で回す動きを認識し、回した角度を知らせるジェスチャー。iOS 17 から非推奨で、RotateGesture に置き換わった。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/rotationgesture")!,
        stage: .card,
        properties: [
            .argument(
                "minimumAngleDelta",
                .choice([Choice(".degrees(1)"), Choice(".degrees(20)"), Choice(".degrees(45)")], initial: 1), on: true,
                summary: "認識し始める角度の変わり幅。省くと 1 度")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"arrow.up\")", "    .rotationEffect(angle)"], call: ".gesture(RotationGesture",
            trailing: ".onChanged { angle = $0 })"),
        build: { v in
            AnyView(
                RotationGestureDemo(
                    minimumAngleDelta: v.pick(
                        "minimumAngleDelta", from: [Angle.degrees(1), .degrees(20), .degrees(45)])
                        ?? .degrees(1)))
        }
    )
}

private struct RotationGestureDemo: View {
    let minimumAngleDelta: Angle
    @State private var angle = Angle.zero

    var body: some View {
        Image(systemName: "arrow.up")
            .font(.system(size: 56, weight: .bold))
            .foregroundStyle(.tint)
            .accessibilityLabel("矢印")
            .rotationEffect(angle)
            .frame(width: 200, height: 160)
            .contentShape(.rect)
            .gesture(RotationGesture(minimumAngleDelta: minimumAngleDelta).onChanged { angle = $0 })
    }
}
