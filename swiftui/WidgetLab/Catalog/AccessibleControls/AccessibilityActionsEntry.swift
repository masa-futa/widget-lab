import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityActions = CatalogEntry(
        id: "accessibilityActions",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術から呼べる操作を、Button を並べてまとめて足す modifier。ボタンの名前が操作の名前になる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityactions(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityActions",
                .fixed(code: "{ Button(\"既読にする\") { isRead = true }; Button(\"旗を付ける\") { isFlagged = true } }"),
                on: true,
                summary: "足す操作を Button で並べる。画面には描かない")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["isRead ? \"既読: 会議の件\" : \"未読: 会議の件\""]),
        build: { v in
            AnyView(AccessibilityActionsDemo(hasActions: v["accessibilityActions"] != nil))
        }
    )
}

private struct AccessibilityActionsDemo: View {
    let hasActions: Bool
    @State private var isRead = false
    @State private var isFlagged = false

    var body: some View {
        A11yDemo(title: "VoiceOver で行える操作", lines: lines) {
            Text(isRead ? "既読: 会議の件" : "未読: 会議の件")
                .font(.title3)
                .foregroundStyle(isFlagged ? .orange : .primary)
                .apply(hasActions ? () : nil) { view, _ in
                    view.accessibilityActions {
                        Button("既読にする") { isRead = true }
                        Button("旗を付ける") { isFlagged = true }
                    }
                }
        }
    }

    private var lines: [String] {
        [A11yText.element(isRead ? "既読: 会議の件" : "未読: 会議の件")] + (hasActions ? ["上下にスワイプして選ぶ: 既読にする・旗を付ける"] : ["（操作なし）"])
    }
}
