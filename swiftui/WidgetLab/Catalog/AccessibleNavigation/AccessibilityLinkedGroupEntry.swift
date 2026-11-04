import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityLinkedGroup = CatalogEntry(
        id: "accessibilityLinkedGroup",
        kind: .modifier,
        topic: .accessibleNavigation,
        summary: "離れた場所にある要素どうしをつなぐ modifier。VoiceOver で、つないだ要素の間をすぐ行き来できる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilitylinkedgroup(id:in:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityLinkedGroup", .fixed(code: "id: \"q1\", in: namespace"), on: true,
                summary: "つなぐ印。問 1 と同じ id と namespace を答え 1 に付ける")
        ],
        code: CodeTemplate(
            prefix: [
                "VStack(alignment: .leading) {", "    Text(\"問 1: 2 + 3 は？\")",
                "        .accessibilityLinkedGroup(id: \"q1\", in: namespace)", "    Text(\"問 2: 4 + 4 は？\")",
                "    Divider()",
            ], call: "Text", fixedArguments: ["\"答え 1: 5\""], closing: ["    Text(\"答え 2: 8\")", "}"]),
        build: { v in
            AnyView(LinkedGroupDemo(links: v["accessibilityLinkedGroup"] != nil))
        }
    )
}

private struct LinkedGroupDemo: View {
    let links: Bool
    @Namespace private var namespace

    var body: some View {
        A11yDemo(title: "VoiceOver の行き来", lines: [line]) {
            VStack(alignment: .leading, spacing: 6) {
                Text("問 1: 2 + 3 は？")
                    .accessibilityLinkedGroup(id: "q1", in: namespace)
                Text("問 2: 4 + 4 は？")
                Divider()
                Text("答え 1: 5")
                    .apply(links ? () : nil) { view, _ in
                        view.accessibilityLinkedGroup(id: "q1", in: namespace)
                    }
                Text("答え 2: 8")
            }
            .frame(width: 200)
        }
    }

    private var line: String {
        links ? "「問 1」と「答え 1」の間を、間の要素を飛ばして行き来できる" : "問 1 → 問 2 → 答え 1 の順にしか進めない"
    }
}
