import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollEdgeEffectHidden = CatalogEntry(
        id: "scrollEdgeEffectHidden",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView の端で、上に重なるバーの下の中身をぼかす効果を消す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrolledgeeffecthidden(_:for:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollEdgeEffectHidden", id: "scrollEdgeEffectHidden.hidden", .toggle(initial: true), on: true,
                summary: "効果を消す"),
            .modifier(
                "scrollEdgeEffectHidden", id: "scrollEdgeEffectHidden.edges", label: "for",
                .choice([Choice(".top"), Choice(".bottom"), Choice(".all")], initial: 0), required: true,
                summary: "効果を消す端"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(1...30, id: \\.self) { i in", "        Text(\"行 \\(i)\")",
                "            .frame(maxWidth: .infinity, minHeight: 44)",
                "            .background(Color(hue: Double(i % 10) / 10, saturation: 0.5, brightness: 1))", "    }",
                "}", ".defaultScrollAnchor(.center)",
            ],
            indent: 0, call: ".safeAreaBar", fixedArguments: ["edge: .top", "content: { Text(\"見出しのバー\").padding(8) }"]),
        build: { v in
            let edges = v.pick("scrollEdgeEffectHidden.edges", from: [Edge.Set.top, .bottom, .all]) ?? .all
            return AnyView(
                ScrollView { EdgeEffectDemo.rows }
                    .defaultScrollAnchor(.center)
                    .safeAreaBar(edge: .top) { EdgeEffectDemo.bar }
                    .apply(v.flag("scrollEdgeEffectHidden.hidden")) { $0.scrollEdgeEffectHidden($1, for: edges) }
            )
        }
    )
}
