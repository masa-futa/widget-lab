import SwiftUI

nonisolated extension CatalogEntry {
    static let sequenceGesture = CatalogEntry(
        id: "SequenceGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 つのジェスチャーを順につなぐジェスチャー。1 つ目が成り立ってから、2 つ目を認識する。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/sequencegesture")!,
        stage: .card,
        properties: [
            .argument(
                "gestures", unlabeled: true,
                .choice(
                    [
                        Choice("0.5 秒の長押し → ドラッグ", code: "LongPressGesture(minimumDuration: 0.5), DragGesture()"),
                        Choice("1.5 秒の長押し → ドラッグ", code: "LongPressGesture(minimumDuration: 1.5), DragGesture()"),
                    ], initial: 0), required: true,
                summary: "つなぐ 2 つのジェスチャー。長押しが成り立つと色が変わり、そのまま引くと動く")
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)", "    .offset(offset)"], call: ".gesture(SequenceGesture",
            trailing: ".onChanged { if case .second(true, let drag) = $0 { offset = drag?.translation ?? .zero } })"),
        build: { v in
            AnyView(SequenceGestureDemo(minimumDuration: v.pick("gestures", from: [0.5, 1.5]) ?? 0.5))
        }
    )
}

private struct SequenceGestureDemo: View {
    let minimumDuration: Double
    @State private var isReady = false
    @State private var offset = CGSize.zero

    var body: some View {
        GestureTile(text: isReady ? "引いて動かす" : "長押ししてから引く", isActive: isReady)
            .offset(offset)
            .gesture(
                SequenceGesture(LongPressGesture(minimumDuration: minimumDuration), DragGesture())
                    .onChanged { value in
                        if case .second(true, let drag) = value {
                            isReady = true
                            offset = drag?.translation ?? .zero
                        }
                    }
                    .onEnded { _ in isReady = false }
            )
    }
}
