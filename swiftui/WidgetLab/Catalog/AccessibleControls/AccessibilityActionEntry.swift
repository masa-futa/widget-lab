import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityAction = CatalogEntry(
        id: "accessibilityAction",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術から呼べる操作を 1 つ足す modifier。VoiceOver では、上下にスワイプして操作を選び、2 回タップで行う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityaction(named:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityAction",
                .choice(
                    [
                        Choice("名前を付ける", code: "named: \"既読にする\", { isRead = true }"),
                        Choice(".magicTap", code: ".magicTap, { isRead = true }"),
                    ], initial: 0), on: true,
                summary: "足す操作。名前を付けると操作の一覧に出る。.magicTap は 2 本指で 2 回タップしたときに行う")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["isRead ? \"既読: 会議の件\" : \"未読: 会議の件\""]),
        build: { v in
            AnyView(AccessibilityActionDemo(kind: v.pick("accessibilityAction", from: [0, 1])))
        }
    )
}

private struct AccessibilityActionDemo: View {
    /// nil なら modifier をかけない。0 名前を付ける・1 .magicTap
    let kind: Int?
    @State private var isRead = false

    var body: some View {
        A11yDemo(title: "VoiceOver で行える操作", lines: lines) {
            Text(isRead ? "既読: 会議の件" : "未読: 会議の件")
                .font(.title3)
                .apply(kind) { view, kind in
                    if kind == 0 {
                        view.accessibilityAction(named: "既読にする") { isRead = true }
                    } else {
                        view.accessibilityAction(.magicTap) { isRead = true }
                    }
                }
        }
    }

    private var lines: [String] {
        let action =
            switch kind {
            case 0: "上下にスワイプして「既読にする」を選び、2 回タップ"
            case 1: "2 本指で 2 回タップすると既読にする"
            default: "（操作なし）"
            }
        return [A11yText.element(isRead ? "既読: 会議の件" : "未読: 会議の件"), action]
    }
}
