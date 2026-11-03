import SwiftUI

nonisolated extension CatalogEntry {
    static let layoutValue = CatalogEntry(
        id: "layoutValue",
        kind: .modifier,
        topic: .customLayout,
        summary: "自作の Layout が読む値を、子の View に付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/layoutvalue(key:value:)")!,
        stage: .card,
        properties: [
            .modifier(
                "layoutValue", id: "layoutValue.key", label: "key", .fixed(code: "Rank.self"), required: true,
                summary: "値の種類（LayoutValueKey に合わせた型）"),
            .modifier(
                "layoutValue", id: "layoutValue.value", label: "value", .slider(range: 0...3, step: 1, initial: 3),
                on: true, summary: "付ける値。RankedHStack は小さい順に左から並べる（OFF なら既定の 0）"),
        ],
        code: CodeTemplate(
            prefix: [
                "// Rank: 既定 0 の LayoutValueKey、RankedHStack: Rank の小さい順に左から並べる Layout",
                "RankedHStack {", "    Text(\"A\").layoutValue(key: Rank.self, value: 1)",
            ],
            call: "Text", fixedArguments: ["\"B\""], suffix: [".background(.yellow)"],
            closing: ["    Text(\"C\").layoutValue(key: Rank.self, value: 2)", "}"]),
        build: { v in
            AnyView(
                RankedHStack {
                    Text("A").layoutValue(key: Rank.self, value: 1)
                    Text("B")
                        .apply(v.number("layoutValue.value")) { $0.layoutValue(key: Rank.self, value: $1) }
                        .background(.yellow)
                    Text("C").layoutValue(key: Rank.self, value: 2)
                }
                .font(.largeTitle)
                .border(.secondary)
            )
        }
    )
}

/// 並べる順の値（小さいほど左）
nonisolated private struct Rank: LayoutValueKey {
    static let defaultValue: Double = 0
}

/// 子を Rank の小さい順に左から並べる Layout
nonisolated private struct RankedHStack: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let width = sizes.map(\.width).reduce(0, +) + spacing * CGFloat(max(sizes.count - 1, 0))
        return CGSize(width: width, height: sizes.map(\.height).max() ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        for subview in subviews.sorted(by: { $0[Rank.self] < $1[Rank.self] }) {
            let size = subview.sizeThatFits(.unspecified)
            subview.place(at: CGPoint(x: x, y: bounds.midY), anchor: .leading, proposal: ProposedViewSize(size))
            x += size.width + spacing
        }
    }
}
