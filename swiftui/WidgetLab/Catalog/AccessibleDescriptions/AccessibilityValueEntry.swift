import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityValue = CatalogEntry(
        id: "accessibilityValue",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "要素が持つ値を言葉で伝える modifier。ラベルのあとに読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityvalue(_:)")!,
        stage: .card,
        properties: [
            .modifier("accessibilityValue", .text(initial: "75%"), on: true, summary: "読ませる値。ラベル「電池」のあとに読む")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"battery.75percent\")"], call: ".accessibilityLabel",
            fixedArguments: ["\"電池\""]),
        build: { v in
            AnyView(AccessibilityValueDemo(value: v.text("accessibilityValue")))
        }
    )
}

private struct AccessibilityValueDemo: View {
    /// nil なら modifier をかけない
    let value: String?

    var body: some View {
        A11yDemo(
            title: "VoiceOver が読む要素", lines: [A11yText.element("電池", value: value, traits: [".isImage"])]
        ) {
            Image(systemName: "battery.75percent")
                .font(.largeTitle)
                .accessibilityLabel("電池")
                .apply(value) { view, value in
                    view.accessibilityValue(value)
                }
        }
    }
}
