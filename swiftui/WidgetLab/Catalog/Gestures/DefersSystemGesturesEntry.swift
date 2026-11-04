import SwiftUI

nonisolated extension CatalogEntry {
    static let defersSystemGestures = CatalogEntry(
        id: "defersSystemGestures",
        kind: .modifier,
        topic: .gestures,
        summary: "画面の端から引く操作で、システムの操作（ホームに戻る・コントロールセンターなど）より、アプリのジェスチャーを先にする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/deferssystemgestures(on:)")!,
        stage: .full,
        properties: [
            .modifier(
                "defersSystemGestures", label: "on",
                .choice([Choice(".bottom"), Choice(".top"), Choice(".all")], initial: 0), on: true,
                summary: "後回しにする端。付けると、端から 1 回引いてもシステムの操作にならず、もう 1 回引くとなる")
        ],
        code: CodeTemplate(
            call: "Color.yellow",
            suffix: [".ignoresSafeArea()", ".gesture(DragGesture().onChanged { distance = $0.translation.height })"]),
        build: { v in
            AnyView(
                DefersSystemGesturesDemo(edges: v.pick("defersSystemGestures", from: [Edge.Set.bottom, .top, .all])))
        }
    )
}

private struct DefersSystemGesturesDemo: View {
    let edges: Edge.Set?
    @State private var distance = 0.0

    var body: some View {
        Color.yellow
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 8) {
                    Text("画面の下の端から上へ引く")
                        .font(.headline)
                    Text("引いた距離: \(Int(-distance))")
                        .monospacedDigit()
                }
            }
            .apply(edges) { $0.defersSystemGestures(on: $1) }
            .gesture(DragGesture().onChanged { distance = $0.translation.height })
    }
}
