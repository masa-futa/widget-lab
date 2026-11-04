import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityHidden = CatalogEntry(
        id: "accessibilityHidden",
        kind: .modifier,
        topic: .accessibilityFundamentals,
        summary: "View を支援技術から隠す modifier。飾りの画像など、読ませなくてよいものに付ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityhidden(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityHidden", .toggle(initial: true), on: true,
                summary: "true なら隠す。飾りの画像を読まず、「新着」だけを読む")
        ],
        code: CodeTemplate(
            prefix: ["HStack {"], call: "Image", fixedArguments: ["systemName: \"sparkles\""],
            closing: ["    Text(\"新着\")", "}"]),
        build: { v in
            AnyView(AccessibilityHiddenDemo(hidden: v.flag("accessibilityHidden")))
        }
    )
}

private struct AccessibilityHiddenDemo: View {
    /// nil なら modifier をかけない
    let hidden: Bool?

    var body: some View {
        A11yDemo(title: "VoiceOver が順に読む要素", lines: lines) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.orange)
                    .apply(hidden) { view, hidden in
                        view.accessibilityHidden(hidden)
                    }
                Text("新着")
            }
            .font(.title3)
        }
    }

    private var lines: [String] {
        hidden == true
            ? [A11yText.element("新着")]
            : A11yText.ordered([A11yText.element("ぴかぴか", traits: [".isImage"]), A11yText.element("新着")])
    }
}
