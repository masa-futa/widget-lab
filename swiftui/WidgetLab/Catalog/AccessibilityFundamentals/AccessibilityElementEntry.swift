import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityElement = CatalogEntry(
        id: "accessibilityElement",
        kind: .modifier,
        topic: .accessibilityFundamentals,
        summary: "子の View を、支援技術から見て 1 つの要素にまとめる modifier。子の扱いを children で選ぶ。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityelement(children:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityElement", label: "children",
                .choice([Choice(".combine"), Choice(".ignore"), Choice(".contain")], initial: 0), on: true,
                summary: "子の扱い。.combine は子のラベルをつないで 1 つに、.ignore は子を読まず中身のない 1 つに、.contain は子を残して組にする")
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing:
                " {\n    Image(systemName: \"star.fill\")\n        .accessibilityLabel(\"星\")\n    Text(\"お気に入り\")\n    Text(\"12\")\n}"
        ),
        build: { v in
            AnyView(AccessibilityElementDemo(children: v.pick("accessibilityElement", from: [0, 1, 2])))
        }
    )
}

private struct AccessibilityElementDemo: View {
    /// nil なら modifier をかけない。0 .combine・1 .ignore・2 .contain
    let children: Int?

    var body: some View {
        A11yDemo(title: "VoiceOver が順に読む要素", lines: lines) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .accessibilityLabel("星")
                Text("お気に入り")
                Text("12")
                    .monospacedDigit()
            }
            .font(.title3)
            .apply(children) { view, children in
                view.accessibilityElement(children: [AccessibilityChildBehavior.combine, .ignore, .contain][children])
            }
        }
    }

    private var lines: [String] {
        let each = [A11yText.element("星", traits: [".isImage"]), A11yText.element("お気に入り"), A11yText.element("12")]
        return switch children {
        case 0: [A11yText.element("星、お気に入り、12") + "（1 つ）"]
        case 1: ["（ラベルなし）（1 つ。子は読まない）"]
        case 2: A11yText.ordered(each) + ["（3 つで 1 つの組）"]
        default: A11yText.ordered(each)
        }
    }
}
