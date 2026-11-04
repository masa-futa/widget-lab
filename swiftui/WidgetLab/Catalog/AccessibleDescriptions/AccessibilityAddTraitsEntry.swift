import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityAddTraits = CatalogEntry(
        id: "accessibilityAddTraits",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "要素の特性（ボタン・見出し・選択中など）を足す modifier。VoiceOver はラベルのあとに特性を読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityaddtraits(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityAddTraits",
                .choice([Choice(".isButton"), Choice("[.isButton, .isSelected]"), Choice(".isHeader")], initial: 0),
                on: true,
                summary: "足す特性。押せる文字に .isButton を足すと「ボタン」と読む")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"お気に入り\""], suffix: [".onTapGesture { isFavorite.toggle() }"]),
        build: { v in
            AnyView(AddTraitsDemo(choice: v.pick("accessibilityAddTraits", from: [0, 1, 2])))
        }
    )
}

private struct AddTraitsDemo: View {
    /// nil なら modifier をかけない
    let choice: Int?
    @State private var isFavorite = false

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: [A11yText.element("お気に入り", traits: traitNames)]) {
            Text("お気に入り")
                .font(.title3)
                .foregroundStyle(isFavorite ? .orange : .primary)
                .apply(choice) { view, choice in
                    view.accessibilityAddTraits(
                        [AccessibilityTraits.isButton, [.isButton, .isSelected], .isHeader][choice])
                }
                .onTapGesture { isFavorite.toggle() }
        }
    }

    private var traitNames: [String] {
        switch choice {
        case 0: [".isButton"]
        case 1: [".isButton", ".isSelected"]
        case 2: [".isHeader"]
        default: ["（特性なし。押せることが伝わらない）"]
        }
    }
}
