import SwiftUI

nonisolated extension CatalogEntry {
    static let dragGesture = CatalogEntry(
        id: "DragGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "指で引く動きを認識し、動かした量や位置を続けて知らせるジェスチャー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/draggesture")!,
        stage: .card,
        properties: [
            .argument(
                "minimumDistance", .slider(range: 0...60, step: 10, initial: 40), on: true,
                summary: "引き始めと認める距離。これより短いと動かない。省くと 10")
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)", "    .offset(offset)"], call: ".gesture(DragGesture",
            trailing: ".onChanged { offset = $0.translation })"),
        build: { v in
            AnyView(DragGestureDemo(minimumDistance: v.number("minimumDistance") ?? 10))
        }
    )
}

private struct DragGestureDemo: View {
    let minimumDistance: Double
    @State private var offset = CGSize.zero

    var body: some View {
        GestureTile(text: "引いて動かす")
            .offset(offset)
            .gesture(DragGesture(minimumDistance: minimumDistance).onChanged { offset = $0.translation })
    }
}
