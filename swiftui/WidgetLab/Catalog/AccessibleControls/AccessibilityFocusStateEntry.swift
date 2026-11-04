import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityFocusState = CatalogEntry(
        id: "AccessibilityFocusState",
        kind: .propertyWrapper,
        topic: .accessibleControls,
        summary: "VoiceOver などのカーソルがどこにあるかを持つ値。読んでカーソルの場所を知り、書いてカーソルを移す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/accessibilityfocusstate")!,
        stage: .card,
        properties: [
            .wrapper("AccessibilityFocusState", summary: "外すと、ただの値になり、カーソルとつながらない（.accessibilityFocused も書けない）")
        ],
        code: CodeTemplate(
            call: "AccessibilityFocusState",
            wrapper: WrapperCode(
                withWrapper: [
                    "@AccessibilityFocusState private var isTotalFocused: Bool",
                    "var body: some View {",
                    "    Button(\"合計へ移る\") { isTotalFocused = true }",
                    "    Text(\"合計: 1,200 円\")",
                    "        .accessibilityFocused($isTotalFocused)",
                    "}",
                ],
                withoutWrapper: [
                    "@State private var isTotalFocused = false  // カーソルとつながらない",
                    "var body: some View {",
                    "    Button(\"合計へ移る\") { isTotalFocused = true }",
                    "    Text(\"合計: 1,200 円\")",
                    "}",
                ])),
        build: { v in
            v["AccessibilityFocusState"] != nil
                ? AnyView(AccessibilityFocusDemo(connects: true)) : AnyView(PlainFocusDemo())
        }
    )
}

/// ラッパーを外した見本。ただの値なので、VoiceOver のカーソルとつながらない
private struct PlainFocusDemo: View {
    @State private var isTotalFocused = false

    var body: some View {
        A11yDemo(
            title: "VoiceOver のカーソル",
            lines: ["isTotalFocused: \(isTotalFocused)", "（ただの値。ボタンで true になっても、カーソルは動かない）"]
        ) {
            VStack(spacing: 12) {
                Button("合計へ移る") { isTotalFocused = true }
                    .buttonStyle(.bordered)
                Text("合計: 1,200 円")
                    .font(.title3)
            }
        }
    }
}
