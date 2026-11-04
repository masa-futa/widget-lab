import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityDragPoint = CatalogEntry(
        id: "accessibilityDragPoint",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術でドラッグを始めるときに触れる場所と、その説明を決める modifier。VoiceOver の操作の一覧に出る。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilitydragpoint(_:description:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityDragPoint", id: "accessibilityDragPoint.point", label: nil,
                .choice([Choice(".topLeading"), Choice(".center")], initial: 0), required: true,
                summary: "ドラッグを始める場所"),
            .modifier(
                "accessibilityDragPoint", id: "accessibilityDragPoint.description", label: "description",
                .text(initial: "写真を運ぶ"), on: true,
                summary: "操作の一覧に出す名前"),
        ],
        code: CodeTemplate(call: "Image", fixedArguments: ["\"sunset\""], suffix: [".draggable(photo)"]),
        build: { v in
            AnyView(
                DragPointDemo(
                    point: v.pick("accessibilityDragPoint.point", from: [UnitPoint.topLeading, .center]),
                    description: v.text("accessibilityDragPoint.description")))
        }
    )
}

private struct DragPointDemo: View {
    let point: UnitPoint?
    /// nil なら modifier をかけない
    let description: String?

    var body: some View {
        A11yDemo(title: "VoiceOver でドラッグを始める操作", lines: lines) {
            LinearGradient(colors: [.orange, .pink, .purple], startPoint: .top, endPoint: .bottom)
                .overlay { Image(systemName: "sun.horizon.fill").font(.largeTitle).foregroundStyle(.yellow) }
                .frame(width: 140, height: 96)
                .clipShape(.rect(cornerRadius: 8))
                .overlay {
                    if let description, let point {
                        A11yPointMarker(point: point, label: description)
                    }
                }
                .draggable("写真")
                .apply(description.map { ($0, point ?? .topLeading) }) { view, pair in
                    view.accessibilityDragPoint(pair.1, description: LocalizedStringKey(pair.0))
                }
        }
    }

    private var lines: [String] {
        if let description {
            ["上下にスワイプして「\(description)」を選び、2 回タップ", "赤い点からドラッグを始める"]
        } else {
            ["（ドラッグの操作は既定の名前で、真ん中から始める）"]
        }
    }
}
