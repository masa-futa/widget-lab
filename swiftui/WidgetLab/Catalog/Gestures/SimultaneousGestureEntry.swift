import SwiftUI

nonisolated extension CatalogEntry {
    static let simultaneousGestureType = CatalogEntry(
        id: "SimultaneousGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 つのジェスチャーを同時に認識するジェスチャー。どちらかが先になることはない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/simultaneousgesture")!,
        stage: .card,
        properties: [
            .argument(
                "gestures", unlabeled: true, .fixed(code: "MagnifyGesture(), RotateGesture()"), required: true,
                summary: "同時に認識する 2 つのジェスチャー。2 本の指で広げながら回すと、大きさと向きが一緒に変わる")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"arrow.up\")", "    .scaleEffect(scale)", "    .rotationEffect(angle)"],
            call: ".gesture(SimultaneousGesture",
            trailing:
                ".onChanged { scale = $0.first?.magnification ?? 1; angle = $0.second?.rotation ?? .zero })"),
        build: { _ in
            AnyView(SimultaneousGestureDemo())
        }
    )
}

private struct SimultaneousGestureDemo: View {
    @State private var scale: CGFloat = 1
    @State private var angle = Angle.zero

    var body: some View {
        Image(systemName: "arrow.up")
            .font(.system(size: 56, weight: .bold))
            .foregroundStyle(.tint)
            .accessibilityLabel("矢印")
            .scaleEffect(scale)
            .rotationEffect(angle)
            .frame(width: 200, height: 160)
            .contentShape(.rect)
            .gesture(
                SimultaneousGesture(MagnifyGesture(), RotateGesture())
                    .onChanged {
                        scale = $0.first?.magnification ?? 1
                        angle = $0.second?.rotation ?? .zero
                    }
            )
    }
}
