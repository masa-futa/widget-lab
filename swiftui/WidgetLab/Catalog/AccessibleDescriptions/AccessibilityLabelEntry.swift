import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityLabel = CatalogEntry(
        id: "accessibilityLabel",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "要素の中身を言葉で伝えるラベルを付ける modifier。絵だけのボタンなどに、VoiceOver が読む名前を付ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilitylabel(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityLabel", .text(initial: "ごみ箱に入れる"), on: true,
                summary: "読ませる名前。外すと、絵の名前（SF Symbols の名前から作ったもの）を読む")
        ],
        code: CodeTemplate(
            call: "Button", trailing: " {\n    moveToTrash()\n} label: {\n    Image(systemName: \"trash\")\n}"),
        build: { v in
            AnyView(AccessibilityLabelDemo(label: v.text("accessibilityLabel")))
        }
    )
}

private struct AccessibilityLabelDemo: View {
    /// nil なら modifier をかけない
    let label: String?

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: [A11yText.element(label ?? "ゴミ箱", traits: [".isButton"])]) {
            Button {
            } label: {
                Image(systemName: "trash")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            .apply(label) { view, label in
                view.accessibilityLabel(label)
            }
        }
    }
}
