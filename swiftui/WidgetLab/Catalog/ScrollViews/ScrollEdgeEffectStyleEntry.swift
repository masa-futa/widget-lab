import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollEdgeEffectStyle = CatalogEntry(
        id: "scrollEdgeEffectStyle",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView の端で、上に重なるバー（ツールバーや safeAreaBar）の下の中身をぼかす効果の形を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrolledgeeffectstyle(_:for:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollEdgeEffectStyle", id: "scrollEdgeEffectStyle.style",
                .choice([Choice(".hard"), Choice(".soft"), Choice(".automatic")], initial: 0), on: true,
                summary: "効果の形（.hard はくっきりした境目、.soft はなだらか）"),
            .modifier(
                "scrollEdgeEffectStyle", id: "scrollEdgeEffectStyle.edges", label: "for",
                .choice([Choice(".top"), Choice(".bottom"), Choice(".all")], initial: 0), required: true,
                summary: "効果を変える端"),
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
            let edges = v.pick("scrollEdgeEffectStyle.edges", from: [Edge.Set.top, .bottom, .all]) ?? .all
            return AnyView(
                ScrollView { EdgeEffectDemo.rows }
                    .defaultScrollAnchor(.center)
                    .safeAreaBar(edge: .top) { EdgeEffectDemo.bar }
                    .apply(
                        v.pick("scrollEdgeEffectStyle.style", from: [ScrollEdgeEffectStyle.hard, .soft, .automatic])
                    ) { $0.scrollEdgeEffectStyle($1, for: edges) }
            )
        }
    )
}
