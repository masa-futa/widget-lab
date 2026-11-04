import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollTargetLayout = CatalogEntry(
        id: "scrollTargetLayout",
        kind: .modifier,
        topic: .scrollViews,
        summary: "並びの入れ物の子を、スクロールが止まる目印（scroll target）にする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrolltargetlayout(isenabled:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollTargetLayout", .fixed(code: ""), on: true,
                summary: "子を止まる目印にする（OFF なら .viewAligned でもカードの途中で止まる）")
        ],
        code: CodeTemplate(
            prefix: ["ScrollView(.horizontal) {"], call: "LazyHStack",
            trailing: " {\n        ForEach(1...10, id: \\.self) { i in\n            Text(\"\\(i)\")\n"
                + "                .frame(width: 160, height: 100)\n"
                + "                .background(.yellow, in: .rect(cornerRadius: 12))\n        }\n    }",
            closing: ["}", ".scrollTargetBehavior(.viewAligned)"]),
        build: { v in
            AnyView(
                ScrollView(.horizontal) {
                    ScrollCardsDemo()
                        .apply(v["scrollTargetLayout"] != nil ? () : nil) { view, _ in view.scrollTargetLayout() }
                }
                .scrollTargetBehavior(.viewAligned)
            )
        }
    )
}
