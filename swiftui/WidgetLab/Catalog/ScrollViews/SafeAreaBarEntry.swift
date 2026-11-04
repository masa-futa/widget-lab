import SwiftUI

nonisolated extension CatalogEntry {
    static let safeAreaBar = CatalogEntry(
        id: "safeAreaBar",
        kind: .modifier,
        topic: .scrollViews,
        summary: "View の端に、自前のバーを置く modifier。safeAreaInset と違い、下に入ったスクロールの中身にぼかしの効果がかかる。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/safeareabar(edge:alignment:spacing:content:)")!,
        stage: .card,
        properties: [
            .modifier(
                "safeAreaBar", id: "safeAreaBar.edge", label: "edge",
                .choice([Choice(".top"), Choice(".bottom")], initial: 0),
                required: true, summary: "バーを置く端"),
            .modifier(
                "safeAreaBar", id: "safeAreaBar.content", label: "content",
                .fixed(code: "{ Text(\"見出しのバー\").padding(8) }"), on: true, summary: "バーの中身"),
        ],
        code: CodeTemplate(
            call: "ScrollView",
            trailing: " {\n    ForEach(1...30, id: \\.self) { i in\n        Text(\"行 \\(i)\")\n"
                + "            .frame(maxWidth: .infinity, minHeight: 44)\n"
                + "            .background(Color(hue: Double(i % 10) / 10, saturation: 0.5, brightness: 1))\n    }\n}",
            suffix: [".defaultScrollAnchor(.center)"]),
        build: { v in
            let edge = v.pick("safeAreaBar.edge", from: [VerticalEdge.top, .bottom]) ?? .top
            return AnyView(
                ScrollView { EdgeEffectDemo.rows }
                    .apply(v["safeAreaBar.content"] != nil ? () : nil) { view, _ in
                        view.safeAreaBar(edge: edge) { EdgeEffectDemo.bar }
                    }
                    .defaultScrollAnchor(.center)
            )
        }
    )
}
