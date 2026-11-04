import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityRepresentation = CatalogEntry(
        id: "accessibilityRepresentation",
        kind: .modifier,
        topic: .accessibilityFundamentals,
        summary: "支援技術には、渡した View の要素を見せる modifier。自作の部品を、Toggle などの既製の部品として読ませる。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/accessibilityrepresentation(representation:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityRepresentation", label: "representation",
                .fixed(code: "{ Toggle(\"通知\", isOn: $isOn) }"), on: true,
                summary: "代わりに読ませる View。画面には描かない。自作のスイッチを Toggle として読み、2 回タップで切り替わる")
        ],
        code: CodeTemplate(
            prefix: [
                "// 自作のスイッチ", "Capsule()", "    .fill(isOn ? .green : .gray)", "    .frame(width: 52, height: 32)",
            ],
            call: ".onTapGesture", trailing: " { isOn.toggle() }"),
        build: { v in
            AnyView(AccessibilityRepresentationDemo(represents: v["accessibilityRepresentation"] != nil))
        }
    )
}

private struct AccessibilityRepresentationDemo: View {
    let represents: Bool
    @State private var isOn = true

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: lines) {
            Capsule()
                .fill(isOn ? .green : .gray)
                .frame(width: 52, height: 32)
                .overlay(alignment: isOn ? .trailing : .leading) {
                    Circle().fill(.white).padding(3)
                }
                .onTapGesture { isOn.toggle() }
                .apply(represents ? () : nil) { view, _ in
                    view.accessibilityRepresentation {
                        Toggle("通知", isOn: $isOn)
                    }
                }
        }
        // 付け外しのたびに作り直す（同じ View のまま representation を外すと、UI テストでアプリが止まった）
        .id(represents)
    }

    private var lines: [String] {
        represents
            ? [A11yText.element("通知", value: isOn ? "1" : "0", traits: [".isToggle"])]
            : ["（読まない。押せることも伝わらない）"]
    }
}
