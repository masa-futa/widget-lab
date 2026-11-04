import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityDropPoint = CatalogEntry(
        id: "accessibilityDropPoint",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術でドラッグを終えるときに離す場所と、その説明を決める modifier。VoiceOver の操作の一覧に出る。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilitydroppoint(_:description:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityDropPoint", id: "accessibilityDropPoint.point", label: nil,
                .choice([Choice(".trailing"), Choice(".center")], initial: 0), required: true,
                summary: "ドラッグを終える場所"),
            .modifier(
                "accessibilityDropPoint", id: "accessibilityDropPoint.description", label: "description",
                .text(initial: "アルバムに入れる"), on: true,
                summary: "操作の一覧に出す名前"),
        ],
        code: CodeTemplate(
            call: "Label", fixedArguments: ["\"アルバム\"", "systemImage: \"photo.on.rectangle\""],
            suffix: [".dropDestination(for: String.self) { items, _ in add(items) }"]),
        build: { v in
            AnyView(
                DropPointDemo(
                    point: v.pick("accessibilityDropPoint.point", from: [UnitPoint.trailing, .center]),
                    description: v.text("accessibilityDropPoint.description")))
        }
    )
}

private struct DropPointDemo: View {
    let point: UnitPoint?
    /// nil なら modifier をかけない
    let description: String?
    @State private var count = 0

    var body: some View {
        A11yDemo(title: "VoiceOver でドラッグを終える操作", lines: lines) {
            Label("アルバム（\(count) 枚）", systemImage: "photo.on.rectangle")
                .frame(width: 200, height: 80)
                .background(Color(.systemBackground), in: .rect(cornerRadius: 10))
                .overlay {
                    if let description, let point {
                        A11yPointMarker(point: point, label: description)
                    }
                }
                .dropDestination(for: String.self) { items, _ in
                    count += items.count
                    return true
                }
                .apply(description.map { ($0, point ?? .trailing) }) { view, pair in
                    view.accessibilityDropPoint(pair.1, description: LocalizedStringKey(pair.0))
                }
        }
    }

    private var lines: [String] {
        if let description {
            ["運んでいるときに、上下にスワイプして「\(description)」を選び、2 回タップ", "赤い点で離す"]
        } else {
            ["（離す操作は既定の名前で、真ん中で離す）"]
        }
    }
}
