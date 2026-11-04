import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollPosition = CatalogEntry(
        id: "scrollPosition",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView のいまの位置（anchor の位置に見えている子の id。.top なら、いちばん上の子）を値に結び付ける modifier。値を変えるとスクロールする。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollposition(id:anchor:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollPosition", id: "scrollPosition.id", label: "id", .fixed(code: "$current"), on: true,
                summary: "位置を入れる値（スクロールすると変わり、変えるとスクロールする）"),
            .modifier(
                "scrollPosition", id: "scrollPosition.anchor", label: "anchor",
                .choice([Choice(".top"), Choice(".center"), Choice(".bottom")], initial: 0), required: true,
                summary: "どこに見えている子を位置とするか"),
        ],
        code: CodeTemplate(
            call: "ScrollView",
            trailing: " {\n    LazyVStack {\n        ForEach(1...50, id: \\.self) { Text(\"行 \\($0)\") }\n    }\n"
                + "    .scrollTargetLayout()\n}"),
        build: { v in
            AnyView(
                ScrollPositionDemo(
                    binds: v["scrollPosition.id"] != nil,
                    anchor: v.pick("scrollPosition.anchor", from: [UnitPoint.top, .center, .bottom]) ?? .top)
            )
        }
    )
}

private struct ScrollPositionDemo: View {
    let binds: Bool
    let anchor: UnitPoint
    @State private var current: Int?

    var body: some View {
        VStack {
            HStack {
                Button("行 1 へ") { current = 1 }
                Button("行 25 へ") { current = 25 }
                Text("位置: \(current.map { "行 \($0)" } ?? "なし")")
                    .monospacedDigit()
            }
            .buttonStyle(.bordered)
            ScrollView {
                LazyVStack {
                    ForEach(1...50, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity, minHeight: 32)
                    }
                }
                .scrollTargetLayout()
            }
            .apply(binds ? () : nil) { view, _ in view.scrollPosition(id: $current, anchor: anchor) }
        }
        .padding(.top, 8)
    }
}
