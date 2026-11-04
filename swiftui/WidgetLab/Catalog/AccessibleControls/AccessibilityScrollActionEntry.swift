import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityScrollAction = CatalogEntry(
        id: "accessibilityScrollAction",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術のスクロールの操作に応える modifier。VoiceOver では、3 本指でスワイプしたときに呼ばれる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityscrollaction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityScrollAction", .fixed(code: "{ edge in page += edge == .trailing ? 1 : -1 }"), on: true,
                summary: "スクロールの処理。スクロールする向きの端（Edge）が渡る")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"\\(page) / 5 ページ\""]),
        build: { v in
            AnyView(ScrollActionDemo(isScrollable: v["accessibilityScrollAction"] != nil))
        }
    )
}

private struct ScrollActionDemo: View {
    let isScrollable: Bool
    @State private var page = 2

    var body: some View {
        A11yDemo(title: "VoiceOver で行える操作", lines: lines) {
            Text("\(page) / 5 ページ")
                .font(.title2)
                .monospacedDigit()
                .apply(isScrollable ? () : nil) { view, _ in
                    view.accessibilityScrollAction { edge in
                        page = min(max(page + (edge == .trailing ? 1 : -1), 1), 5)
                    }
                }
        }
    }

    private var lines: [String] {
        [A11yText.element("\(page) / 5 ページ")]
            + (isScrollable ? ["3 本指で左右にスワイプして、ページを送る"] : ["（3 本指でスワイプしても変わらない）"])
    }
}
