import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityHeading = CatalogEntry(
        id: "accessibilityHeading",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "見出しの段（1〜6）を決める modifier。VoiceOver のローターで、段ごとに見出しへ飛べる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityheading(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityHeading", .choice([Choice(".h1"), Choice(".h2"), Choice(".h3")], initial: 1), on: true,
                summary: "見出しの段。.isHeader の特性と組で使う")
        ],
        code: CodeTemplate(
            prefix: ["VStack(alignment: .leading) {"], call: "Text", fixedArguments: ["\"お知らせ\""],
            suffix: [".accessibilityAddTraits(.isHeader)"], closing: ["    Text(\"明日は休みです\")", "}"]),
        build: { v in
            AnyView(HeadingDemo(level: v.pick("accessibilityHeading", from: [1, 2, 3])))
        }
    )
}

private struct HeadingDemo: View {
    /// nil なら modifier をかけない
    let level: Int?

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: lines) {
            VStack(alignment: .leading, spacing: 4) {
                Text("お知らせ")
                    .font(.headline)
                    .apply(level) { view, level in
                        view.accessibilityHeading([AccessibilityHeadingLevel.h1, .h2, .h3][level - 1])
                    }
                    .accessibilityAddTraits(.isHeader)
                Text("明日は休みです")
            }
        }
    }

    private var lines: [String] {
        A11yText.ordered([
            A11yText.element("お知らせ", traits: [".isHeader"] + (level.map { ["段 \($0)"] } ?? [])),
            A11yText.element("明日は休みです"),
        ])
            + [level.map { "ローターの「見出しレベル \($0)」でも飛べる" } ?? "ローターの「見出し」で飛べる（段なし）"]
    }
}
