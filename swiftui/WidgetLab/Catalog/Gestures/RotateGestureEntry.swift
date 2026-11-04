import SwiftUI

nonisolated extension CatalogEntry {
    static let rotateGesture = CatalogEntry(
        id: "RotateGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 本の指で回す動きを認識し、回した角度を知らせるジェスチャー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/rotategesture")!,
        stage: .card,
        properties: [
            .argument(
                "minimumAngleDelta",
                .choice([Choice(".degrees(1)"), Choice(".degrees(20)"), Choice(".degrees(45)")], initial: 1), on: true,
                summary: "認識し始める角度の変わり幅。省くと 1 度")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"arrow.up\")", "    .rotationEffect(angle)"], call: ".gesture(RotateGesture",
            trailing: ".onChanged { angle = $0.rotation })"),
        build: { v in
            AnyView(
                RotateGestureDemo(
                    minimumAngleDelta: v.pick(
                        "minimumAngleDelta", from: [Angle.degrees(1), .degrees(20), .degrees(45)])
                        ?? .degrees(1)))
        }
    )
}

private struct RotateGestureDemo: View {
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
            .gesture(RotateGesture(minimumAngleDelta: minimumAngleDelta).onChanged { angle = $0.rotation })
    }
}
