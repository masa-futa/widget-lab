import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollTargetBehavior = CatalogEntry(
        id: "scrollTargetBehavior",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView を指で動かしたあとに止まる位置の決め方（ページごと・子ごと）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrolltargetbehavior(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollTargetBehavior", .choice([Choice(".viewAligned"), Choice(".paging")], initial: 0), on: true,
                summary: "止まる位置（.viewAligned は子の頭、.paging は枠の幅ごと）")
        ],
        code: CodeTemplate(
            call: "ScrollView", fixedArguments: [".horizontal"],
            trailing: " {\n    LazyHStack {\n        ForEach(1...10, id: \\.self) { i in\n            Text(\"\\(i)\")\n"
                + "                .frame(width: 160, height: 100)\n"
                + "                .background(.yellow, in: .rect(cornerRadius: 12))\n        }\n    }\n"
                + "    .scrollTargetLayout()\n}"),
        build: { v in
            AnyView(
                ScrollView(.horizontal) {
                    ScrollCardsDemo()
                        .scrollTargetLayout()
                }
                .apply(v.pick("scrollTargetBehavior", from: [0, 1])) { view, i in
                    if i == 0 { view.scrollTargetBehavior(.viewAligned) } else { view.scrollTargetBehavior(.paging) }
                }
            )
        }
    )
}
