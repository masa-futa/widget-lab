import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityAdjustableAction = CatalogEntry(
        id: "accessibilityAdjustableAction",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術から値を上げ下げできるようにする modifier。VoiceOver では、上下にスワイプして 1 つずつ変える。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilityadjustableaction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityAdjustableAction",
                .fixed(code: "{ direction in rating += direction == .increment ? 1 : -1 }"), on: true,
                summary: "上げ下げの処理。上にスワイプで .increment、下で .decrement が渡る")
        ],
        code: CodeTemplate(
            prefix: ["StarRating(rating: $rating)", "    .accessibilityElement()", "    .accessibilityLabel(\"評価\")"],
            call: ".accessibilityValue", fixedArguments: ["\"\\(rating) 個\""]),
        build: { v in
            AnyView(AdjustableActionDemo(isAdjustable: v["accessibilityAdjustableAction"] != nil))
        }
    )
}

private struct AdjustableActionDemo: View {
    let isAdjustable: Bool
    @State private var rating = 3

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: lines) {
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                        .onTapGesture { rating = index }
                }
            }
            .font(.title2)
            .accessibilityElement()
            .accessibilityLabel("評価")
            .accessibilityValue("\(rating) 個")
            .apply(isAdjustable ? () : nil) { view, _ in
                view.accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: rating = min(rating + 1, 5)
                    case .decrement: rating = max(rating - 1, 1)
                    @unknown default: break
                    }
                }
            }
        }
    }

    private var lines: [String] {
        isAdjustable
            ? [A11yText.element("評価", value: "\(rating) 個", traits: [".adjustable"]), "上下にスワイプで 1 つずつ変える"]
            : [A11yText.element("評価", value: "\(rating) 個"), "（VoiceOver からは変えられない）"]
    }
}
