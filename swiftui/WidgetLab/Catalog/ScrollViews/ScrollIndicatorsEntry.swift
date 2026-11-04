import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollIndicators = CatalogEntry(
        id: "scrollIndicators",
        kind: .modifier,
        topic: .scrollViews,
        summary: "中の ScrollView のスクロールバーを出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollindicators(_:axes:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollIndicators",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".never"), Choice(".automatic")], initial: 0),
                on: true, summary: "バーを出すか（スクロールしている間に見る）")
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n}"),
        build: { v in
            AnyView(
                ScrollView {
                    ForEach(1...30, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity, minHeight: 32)
                    }
                }
                .apply(
                    v.pick("scrollIndicators", from: [ScrollIndicatorVisibility.hidden, .visible, .never, .automatic])
                ) { $0.scrollIndicators($1) }
            )
        }
    )
}
