import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityRemoveTraits = CatalogEntry(
        id: "accessibilityRemoveTraits",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "要素の特性を取り除く modifier。文字の代わりに置いた絵を、「画像」と読ませないときなどに使う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityremovetraits(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityRemoveTraits", .fixed(code: ".isImage"), on: true,
                summary: "取り除く特性。.isImage を取ると「画像」と読まない")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"star.fill\")"], call: ".accessibilityLabel", fixedArguments: ["\"評価 3\""]),
        build: { v in
            AnyView(RemoveTraitsDemo(removes: v["accessibilityRemoveTraits"] != nil))
        }
    )
}

private struct RemoveTraitsDemo: View {
    let removes: Bool

    var body: some View {
        A11yDemo(
            title: "VoiceOver が読む要素",
            lines: [A11yText.element("評価 3", traits: removes ? [] : [".isImage"])]
        ) {
            Image(systemName: "star.fill")
                .font(.largeTitle)
                .foregroundStyle(.yellow)
                .accessibilityLabel("評価 3")
                .apply(removes ? () : nil) { view, _ in
                    view.accessibilityRemoveTraits(.isImage)
                }
        }
    }
}
