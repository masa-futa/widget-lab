import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityIdentifier = CatalogEntry(
        id: "accessibilityIdentifier",
        kind: .modifier,
        topic: .accessibilityFundamentals,
        summary: "View を見分ける名前を付ける modifier。VoiceOver は読まず、UI テストが要素を探すときに使う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityidentifier(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityIdentifier", .text(initial: "save-button"), on: true,
                summary: "見分ける名前。文言を変えても、UI テストは同じ名前で探せる")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存\""], trailing: " { save() }"),
        build: { v in
            AnyView(AccessibilityIdentifierDemo(identifier: v.text("accessibilityIdentifier")))
        }
    )
}

private struct AccessibilityIdentifierDemo: View {
    let identifier: String?

    var body: some View {
        A11yDemo(title: "UI テストで探す書き方", lines: lines) {
            Button("保存") {}
                .buttonStyle(.borderedProminent)
                .apply(identifier) { view, identifier in
                    view.accessibilityIdentifier(identifier)
                }
        }
    }

    private var lines: [String] {
        if let identifier {
            ["app.buttons[\"\(identifier)\"]", "（VoiceOver は「保存」と読み、名前は読まない）"]
        } else {
            ["app.buttons[\"保存\"]", "（名前がないのでラベルで探す。文言を変えるとテストが壊れる）"]
        }
    }
}
