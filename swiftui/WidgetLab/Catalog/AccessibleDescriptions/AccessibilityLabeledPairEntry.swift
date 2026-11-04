import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityLabeledPair = CatalogEntry(
        id: "accessibilityLabeledPair",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "離れて置いたラベルの要素と中身の要素を組にする modifier。中身の要素を、ラベルの文字で読ませる。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilitylabeledpair(role:id:in:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityLabeledPair", .fixed(code: "role: .content, id: \"notify\", in: namespace"), on: true,
                summary: "中身の側の印。ラベルの側（role: .label）と同じ id と namespace を渡すと組になる")
        ],
        code: CodeTemplate(
            prefix: [
                "HStack {", "    Text(\"通知\")",
                "        .accessibilityLabeledPair(role: .label, id: \"notify\", in: namespace)",
                "    Toggle(\"\", isOn: $isOn)",
            ], indent: 8, call: ".labelsHidden", closing: ["}"]),
        build: { v in
            AnyView(LabeledPairDemo(pairs: v["accessibilityLabeledPair"] != nil))
        }
    )
}

private struct LabeledPairDemo: View {
    let pairs: Bool
    @State private var isOn = true
    @Namespace private var namespace

    var body: some View {
        A11yDemo(title: "VoiceOver が順に読む要素", lines: lines) {
            HStack {
                Text("通知")
                    .accessibilityLabeledPair(role: .label, id: "notify", in: namespace)
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .apply(pairs ? () : nil) { view, _ in
                        view.accessibilityLabeledPair(role: .content, id: "notify", in: namespace)
                    }
            }
            .padding(.horizontal, 12)
            .frame(width: 240, height: 52)
            .background(Color(.systemBackground), in: .rect(cornerRadius: 10))
        }
    }

    private var lines: [String] {
        let value = isOn ? "1" : "0"
        return pairs
            ? A11yText.ordered([A11yText.element("通知"), A11yText.element("通知", value: value, traits: [".isToggle"])])
            : A11yText.ordered([A11yText.element("通知"), A11yText.element(nil, value: value, traits: [".isToggle"])])
    }
}
