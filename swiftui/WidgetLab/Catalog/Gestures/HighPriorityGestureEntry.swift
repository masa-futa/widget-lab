import SwiftUI

nonisolated extension CatalogEntry {
    static let highPriorityGesture = CatalogEntry(
        id: "highPriorityGesture",
        kind: .modifier,
        topic: .gestures,
        summary: "View にジェスチャーを付け、中の View のジェスチャーより先に認識させる modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/highprioritygesture(_:including:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "highPriorityGesture", .fixed(code: "TapGesture().onEnded { print(\"外側\") }"), on: true,
                summary: "外側に付けるジェスチャー。内側をタップしても、外側だけが動く"),
            .modifier(
                "highPriorityGesture", id: "highPriorityGesture.including", label: "including",
                .choice([Choice(".all"), Choice(".gesture"), Choice(".subviews"), Choice(".none")], initial: 0),
                required: true,
                summary: "効かせる範囲。.subviews は外側が止まり内側が動く、.none はどちらも止まる"),
        ],
        code: CodeTemplate(
            call: "VStack", trailing: " {\n    Text(\"内側\")\n        .onTapGesture { print(\"内側\") }\n}"),
        build: { v in
            AnyView(
                OuterGestureDemo(
                    kind: v["highPriorityGesture"] != nil ? .highPriority : nil,
                    mask: v.pick("highPriorityGesture.including", from: [GestureMask.all, .gesture, .subviews, .none])
                        ?? .all))
        }
    )
}
