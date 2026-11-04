import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityHint = CatalogEntry(
        id: "accessibilityHint",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "押すと何が起きるかを伝えるヒントを付ける modifier。VoiceOver は、ラベルと特性を読んで少し間をおいてから読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityhint(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityHint", .text(initial: "メールを送って、一覧に戻ります"), on: true,
                summary: "ヒントの文。何が起きるかを短く書く")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"送る\""], trailing: " { send() }"),
        build: { v in
            AnyView(HintDemo(hint: v.text("accessibilityHint")))
        }
    )
}

private struct HintDemo: View {
    /// nil なら modifier をかけない
    let hint: String?

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: [A11yText.element("送る", traits: [".isButton"], hint: hint)]) {
            Button("送る") {}
                .buttonStyle(.borderedProminent)
                .apply(hint) { view, hint in
                    view.accessibilityHint(hint)
                }
        }
    }
}
